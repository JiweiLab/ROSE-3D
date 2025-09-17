function imgbuf = PointSet2Image3D(xlist, ylist, zdata, zoom, zlist, rect)
    if nargin <6 || isempty(rect)
        minx = floor(min(xlist));
        maxx = ceil(max(xlist));
        miny = floor(min(ylist));
        maxy = ceil(max(ylist));
    else
        minx = rect(1);
        maxx = rect(2);
        miny = rect(3);
        maxy = rect(4);
    end
    
    rect = [minx, maxx, miny, maxy];
    
%     zoom = 16;
    zstep = len(zlist)-1;
%     zrange = [200, 900];
%     zlist = zrange(1):zstep:zrange(2);
%     rect = [floor(min(smInfo(:,1))), ceil(max(smInfo(:,1))), floor(min(smInfo(:,2))), ceil(max(smInfo(:,2)))];
%     minx = rect(1);
%     maxx = rect(2);
%     miny = rect(3);
%     maxy = rect(4);

    imgbuf = zeros((maxy-miny+2)*zoom, (maxx-minx+2)*zoom, zstep, 'int16');
    for m=1:zstep
        ze = zlist(m+1);
        zs = zlist(m);
        tm = zdata>=zs & zdata<ze;
        timg = PointSet2Image(xlist(tm),ylist(tm), zoom, rect);
        imgbuf(:,:,m) = timg;
    end


end