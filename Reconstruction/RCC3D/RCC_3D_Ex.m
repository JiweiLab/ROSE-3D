% RCC 3D drift correction, with segmented calculation for large dataset
function [coordscorr, finaldrift, seginfo, driftbuf] = RCC_3D_Ex(coords, segframe, zoom, binz, rmax, pmax)
if nargin<6
    pmax = 5e6; %5M points 
end
plen = size(coords, 1);
pstep = pmax/2; %make large margin
nseg = max(0, ceil((plen-pmax)/pstep))+1;

seginfo = zeros(nseg,4);%[fs,fe, ps, pe]
driftbuf = cell(nseg,3);% [driftx, drifty, driftz]
for m=1:nseg
    ps = 1 + (m-1)*pstep;
    pe = min((ps + pmax -1), plen);
    tempcoords = coords(ps:pe,:);
    fs = tempcoords(1,4);
    fe = tempcoords(end,4);
    tempcoords(:,4) = tempcoords(:,4) - fs+1;
    disp(sprintf('seg %d/%d: frame:%d ~ %d, point: %d ~ %d',m,nseg,fs,fe,ps,pe));
    [tcoordscorr, tfinaldrift, A, b, rowerr] = RCC_mod_3D_GPU(tempcoords, segframe, zoom, binz, rmax);
    seginfo(m,1) = fs;
    seginfo(m,2) = fe;
    seginfo(m,3) = ps;
    seginfo(m,4) = pe;
    driftbuf{m,1} = tfinaldrift(:,1);
    driftbuf{m,2} = tfinaldrift(:,2);
    driftbuf{m,3} = tfinaldrift(:,3);
end

% merge segments
if size(driftbuf,1)>1
    [driftx, ~] = mergeTrace(driftbuf(:,1), seginfo(:,1:2));
    [drifty, ~] = mergeTrace(driftbuf(:,2), seginfo(:,1:2));
    [driftz, ~] = mergeTrace(driftbuf(:,3), seginfo(:,1:2));
else
    driftx = driftbuf{1};
    drifty = driftbuf{2};
    driftz = driftbuf{3};
end
finaldrift = cat(2, driftx, drifty, driftz);

% correction
coordscorr = coords;
coordscorr(:,1) = coordscorr(:,1) - driftx(coordscorr(:,4));
coordscorr(:,2) = coordscorr(:,2) - drifty(coordscorr(:,4));
coordscorr(:,3) = coordscorr(:,3) - driftz(coordscorr(:,4));
end