function [lp_optimized, result] = SearchPhasePlane6_CompTest(x,y,p2,fdata,samplerate, searchrange)
    %% sample
    if nargin < 5
        searchrange = [-3.2 3.2];
    end
    if nargin <4
        samplerate = 1;
    end
    if samplerate > 1
        samplerate = min(1, samplerate/length(x));
    end
    samplerate_2 = 100000; %max 10W point for 2nd step fitting
    
    mask = rand(size(x)) <= samplerate;
    xs = x(mask);
    ys = y(mask);
    p2s = p2(mask);
    searchstart = min(searchrange);
    searchend = max(searchrange);
    
% --- 做TXYZ矫正，需要判断每个区间内的点数量有效性 ----%
    samplerate_comp = 5000;
    %T compensation
    doTcomp = 1;
    tstep = 10000; %step-step length
    tsteplen = tstep; %window size
    %XY compensation
    doXYcomp = 1;
    xystep = 20;
    xysteplen = xystep;
    
    %% search for parameters
    lplist1 = searchstart:0.01:searchend;
    lplist2 = 3.50:0.02:3.85;
%     lplist1 = searchstart:0.05:searchend;
%     lplist2 = 2.50:0.05:3.8;

    [aa, bb] = meshgrid(lplist1, lplist2);

    resnormmap = zeros(size(aa));
    
    lplist = zeros(length(aa(:)), 3);
    %options = optimset('Display','off','MaxFunEvals',100,'MaxIter',5,'TolFun',1e-4,'LargeScale','off');
%     parfor_progress(length(aa(:)));
    for m=1:length(aa(:))
        [lp, resnormx] = FitPhasePlane(xs,ys,p2s, [aa(m) bb(m) 0], 1);
        resnormmap(m) = resnormx;
        lplist(m,:) = lp;
%         [lpx,resnormx,residualx,exitflagx]=lsqcurvefit(@(xp, xdata)CalPhaseSin(xp, xs, ys), ...
%         [aa(m) bb(m) 0],xs,[sin(p2s) cos(p2s)],[],[],options);
%         resnormmap(m) = resnormx;
%         lplist(m,:) = lpx;
%         parfor_progress();
    end
%     parfor_progress(0);

    %% get parameters under 500
    mask = find(resnormmap <(min(resnormmap(:))+1));
%     alist = aa(mask);
%     blist = bb(mask);
    lplist = lplist(mask, :);
    
    %decrease data size
    mask = rand(size(x)) <= (samplerate_2/length(x));
    xs = x(mask);
    ys = y(mask);
    p2s = p2(mask);
    
    options = optimset('Display','off','MaxFunEvals',1000,'MaxIter',100,'TolFun',1e-5,'LargeScale','on');
%     for m=1:length(mask)
    [lpx,resnormx,residualx,exitflagx]=lsqcurvefit(@(xp, xdata)CalPhaseSin(xp, xs, ys), ...
    [mean(lplist(:,1)) mean(lplist(:,2)) 0],[],[sin(p2s) cos(p2s)],[],[],options);
%     lplist(m,:) =  lpx;
%     end

    lp_optimized = [lpx(1), lpx(2), checkPhase(lpx(3))];
    result = CalPhase(lp_optimized, x, y);
    
    %% display
    figure()
    surf(aa,bb,resnormmap);
    drawnow();
    
    %% T comp
    if doTcomp>0
        disp('do T-comp ..');
        dpase = checkPhase(result - p2); %phase diff
%         lp_base = lp_optimized;

        tslist = min(fdata) : tstep: (max(fdata)-tstep);
        telist = tslist + tsteplen;
        tcomplen = length(tslist);
        tcompdata = zeros(tcomplen, 2); %[f_mean, phase]
        for m=1:tcomplen
            tm = fdata>=tslist(m) & fdata<=telist(m);
            mask = tm; % & (rand(size(x)) <= (samplerate_comp/sum(tm)));
            
            tcompdata(m,1) = mean(tslist(m), telist(m));
            tcompdata(m,2) = findPeakPhase(dpase(mask));
        end

%         tcompdata(:,2) = tcompdata(:,2) - tcompdata(1,2);
        tcompdata(:,2) = unwrap(tcompdata(:,2));

        % T-compensation
        if size(tcompdata,1)>=2
            p_comp = interp1(tcompdata(:,1), tcompdata(:,2), fdata, 'pchip', 'extrap');
        else
            p_comp = zeros(size(fdata));
        end
        result = checkPhase(result - p_comp);
%         p2_compT = p2 - p_comp;
    else
        result = checkPhase(result);
%         p2_compT = p2;
    end
    
    
    %% XY compensation
    if doXYcomp >0
        dpase = checkPhase(result - p2); %phase diff
        xlist = min(x) : xystep : (max(x) - xystep);
        ylist = min(y) : xystep : (max(y) - xystep);
        [xxs, yys] = meshgrid(xlist, ylist);
        xxs = xxs(:);
        yys = yys(:);
        xxe = xxs + xysteplen;
        yye = yys + xysteplen;
        xycomplen = length(xxs);
        xycompdata = zeros(xycomplen, 4); %[xmean, ymean, phase, datalen]
        for m=1:xycomplen
            tm = x>=xxs(m) & x<=xxe(m) & y>=yys(m) & y<=yye(m);
            mask = tm; % & (rand(size(x)) <= (samplerate_comp/sum(tm)));
            xs = x(mask);
            ys = y(mask);
%             p2s = p2_compT(mask); % use p2 after T-comp!
%             fprintf(1,'xy-comp: step#%d/%d, datalen:%d\n', m, xycomplen, length(xs));
        %-- fitting
%             [lpx,resnormx,residualx,exitflagx]=lsqcurvefit(@(xp, xdata)CalPhaseSin([lp_base(1), lp_base(2), xp(1)], xs, ys), ...
%             [0],[],[sin(p2s) cos(p2s)],[],[],options);
            xycompdata(m,1) = mean(xs);
            xycompdata(m,2) = mean(ys);
            xycompdata(m,3) = findPeakPhase(dpase(mask));
            xycompdata(m,4) = length(xs);
        end

        % XY-compensation
        tmask = xycompdata(:,4)>samplerate_comp*0.1;
        temp = xycompdata(tmask,3);
        tempphase = mean(temp);
        temp=checkPhase(temp-mean(temp));
        tempphase = tempphase + mean(temp);

        xycompdata(:,3) = xycompdata(:,3) - tempphase;
        Fxy = scatteredInterpolant(xycompdata(tmask,1), xycompdata(tmask,2),xycompdata(tmask,3), 'linear','linear');

        p_comp_xy = Fxy(x,y);
        if ~isempty(p_comp_xy)
            result = checkPhase(result - p_comp_xy);
        end
%         p2_compTXY = p2_compT - p_comp_xy;
    else
        result = checkPhase(result);
%         p2_compTXY = p2_compT;
    end
end