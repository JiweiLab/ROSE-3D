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
    
    [segresult1, seglen1] = segTrace(trace1, 1, s(1));
    [segresult2, seglen2] = segTrace(trace2, -1, s(1));
    
    %merge results
    trace = cat(1,trace1, trace2);
    intlistbuf = cat(1, intlistbuf1, intlistbuf2);
    
    %% merge seg
    segnum = seglen1+seglen2-1;
    segbuf = cell(segnum, 1);
    tcnt = 1;
    %before 0
    for m=seglen2:-1:2
        tseg = segresult2(m,:);
        ts = tseg(1);
        te = tseg(2);
        segbuf{tcnt} = flipud(trace2(ts:te,:));
        tcnt = tcnt+1;
    end
    %0
    tseg = segresult1(1,:);
    ts = tseg(1);
    te = tseg(2);
    temp1 = trace1(ts:te,:);
    tseg = segresult2(1,:);
    ts = tseg(1);
    te = tseg(2);
    temp2 = flipud(trace2(ts:te,:));
    segbuf{tcnt} = cat(1, temp2,temp1);
    tcnt = tcnt+1;
    %after 0
    for m=2:seglen1
        tseg = segresult1(m,:);
        ts = tseg(1);
        te = tseg(2);
        segbuf{tcnt} = trace1(ts:te,:);
        tcnt = tcnt+1;
    end
end
