function [ret1, ret2] = getSegBound(trace1, trace2, s, isstart, isend)
    t1 = interpTrace(trace1, s);
    t2 = interpTrace(trace2, s);

   %% find segment line
    gap = 0.05; %5% for gap
    yrange1 = [min(t1(:,2)), max(t1(:,2))];
    yrange2 = [min(t2(:,2)), max(t2(:,2))];
    yrange = [max(yrange1(1), yrange2(1)), min(yrange1(2), yrange2(2))];

    ret1 = zeros(0,2);
    ret2 = zeros(0,2);

    if yrange(1)>1 && yrange(2)<s(1)
        pairflag = 1; %flag that is a pair trace 两个重叠路径
    else
        pairflag = 0;
    end

    %deal ymin-ymax
    tlen = yrange(2) - yrange(1)+1;
    temptrace1a = zeros(tlen, 2); %x1, y1
    temptrace2a = zeros(tlen, 2); %x2, y2
    temptrace1ap = zeros(tlen, 2); %x1, y1
    temptrace2ap = zeros(tlen, 2); %x2, y2
    wlist = zeros(tlen, 1); %record of the width
    ylist = yrange(1):yrange(2);
    ylen = length(ylist);
    for m=1:ylen
        cy = ylist(m);
        tidx1 = find(t1(:,2) == cy);
        tidx1 = tidx1(1);
        cx1 = t1(tidx1,1);
        tidx2 = find(t2(:,2) == cy);
        tidx2 = tidx2(1);
        cx2 = t2(tidx2,1);
        dx = (cx2 - cx1) * (1-gap) /2;
        tx1 = cx1 + dx;
        tx2 = cx2 - dx;
        temptrace1a(m,:) = [tx1, cy];
        temptrace2a(m,:) = [tx2, cy];
        temptrace1ap(m,:) = [cx1 - dx, cy];
        temptrace2ap(m,:) = [cx2 + dx, cy];
        wlist(m) = dx;
    end
    ret1 = cat(1, ret1, temptrace1a);
    ret2 = cat(1, ret2, temptrace2a);
    if isstart>0
        ret1 = cat(1,ret1,temptrace1ap);
    end
    if isend>0
        ret2 = cat(1,ret2,temptrace2ap);
    end

    %deal 1 ~ ymin
    if yrange(1) > 1
        %trace 1, constant width
        ylist = 1:(yrange(1)-1);
        dx = wlist(1);
        tlen = length(ylist);
        temptrace1b = zeros(tlen, 2); %x2, y2
        temptrace1bp = zeros(tlen, 2);
        for m=1:tlen
            cy = ylist(m);
            tidx1 = find(t1(:,2) == cy);
            tidx1 = tidx1(1);
            cx1 = t1(tidx1,1);
            tx1 = cx1 + dx;
            temptrace1b(m,:) = [tx1, cy];
            temptrace1bp(m,:) = [cx1 - dx, cy];
        end
        if isstart>0
            temptrace1b = cat(1,temptrace1b,temptrace1bp);
        end

        %trace2, end
        ylist = yrange(1):yrange(2);
        tlen = length(ylist);
        temptrace2b = zeros(tlen, 2); %x1, y1
        for m=1:ylen
            cy = ylist(m);
            tidx2 = find(t2(:,2) == cy);
            tidx2 = tidx2(1);
            cx2 = t2(tidx2,1);
            dx = wlist(m);
            tx2 = cx2 + dx;
            temptrace2b(m,:) = [tx2, cy];
        end
        %简单封口
        txlist = temptrace2a(1,1) : temptrace2b(1,1);
        txlist = txlist';
        tylist = ones(size(txlist)).*yrange(1);
        temptrace2b = cat(1, temptrace2b, [txlist,tylist]);

        ret1 = cat(1, ret1, temptrace1b);
        ret2 = cat(1, ret2, temptrace2b);
    end

    %del ymax ~ s
    if yrange(2) < s(1)
        %trace1, end
        ylist = yrange(1):yrange(2);
        tlen = length(ylist);
        temptrace1c = zeros(tlen, 2); %x1, y1
        for m=1:ylen
            cy = ylist(m);
            tidx1 = find(t1(:,2) == cy);
            tidx1 = tidx1(1);
            cx1 = t1(tidx1,1);
            dx = wlist(m);
            tx1 = cx1 - dx;
            temptrace1c(m,:) = [tx1, cy];
        end
        %简单封口
        txlist = (cx1 - dx) : (cx1 + dx);
        txlist = txlist';
        tylist = ones(size(txlist)).*cy;
        temptrace1c = cat(1, temptrace1c, [txlist,tylist]);

        %trace 2, constant width
        ylist = yrange(2)+1 : s(1);
        dx = wlist(end);
        tlen = length(ylist);
        temptrace2c = zeros(tlen, 2); %x2, y2
        temptrace2cp = zeros(tlen, 2); %x2, y2
        for m=1:tlen
            cy = ylist(m);
            tidx2 = find(t2(:,2) == cy);
            tidx2 = tidx2(1);
            cx2 = t2(tidx2,1);
            tx2 = cx2 - dx;
            temptrace2c(m,:) = [tx2, cy];
            temptrace2cp(m,:) = [cx2 + dx, cy];
        end
        if isend>0
            temptrace2c = cat(1,temptrace2c,temptrace2cp);
        end

        ret1 = cat(1, ret1, temptrace1c);
        ret2 = cat(1, ret2, temptrace2c);
    end
end