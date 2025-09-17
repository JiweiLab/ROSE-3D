function [phase, amp, offset] = MyCalPhase3Ex(intlist, p1, p2)
k = (intlist(2)-intlist(1))/(intlist(3)-intlist(1));
tana = (k*sin(p2)-sin(p1)) / (cos(p1)-1-k*(cos(p2)-1));
phase = atan(tana);
if abs(intlist(2)-intlist(1)) > abs(intlist(3)-intlist(1)) %use I2-I1
    if (sin(phase+p1) - sin(phase))*(intlist(2)-intlist(1))<0
        phase=phase+pi;
    end
else %use I3-I1
    if (sin(phase+p2) - sin(phase))*(intlist(3)-intlist(1))<0
        phase=phase+pi;
    end
end
amp = (intlist(2)-intlist(1))/(sin(phase+p1) - sin(phase));
offset = intlist(1) - amp*sin(phase);
