function [segbuf, trace, intlistbuf] = calImagePeakCurve(pzimg)
    % find max for starting point
    s = size(pzimg);
    t = find(pzimg == max(pzimg(:)));
    [y0, x0] = ind2sub(s, t(1));
    initdir = -90/180*pi;
    %search two directions
    %forward
    [trace1, intlistbuf1] = calImagePeakCurve_half(pzimg, x0, y0, initdir);
    %backward
    [trace2, intlistbuf2] = calImagePeakCurve_half(pzimg, x0, y0, -initdir);
    
    trace1 = round(trace1(1:end-1,:));
    trace2 = round(trace2(2:end-1,:));
    
    tr = cat(1, trace2(end:-1:1,:), trace1);
    tr = tr(3:end-2,:); %remove head and tail
    
    trlen = size(tr,1);
    pzs = size(pzimg);
   %% interp input points [current-point next-point)
    tr_interp = zeros(0,2);
    for m=1:(trlen-1)
        cx = tr(m,1);
        cy = tr(m,2);
        nx = tr(m+1,1);
        ny = tr(m+1,2);
        if cy < ny
            % wrap1 cy -> 1
            tylist = cy : -5: 1;
            tylist = tylist';
            txlist = ones(size(tylist)) * cx;
            tr_interp = cat(1, tr_interp, [txlist tylist]);
            % wrap2 height -> ny
            tylist = pzs(1) : -5: ny;
            tylist = tylist';
            txlist = ones(size(tylist)) * nx;
            tr_interp = cat(1, tr_interp, [txlist tylist]);
        else
            %normal
            tylist = cy : -5: ny;
            tylist = tylist(1:end-1);
            tylist = tylist';
            txlist = round(interp1([cy, ny], [cx,nx], tylist));
            tr_interp = cat(1, tr_interp, [txlist tylist]);
        end
    end

    %add last point
    tr_interp = cat(1, tr_interp, [nx ny]);


    %% refine input points
    searchlenx = 4; % -4pix ~ 4 pix in x
    searchleny = 1; % -2pix ~ 2 pix in y (cum)
    resulttr = tr_interp;
    for m=1:trlen
        cx = tr_interp(m,1);
        cy = tr_interp(m,2);
        xs = cx - searchlenx;
        xe = cx + searchlenx;
        ys = cy - searchleny;
        ye = cy + searchleny;

        %check validate
        if xs<1
            xs=1;
        end
        if ys<1
            ys=1;
        end
        if xe > pzs(2)
            xe = pzs(2);
        end
        if ye > pzs(1)
            ye = pzs(1);
        end

        timg = pzimg(ys:ye, xs:xe);
        timg2 = sum(timg, 1);
        tpos = mean(find(timg2 == max(timg2(:))));

        resulttr(m,1) = xs + tpos -1;
    end
    
    %% merge trace
    
    trace = resulttr;
    [segresult1, seglen1] = segTrace(trace, -1, s(1));
    
    %merge results
%     trace = cat(1,trace1, trace2);
    intlistbuf = [];
    
    %% merge seg
    segnum = seglen1;
    segbuf = cell(segnum, 1);
    tcnt = 1;
    %after 0
    for m=1:seglen1
        tseg = segresult1(m,:);
        ts = tseg(1);
        te = tseg(2);
        segbuf{tcnt} = trace(ts:te,:);
        tcnt = tcnt+1;
    end
end
