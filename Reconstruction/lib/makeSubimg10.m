function [subimgbuf, subimginfo] = makeSubimg10(imgbuf1, imgbuf2, imgbuf3, imgbuf4, imgbuf5, ...
    imgbuf6, imgbuf7, imgbuf8, imgbuf9, imgbuf10, ...
    detectResult, subimgsize)
% [subimgbuf, subimginfo] = makeSubimages(imgbuf1, imgbuf2, imgbuf3, detectResult, subimgsize)
% duplicate subimages from 3 imgebufs with detection results
%
% subimgInfo:[x, y, frame], with x y be integer
%
    s = size(imgbuf1);
    s(3) = size(imgbuf1,3);
    assert(all(size(imgbuf1) == size(imgbuf2)) && all(size(imgbuf1) == size(imgbuf3)) && all(size(imgbuf1) == size(imgbuf4)), ...
        'makeSubimg3: Size of imgbuf is not EQUAL!');
    
    %calculate detectCnt
    detectCnt = sum(cellfun(@(a)size(a,1), detectResult));
    
    subimgbuf = zeros(subimgsize,subimgsize,10,detectCnt);
    subimginfo = zeros(detectCnt, 3);%[x y frame]

    windowsize = round((subimgsize-1)/2);

    disp('Make sub imges ..');

    subimgcnt = 0;
    for m=1:len(detectResult)
        temp = round(detectResult{m});%[x y ~]
        tlen = size(temp,1);
        for n=1:tlen
            tx = temp(n,1);
            ty = temp(n,2);
            xs = tx - windowsize;
            xe = tx + windowsize;
            ys = ty - windowsize;
            ye = ty + windowsize;
            if xs>0 && ys >0 && xe<=s(2) && ye<=s(1)
                subimgcnt = subimgcnt +1;
                subimgbuf(:,:,1,subimgcnt) = imgbuf1(ys:ye, xs:xe, m);
                subimgbuf(:,:,2,subimgcnt) = imgbuf2(ys:ye, xs:xe, m);
                subimgbuf(:,:,3,subimgcnt) = imgbuf3(ys:ye, xs:xe, m);
                subimgbuf(:,:,4,subimgcnt) = imgbuf4(ys:ye, xs:xe, m);
                subimgbuf(:,:,5,subimgcnt) = imgbuf5(ys:ye, xs:xe, m);
                subimgbuf(:,:,6,subimgcnt) = imgbuf6(ys:ye, xs:xe, m);
                subimgbuf(:,:,7,subimgcnt) = imgbuf7(ys:ye, xs:xe, m);
                subimgbuf(:,:,8,subimgcnt) = imgbuf8(ys:ye, xs:xe, m);
                subimgbuf(:,:,9,subimgcnt) = imgbuf9(ys:ye, xs:xe, m);
                subimgbuf(:,:,10,subimgcnt) = imgbuf10(ys:ye, xs:xe, m);
                subimginfo(subimgcnt,:) = [tx ty m];
            end
        end
    end

    subimgbuf = subimgbuf(:,:,:,1:subimgcnt);
    subimginfo = subimginfo(1:subimgcnt,:);
end