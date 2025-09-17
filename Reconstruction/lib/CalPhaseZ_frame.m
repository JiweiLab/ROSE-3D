function result = CalPhaseZ_frame(lp, z, f)
%lp: (theta, cycle, phase)
cycle = lp(f,1);
phase = lp(f,2);

ret = z .* cycle + phase;
result = checkPhase(ret);
end