function result = CalPhaseZ(lp, z)
%lp: (theta, cycle, phase)
cycle = lp(1);
phase = lp(2);

ret = z * cycle + phase;
result = checkPhase(ret);
end