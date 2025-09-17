function [img, funcz, funcp] = phaseZ2Image(zlist, plist, zoomz, zoomp, zrange)
%img = PointSet2Image(xlist, ylist, zoom, rect)
    if nargin <5
        minz = 0;
        maxz = max(zlist);
    else
        minz = zrange(1);
        maxz = zrange(2);
    end
    
    minp = -pi;
    maxp = pi;
%     mask = zlist>=minz & zlist<=maxz & plist>=minp & plist<=maxp;
%     zlist= zlist(mask);
%     plist= plist(mask);
    
    %change to 0-max
    plist = plist - minp;
    zlist = zlist - minz;
    plen = 2*pi;
    zlen = maxz - minz;
    
    
    img = zeros(floor((plen)*zoomp), floor((zlen)*zoomz));
    s = size(img);
    
    zlist =ceil((zlist)*zoomz);
    plist =ceil((plist)*zoomp);
    tm = zlist>0 & zlist<=s(2) & plist>0 & plist<=s(1);
    zlist = zlist(tm);
    plist = plist(tm);
    
    for m=1:length(zlist)
        img(plist(m), zlist(m)) = img(plist(m), zlist(m)) +1;
    end
    
    funcz = @(zlist)(ceil((zlist - minz).*zoomz));
    funcp = @(plist)(ceil((plist - minp).*zoomp));
end