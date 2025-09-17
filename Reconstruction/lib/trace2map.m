function lblmap = trace2map(segbuf, s)
    segnum = length(segbuf);
    [tlblmap, ~] = getBndmap(segbuf, s);
    lblmap = zeros(s);
    t2lresult = zeros(segnum, 1);
    for m=1:segnum
        ctrace = segbuf{m};
        tx = round(ctrace(:,1));
        ty = round(ctrace(:,2));
        tbuf = zeros(length(tx));
        for n=1:length(tx)
            tbuf(n) = tlblmap(ty(n), tx(n));
        end
        tbuf=round(tbuf(tbuf>0));
        t2lresult(m) = mean(tbuf);

        lblmap(tlblmap == t2lresult(m)) = m;
    end
end