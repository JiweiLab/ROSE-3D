function result = CalPhaseZSin(lp, z)
%lp: (cycle, phase)
cycle = lp(1);
phase = lp(2);

ret = z * cycle + phase;
result = [sin(ret) cos(ret)];


end