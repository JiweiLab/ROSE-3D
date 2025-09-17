function [resultp, resultz, dz, lp, resnormx] = fitPhaseZ2(z,p,lp0)
%   fitPhaseZ
%   solve the equation: p = z*lp(1) + lp(2)
%     z = zdata(tm);
%     p = smInfo(tm,5);
    if nargin <3 || isempty(lp0)    %use default parameter
        tdata = load('..\pcycle.mat');
        lp0 = [-2*pi/tdata.pcycle*(1.518+1)/(1.33+1.33), 0];
        [resultp0, resultz0, dz0, lp0, resnormx0] = fitPhaseZLite(z,p,lp0);
    end

    options = optimset('Display','off','MaxFunEvals',1000,'MaxIter',100,'TolFun',1e-5,'LargeScale','on');
    [lpx,resnormx,~,~]=lsqcurvefit(@(xp, xdata)CalPhaseZSin(xp, xdata), ...
        lp0,z,[sin(p) cos(p)],[],[],options);

    lp = [lpx(1), checkPhase(lpx(2))];

    resultp = CalPhaseZ(lp, z);
    dp = checkPhase(p-resultp); %diff of phase
    dp(dp<-pi) = dp(dp<-pi) + 2*pi;
    dp(dp>pi) = dp(dp>pi) - 2*pi;

    dz = dp/lp(1);
    resultz = z + dz; % correction with phase

end