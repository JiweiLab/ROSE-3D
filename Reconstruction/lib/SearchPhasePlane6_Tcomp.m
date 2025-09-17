function [lp_optimized, result, tcompdata, p_comp] = SearchPhasePlane6_Tcomp(x,y,p2,fdata,samplerate, searchrange)
% add compensation for XY phase drift
    %% sample
    if nargin < 6
        searchrange = [-3.2 3.2];
    end
    if nargin <5 || isempty(samplerate)
        samplerate = 1;
    end
    if samplerate <= 1
        samplerate = length(x) * samplerate;
    end
    samplerate_2 = 100000; %max 10W point for 2nd step fitting
    samplerate_comp = 100000; %max 10W point for compensation step fitting
    tstep = 10000; %step-step length
    tsteplen = 10000; %window size
    
    tm = fdata<= (min(fdata) + tsteplen);
    mask = tm & (rand(size(x)) <= samplerate/sum(tm));
%     mask = rand(size(x)) <= samplerate;
    xs = x(mask);
    ys = y(mask);
    p2s = p2(mask);
    searchstart = min(searchrange);
    searchend = max(searchrange);
    %% search for parameters
    lplist1 = searchstart:0.01:searchend;
    lplist2 = 3.50:0.02:3.85;

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
    options = optimset('Display','off','MaxFunEvals',1000,'MaxIter',100,'TolFun',1e-5,'LargeScale','on');
%     for m=1:length(mask)

%-- decrease data size
    tm = fdata<= (min(fdata) + tsteplen);
    mask = tm & (rand(size(x)) <= (samplerate_2/sum(tm)));
    xs = x(mask);
    ys = y(mask);
    p2s = p2(mask);

%-- fitting
    [lpx,resnormx,residualx,exitflagx]=lsqcurvefit(@(xp, xdata)CalPhaseSin(xp, xs, ys), ...
    [mean(lplist(:,1)) mean(lplist(:,2)) 0],[],[sin(p2s) cos(p2s)],[],[],options);
%     lplist(m,:) =  lpx;
%     end

    lp_optimized = [lpx(1), lpx(2), checkPhase(lpx(3))];
    result = CalPhase(lp_optimized, x, y);
    
    %% T compensation
    
    lp_base = lp_optimized;
    
    tslist = min(fdata) : tstep: (max(fdata)-tstep);
    telist = tslist + tsteplen;
    tcomplen = length(tslist);
    tcompdata = zeros(tcomplen, 2); %[f_mean, phase]
    if size(tcompdata,1)>=2
        for m=1:tcomplen
            tm = fdata>=tslist(m) & fdata<=telist(m);
            mask = tm & (rand(size(x)) <= (samplerate_comp/sum(tm)));
            xs = x(mask);
            ys = y(mask);
            p2s = p2(mask);
            fprintf(1,'t-comp: step#%d/%d, datalen:%d\n', m, tcomplen, length(xs));
        %-- fitting
            [lpx,resnormx,residualx,exitflagx]=lsqcurvefit(@(xp, xdata)CalPhaseSin([lp_base(1), lp_base(2), xp(1)], xs, ys), ...
            [0],[],[sin(p2s) cos(p2s)],[],[],options);
            tcompdata(m,1) = mean(tslist(m), telist(m));
            tcompdata(m,2) = lpx;
        end

        tcompdata(:,2) = tcompdata(:,2) - tcompdata(1,2);
        tcompdata(:,2) = unwrap(tcompdata(:,2));
    end
    %% T-compensation
    if size(tcompdata,1)>=2
        p_comp = interp1(tcompdata(:,1), tcompdata(:,2), fdata, 'pchip', 'extrap');
    else
        p_comp = zeros(size(fdata));
    end
    result = checkPhase(result + p_comp);
%     p2_compT = p2 - p_comp;
    
    %% display
    figure()
    surf(aa,bb,resnormmap);
%     figure()
%     plot(tcompdata(:,1), tcompdata(:,2));
end