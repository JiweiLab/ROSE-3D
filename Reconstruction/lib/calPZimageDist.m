function [center_max, resimg, dlist, conval] = calPZimageDist(timg1, timg2)
%     timg1 = pzimgbuf{42};
%     timg2 = pzimgbuf{46};
%     timg1 = conv2(timg1, ones(3,3)/9, 'same');
%     timg2 = conv2(timg2, ones(3,3)/9, 'same');
    timg2_raw = timg2;
    timg1 = timg1 - mean(timg1(:));
    timg1 = timg1 / max(timg1(:));
    timg2 = timg2 - mean(timg2(:));
    timg2 = timg2 / max(timg2(:));
    
    dlist = -120:1:120;
    dlist = dlist';
    dlen = len(dlist);
    conval = zeros(dlen,1);
    for m=1:dlen
        currd = dlist(m);
        if currd>0
            timg2b = cat(1, timg2(currd+1:end,:), timg2(1:currd,:));
        elseif currd<0
            timg2b = cat(1, timg2(end+currd:end,:), timg2(1:end+currd-1,:));
        else
            timg2b = timg2;
        end
        t2b = timg1.*timg2b./(timg1.^2 + timg2b.^2);
        conval(m) = sum(t2b(~isnan(t2b)));
    end
    center_gfit = fitGauss1D(dlist, conval, 10);
    center_max = dlist(find(conval == max(conval), 1));


    currd = center_max;
    if currd>0
        resimg = cat(1, timg2_raw(currd+1:end,:), timg2_raw(1:currd,:));
    elseif currd<0
        resimg = cat(1, timg2_raw(end+currd:end,:), timg2_raw(1:end+currd-1,:));
    else
        resimg = timg2_raw;
    end
end