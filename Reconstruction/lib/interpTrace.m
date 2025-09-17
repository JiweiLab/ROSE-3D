function ret = interpTrace(trace, s)
    tx = trace(:,1);
    ty = trace(:,2);
    % remove bad points
    temp = ones(size(ty))>0;
    temp(2:end) = diff(ty)<0;
    tx = tx(temp);
    ty = ty(temp);
    
    if min(ty)<10
        miny = 1;
    else
        miny = min(ty);
    end
    
    if max(ty) > (s(1)-10)
        maxy = s(1);
    else
        maxy = max(ty);
    end
    
    ylist = miny:maxy;
    
    if len(tx)>1
        xlist = interp1(ty,tx,ylist,'linear','extrap');
    else
        xlist = tx;
    end
    
    xlist(xlist<1) = 1;
    xlist(xlist>s(2)) = s(2);
    
    ret = [xlist', ylist'];
end