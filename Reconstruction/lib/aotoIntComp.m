function [resultphase, resultamp, resultoffset] = aotoIntComp(intlist, x, y)

%% select the phase and int
% cphase = phase1;
% intlist = intlist(smInfo(:,11),1:3);
% x = smInfo(:,1);
% y = smInfo(:,2);
margin = 30; %pixel
destcnt = 50000; % sample count for fitting

xmin = min(x);
xmax = max(x);
ymin = min(y);
ymax = max(y);

[xx, yy] = meshgrid( (xmin+margin/2) : margin: (xmax-margin/2), ...
   (ymin+margin/2) : margin: (ymax-margin/2) );

xxlist = xx(:);
yylist = yy(:);
xxlen = len(xxlist);
parlist = zeros(xxlen, 4); %[poffset1, poffset2, intcomp1, intcomp2]

for m=1:xxlen
    cx = xxlist(m);
    cy = yylist(m);
    tmask = x> (cx-margin/2) & x < (cx+margin/2) & y> (cy-margin/2) & y < (cy+margin/2);
%     temp = sum(tmask);
    tmask2 = rand(size(tmask)) < (destcnt / sum(tmask)); %reduce sample length
    
    tintlist = intlist(tmask & tmask2, :);
    
    par0 = [120, 120, 1, 1];

    func = @(par)(fitPhaseTest(tintlist, par));

    options = optimset('Display','off','TolFun',1,'TolX', 1);

%     tic
    [par,~] = fminsearch(func, par0, options);
%     toc

%     disp(par)
    
    parlist(m,:) = par;
end

% disp('Done.')

%% phase and int comp
%use global phase offset
phaseOffset1 = median(parlist(:,1));
phaseOffset2 = median(parlist(:,2));

%use local int compensation data
F1 = scatteredInterpolant(xx(:),yy(:),parlist(:,3),'linear','linear');
F2 = scatteredInterpolant(xx(:),yy(:),parlist(:,4),'linear','linear');
intCompList1 = F1(x,y);
intCompList2 = F2(x,y);
% intCompList1 = interp2(xx,yy,reshape(parlist(:,3), size(xx)), x,y);
% intCompList2 = interp2(xx,yy,reshape(parlist(:,4), size(xx)), x,y);

tempintlist = intlist;
tempintlist(:,2) = tempintlist(:,2) .* intCompList1;
tempintlist(:,3) = tempintlist(:,3) .* intCompList2;

[resultphase, resultamp, resultoffset] = MyCalPhase3Ex_list(tempintlist(:,1:3), phaseOffset1/180*pi, -phaseOffset2/180*pi);

end