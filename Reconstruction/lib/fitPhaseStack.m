function [resultz, resultp,lplist2,lplist,reslist, lplist_interp] = fitPhaseStack(zd, pd, fd, fstep, lp1_est)
% fit phase from a stack and return the parameters and interped parameter
if nargin<4 || isempty(fstep)
    fstep = 2000;
end
if nargin<5 || isempty(lp1_est)
    skiplp1 = 0;
    lp1_est = 0;
else
    skiplp1 = 1;
end


framenum = max(fd);
fitlen = ceil(framenum/fstep*2);

if skiplp1
    lplist = [];
    reslist =[];
    fselist = zeros(fitlen, 2);
     pcntlist = zeros(fitlen, 1);
    cnt=1;
    for fs=1:fstep/2:framenum
        fe = fs+fstep;
        fselist(cnt,:) = [fs, fe];
        tm2 = fd>=fs & fd<fe;
        pcntlist(cnt) = sum(tm2);
        cnt = cnt+1;
    end
    disp(sprintf('(skipped)Estimated lp(1): %0.5f', lp1_est));
else
    %% fit phase plane
    pcntlist = zeros(fitlen, 1);
    fselist = zeros(fitlen, 2);
    lplist = zeros(fitlen, 2);
    reslist = zeros(fitlen, 1);
    pbuf = cell(fitlen,2);
    dpbuf = cell(fitlen,1);
    cnt=1;
    for fs=1:fstep/2:framenum
        fe = fs+fstep;
        tm2 = fd>=fs & fd<fe;
        [resultp, resultz, dz, lp, resnormx] = fitPhaseZ2(zd(tm2), pd(tm2));
    %     [resultp, resultz, dz, lp, resnormx] = fitPhaseZLite(zd(tm2), pd(tm2), [-0.019 0]);

        pcntlist(cnt) = sum(tm2);
        fselist(cnt,:) = [fs, fe];
        lplist(cnt,:) = lp;
        reslist(cnt) = resnormx/pcntlist(cnt);
        pbuf{cnt,1} = zd(tm2);
        pbuf{cnt,2} = pd(tm2);
        dpbuf{cnt} = pd(tm2) - resultp;
        cnt = cnt+1;
    end

    %% estimate the lp(1)
    resthreshold = mean(reslist)+3*std(reslist);
    tm2 = reslist<=resthreshold;
    lp1_est = sum(lplist(:,1).*tm2.*pcntlist)/sum(tm2.*pcntlist);
    % lp1_est = -0.025;
    disp(sprintf('Estimated lp(1): %0.5f', lp1_est));
end
%% estimate the drift of lp(2)

lplist2 = zeros(fitlen, 2);
reslist2 = zeros(fitlen, 1);
lastlp = 0;

h = waitbar(0,'Fitting ..');
for m=1:size(fselist,1)
    fs = fselist(m,1);
    fe = fselist(m,2);
    tm2 = fd>=fs & fd<fe;
    [resultp, resultz, dz, lp, resnormx] = fitPhaseZLite(zd(tm2), pd(tm2), lp1_est, lastlp);
    
    lplist2(m,:) = lp;
    reslist2(m) = resnormx/pcntlist(m);
    lastlp = lp(2);
    
    waitbar(m/size(fselist,1),h,sprintf('Fitting ..(%d/%d)', m, size(fselist,1)));
end
close(h);

lplist2(:,2) = unwrap(lplist2(:,2), pi*3/2);
% plot(fselist(:,1),lplist2(:,2))
% title lp(2)drift

%% make the interp of lp
if size(lplist2,1)>1
    lp2 = interp1(mean(fselist, 2), lplist2(:,2), 1:framenum, 'pchip','extrap');
else
    disp('not enought frame number, skip interp!')
    lp2 = ones(size(1:framenum)).*lplist(1,2);
end
% plot(1:framenum, lp2)
% title('Interp of lp2');

lplist_interp = [ones(framenum,1).*lp1_est, lp2'];

%% calculate the resultp and z_corr
resultp = CalPhaseZ_frame(lplist_interp, zd, fd);
dp = checkPhase(pd-resultp); %diff of phase
dp(dp<-pi) = dp(dp<-pi) + 2*pi;
dp(dp>pi) = dp(dp>pi) - 2*pi;

dz = dp./lplist_interp(fd, 1);
resultz = zd + dz; % correction with phase