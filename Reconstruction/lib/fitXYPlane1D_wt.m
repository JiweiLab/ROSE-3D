function [resultfitter, lp, resultpmap] = fitXYPlane1D_wt(xx, yy, pmap, wmap)
    if nargin <4
        % no weight 
        wmap = ones(size(pmap));
    end
    xdata = cat(2, xx(:), yy(:));
    ydata = cat(2, sin(pmap(:)), cos(pmap(:)));
    wdata = cat(2, wmap(:), wmap(:));
    xp=[0, 0, 0];

    myfunc = @(x0)(myPlaneFunc2(x0,xdata, ydata, wdata));

    options = optimset('Display','off','MaxFunEvals',1e7,'MaxIter',1000,'TolFun',0.0001,'Algorithm','levenberg-marquardt');
    [lp,resnorm,residual,exitflag]=fminsearch(myfunc,xp,options);

    
    resultfitter = @(xx,yy)(lp(1) + lp(2).*xx + lp(:,3).*yy);
    resultpmap = resultfitter(xx,yy);
end

function fresult = myPlaneFunc2(xp,xdata, ydata, wdata)
    % 1-order plane fit with sin and cos
    % xp:[a, b, c]
    % xdata:[xx,yy], n*2
    % phase = a + b*x + c*y + d*x^2 + e*x*y + f*y^2
    xx = xdata(:,1);
    yy = xdata(:,2);
    p = xp(1) + xp(2).*xx + xp(3).*yy;
    
    ret = (cat(2, sin(p), cos(p)) - ydata).^2;
    
    fresult = sum(ret(:) .* wdata(:));
    %ret=ret(:);
end