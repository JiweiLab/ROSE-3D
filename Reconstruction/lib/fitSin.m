function [lp, rety] = fitSin(x,y,initcyc)
% y = lp(1) * sin(lp(2)*x+lp(3)) + lp(4)
    if nargin<3
        initcyc = 0.1;
    end
    xp = [(max(y)-min(y))/2, initcyc, 0,(max(y)+min(y))/2];
    options = optimset('Display','off','MaxFunEvals',1e7,'MaxIter',100,'TolFun',0.01,'LargeScale','on');
    [lp,resnorm,residual,exitflag]=lsqcurvefit(@SinFunc,xp,x,y,[],[],options);
    rety = SinFunc(lp,x);
end

function result = SinFunc(param, x)
    amp = param(1);
    cyc = param(2);
    phase = param(3);
    offset = param(4);
    
    result = amp* sin(cyc*x+phase) + offset;
end