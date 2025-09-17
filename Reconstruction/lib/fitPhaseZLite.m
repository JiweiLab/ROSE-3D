function [resultp, resultz, dz, lp, resnormx] = fitPhaseZLite(z,p,lp0, lp1)
%   fitPhaseZLite
%   lp(1) is fixed and solve the lp(2)
    if nargin<4
        lp1 = 0;
    end
    
    options = optimset('Display','off','MaxFunEvals',1000,'MaxIter',100,'TolFun',1e-5,'LargeScale','on');
    [lpx,resnormx,~,~]=lsqcurvefit(@(xp, xdata)CalPhaseZSin([lp0(1), xp], xdata), ...
        [lp1],z,[sin(p) cos(p)],[],[],options);

    lp = [lp0(1), checkPhase(lpx)];

    resultp = CalPhaseZ(lp, z);
    dp = checkPhase(p-resultp); %diff of phase
    dp(dp<-pi) = dp(dp<-pi) + 2*pi;
    dp(dp>pi) = dp(dp>pi) - 2*pi;

    dz = dp/lp(1);
    resultz = z + dz; % correction with phase

end