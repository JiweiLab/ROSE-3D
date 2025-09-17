function result = CalPhase_xyzcomp(lp, x, y, z, Pxyz)
%lp: (theta, cycle, phase)
theta = lp(1);
cycle = lp(2);
phase = lp(3);

ret = (x.*cos(theta) + y.*sin(theta)) * cycle + Pxyz;
result = checkPhase(ret);
end