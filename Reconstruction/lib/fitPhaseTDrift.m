function [resultp, resultdp, resultdrift] = fitPhaseTDrift(zd, pd, fd, fstep)
    % phase T-drift
    frange = [min(fd), max(fd)];
    flist = frange(1) : fstep: frange(2);
    flen = length(flist);
    pzimgbuf = cell(flen,1);
    
    %make p-z images
    zrange = [0 1500];
    zoomz = 0.1;
    zoomp = 40;
    convsize = 6; % smooth the pzimage
    for m=1:flen
        fs = flist(m);
        fe = fs + fstep;
        tmask = fd>=fs & fd<fe;
        [img, ~, ~] = phaseZ2Image(zd(tmask), pd(tmask), zoomz, zoomp, zrange);
        pzimgbuf{m} = conv2(img, ones(convsize,convsize)/(convsize*convsize));
    end
    
    %cal drift
    apzimg = pzimgbuf{1};
    offsetlist = zeros(flen,1);
    for m=2:flen
        cpzimg = pzimgbuf{m};
        % cal offset
        [center_max, resimg, ~, ~] = calPZimageDist(apzimg, cpzimg);
        offsetlist(m) = center_max;
    end
    
    offsetlist = offsetlist/zoomp;
    offsetlist(end+1) = offsetlist(end);
    flist(end+1) = frange(2);
    offsetlist = unwrap(offsetlist);
    
    resultdrift = interp1(flist, offsetlist, frange(1):frange(2), 'pchp');
    resultdp = interp1(flist, offsetlist, fd, 'pchp');
    resultp = pd - resultdp;
end