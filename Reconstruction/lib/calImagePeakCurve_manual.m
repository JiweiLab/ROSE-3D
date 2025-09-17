function [segbuf, trace, intlistbuf] = calImagePeakCurve_manual(pzimg)
    % find max for starting point
    s = size(pzimg);
    t = find(pzimg == max(pzimg(:)));
    [y0, x0] = ind2sub(s, t(1));
    initdir = -90/180*pi;
    %get pzimg trace BY HAND
    [trace] = getImagePeakCurveManual(pzimg);
    
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

