function [phase, amp, offset] = MyCalPhase3Ex_list(intlist, phase1, phase2)

    if nargin <2
        phase1 = 120/180*pi;
    end
    if nargin<3
        phase2 = -phase1;    
    end
    
    intlen = size(intlist,1);
    phase = zeros(intlen,1);
    amp = zeros(intlen,1);
    offset = zeros(intlen,1);
    
    for m=1:intlen
        [tphase, tamp, toffset] = MyCalPhase3Ex(intlist(m,:), phase1, phase2);
        phase(m) = tphase;
        amp(m) = tamp;
        offset(m) = toffset;
    end 
end