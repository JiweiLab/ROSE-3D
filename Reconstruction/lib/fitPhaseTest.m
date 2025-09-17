function result = fitPhaseTest(intlist, par)
%par: [phase1, phase2, intcomp1, intcomp2]
phaseoffset1 = par(1);
phaseoffset2 = par(2);
intcomp1 = par(3);
intcomp2 = par(4);
intlist(:,2) = intlist(:,2) .* intcomp1;
intlist(:,3) = intlist(:,3) .* intcomp2;
[tp, ~, ~] = MyCalPhase3Ex_list(intlist, phaseoffset1/180*pi, -phaseoffset2/180*pi);
[a , ~] = hist(tp, 100);
result = std(a);
