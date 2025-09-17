function [segresult, seglen] = segTrace(trace, segidxdir, cycle)
    dp = diff(trace(:,2));
    p = find(abs(dp)>cycle/2);
    seglen = len(p)+1;
    if seglen ==1
        segresult = [1, size(trace,1), 0];
    else
        segresult = zeros(seglen, 3); %start, end, idx
        segidx = 0;
        for m=1:seglen
            if m==1
                ts = 1;
                te = p(m);
            elseif m==seglen
                ts = p(m-1)+1;
                te = size(trace,1);
            else
                ts = p(m-1)+1;
                te = p(m);
            end
            segresult(m,:) = [ts, te, segidx];
            segidx = segidx + segidxdir;
        end
    end
end