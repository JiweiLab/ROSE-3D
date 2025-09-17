function [lp1, lp2, resultp1, resultp2, resultx, resulty, resultdx, resultdy, A] ...
    = CalculatePhaseAndFineXY_3d_Tcomp(x, y, p1, p2, fdata, samplelength)
%% Calculate phase plane and  calculate the fine coordinates X and Y
%data : x y p1 p2
%results: lp1, lp2, resultp1, resultp2, resultx, resulty, 
%         resultdx, resultdy
%parameters: samplelength
% x = smInfo(:,1);
% y = smInfo(:,2);
% p1 = smInfo(:,13);
% p2 = smInfo(:,14);

if nargin < 6 || isempty(samplelength)
    samplelength = 5000;
end

%% fitting phase plane
disp('Fitting Phase Plane 1 ..');
% [lp1, resultp1] = SearchPhasePlane6(x,y,p1,samplelength,[1.55 1.65]);
[lp1, resultp1] = SearchPhasePlane6_Tcomp(x,y,p1,fdata,samplelength,[1.55 1.65]);
title('Fitting P1');

disp('Fitting Phase Plane 2 ..');
% [lp2, resultp2] = SearchPhasePlane6(x,y,p2,samplelength,[-0.05 0.05]);%[-1.7 -1.4] for EM, [1.4 1.6] for Conventional
[lp2, resultp2] = SearchPhasePlane6_Tcomp(x,y,p2,fdata,samplelength,[-0.1 0.05]);
title('Fitting P2');

drawnow

%% calculate fine X and Y
dp1 = checkPhase(resultp1 - p1);
dp2 = checkPhase(resultp2 - p2);
a1 = lp1(1);
b1 = lp1(2);
a2 = lp2(1);
b2 = lp2(2);
A = [b1*cos(a1), b1*sin(a1); b2*cos(a2), b2*sin(a2)];
B = [dp1, dp2];
% iA = inv(A);
% x * A = B   =>   x = B * inv(A) = B/A
resX = B/A;
resultdx = resX(:,1);
resultdy = resX(:,2);
resultx = x - resultdx;
resulty = y - resultdy;

