function [lblmap, bndmap] = getBndmap(segbuf, s)
%% make bound mark
bndmap = zeros(s);
bndmark = 1;
seglen = length(segbuf);

overlapflag = 1;
if seglen <2
    overlapflag = 0;
elseif seglen ==2
    t1 = segbuf{1};
    t2 = segbuf{2};
    if max(t1(:,2)) < min(t2(:,2))
        overlapflag = 0;
    end
end

if overlapflag>0
    for m=1:(seglen-1)
        [ret1, ret2] = getSegBound(segbuf{m}, segbuf{m+1}, s, m==1, m==(seglen-1));
        for n=1:size(ret1,1)
            tx = round(ret1(n,1));
            ty = round(ret1(n,2));
            if tx>0 && ty>0 && tx<=s(2) && ty<=s(1)
                bndmap(ty,tx) = bndmark;
            end
        end

        for n=1:size(ret2,1)
            tx = round(ret2(n,1));
            ty = round(ret2(n,2));
            if tx>0 && ty>0 && tx<=s(2) && ty<=s(1)
                bndmap(ty,tx) = bndmark;
            end
        end
    end
else
    for m=1:seglen
        singleSegWidth = 15;
        [ret1] = getSegBound_single(segbuf{m}, s, singleSegWidth);
        for n=1:size(ret1,1)
            tx = round(ret1(n,1));
            ty = round(ret1(n,2));
            if tx>0 && ty>0 && tx<=s(2) && ty<=s(1)
                bndmap(ty,tx) = bndmark;
            end
        end
    end
end

bndmap = imdilate(bndmap==bndmark, strel('disk',1));
bndmap = bndmap.*bndmark;

lblmap = bwlabel(bndmap ~= bndmark);
