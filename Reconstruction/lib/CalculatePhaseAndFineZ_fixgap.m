function [resultz, resultdz, resultzrange] = CalculatePhaseAndFineZ_fixgap(x, y, z, frame, phase, filename, fitorder)
% fit phase with XY, Z-poly and T

% parameters:
figure_flag = 1; %output result for diagnose
savefig_flag = 1; %save figure
trace_manual = 0;
if nargin <7
    fitorder = 2; %XY-Phase fit order, 1 or 2
end
% make data
% xdata = smInfo(:,1);
% ydata = smInfo(:,2);
% fdata = smInfo(:,3);
% pdata = smInfo(:,6);
xdata = x;
ydata = y;
fdata = frame;
pdata = phase;
%-------- INVERT PHASE ------------%
pdata = -pdata;
% zdata = smInfo(:,1);

%randomize the zdata!
zdata_r = z + rand(size(z));

flag_doXYCorr = 1;
flag_doTCorr = 1;

%% step1£º XY + p -> p_corr1
% correct the lateral phase drift with PLANE fitting
% data in xdata, ydata, fdata, pdata, zdata
xycorr_framerange = 2000; % frames for xy-corr calculation
fmask = fdata < xycorr_framerange; % time-mask 

xycorr_xyrange = [0 0 240 240]; %[xstart, ystart, xend, yend] in pixel
xystep = 30; %step size in pixel
xymargin = 0; % overlaped size
xyhstep = xystep/2+xymargin; % region half size

xs = xycorr_xyrange(1);
ys = xycorr_xyrange(2);
xe = xycorr_xyrange(3);
ye = xycorr_xyrange(4);
[xx, yy] = meshgrid(xs:xystep:xe, ys:xystep:ye);
sxx = size(xx);
xx=xx(:);
yy=yy(:);
testlen = len(xx);

% cal each region
pcntlist = zeros(testlen, 1);
pzimgbuf = cell(testlen, 1);
zlist = 0:10:1500;
zrange = [0 1500];
zoomz = 0.1;
zoomp = 40;
convsize = 3; % smooth the pzimage

for m=1:testlen
    cx = xx(m);
    cy = yy(m);
    cxs = cx - xyhstep;
    cxe = cx + xyhstep;
    cys = cy - xyhstep;
    cye = cy + xyhstep;
    
    tmask = xdata>cxs & xdata<cxe & ydata>cys & ydata<cye & fmask;
%     [rzlist, rplist, rpcntlist, rawdata] = calPhasePeakCurve(zdata(tmask), pdata(tmask), zlist);
    [img, funcz, funcp] = phaseZ2Image(zdata_r(tmask), pdata(tmask), zoomz, zoomp, zrange);
    pzimgbuf{m} = conv2(img, ones(convsize,convsize)/(convsize*convsize));
    pcntlist(m) = sum(tmask);
end

% choose the start point
% choose the center!
startIdx = (len(xx)+1)/2;
sx = xx(startIdx);
sy = yy(startIdx);
dlist = (xx-sx).^2 + (yy-sy).^2;
[~, idxlist] = sort(dlist); %index list for align, from center to periphery

% do align
offsetlist = zeros(testlen, 1);
pcntlist = zeros(testlen, 1);
cidx = idxlist(1);
apzimg = pzimgbuf{cidx};

for m=2:testlen
    cidx = idxlist(m);
    cpzimg = pzimgbuf{cidx};
    
    % cal offset
    [center_max, resimg, dlist, conval] = calPZimageDist(apzimg, cpzimg);
    offsetlist(m) = center_max;
    pcntlist(m) = sum(cpzimg(:));
    %merge two tracks
    apzimg = apzimg + resimg;
    
end
toffsetmap=zeros(size(xx));
toffsetmap(idxlist) = offsetlist/zoomp;
tpcntmap=zeros(size(xx));
tpcntmap(idxlist) = pcntlist;

% figure();
% surf(reshape(xx, [9 9]), reshape(yy, [9 9]), reshape(checkPhase(toffsetmap), [9 9]));

% fit XY curve 
toffsetmap_unwrap = myUnwrap2D(reshape(toffsetmap, sxx));
% [resultp, lpxy, resnormx] = fitPhaseXY_bak(xx,yy,toffsetmap_unwrap(:));
% [phasePeakXYFitter, gof] = fitXYPhase_cfit(xx, yy, toffsetmap_unwrap(:));
if fitorder ==2
    [phasePeakXYFitter, gof] = fitXYPlane_wt(xx, yy, toffsetmap_unwrap(:), tpcntmap(:));
elseif fitorder ==1
    [phasePeakXYFitter, gof] = fitXYPlane1D_wt(xx, yy, toffsetmap_unwrap(:), tpcntmap(:));
else
    error('Fitting order error, 1 or 2 needed!');
end

resultp = phasePeakXYFitter(xx,yy);
offsetdata = phasePeakXYFitter(xdata, ydata);
% offsetdata = CalPhaseXY(lpxy, xdata, ydata);
if flag_doXYCorr>0
    disp('skip XY-coorection');
    pdata_corr1 = checkPhase(pdata - offsetdata);
else
    disp('apply XY-coorection');
    pdata_corr1 = checkPhase(pdata);
end

if figure_flag>0
    figure
    subplot(2,2,1);
    plot3(xx,yy,toffsetmap_unwrap(:),'r.','markersize',10);
    hold on
    surf(reshape(xx, [9 9]), reshape(yy, [9 9]), reshape(resultp, [9 9]));
    hold off
    title('XY corr');
end
%% step2: time-corr T+P -> P_corr2
if flag_doTCorr>0 && max(fdata)>500
    [a, b] = hist(zdata_r, 200);
    %don't use edge data!
    a(1)=0;
    a(end)=0;

    temp = find(a>max(a)/3);
    tcorr_zrange = [b(temp(1)) b(temp(end))];
    disp(sprintf('Time_corr zrange: [%0.1f, %0.1f]', tcorr_zrange(1), tcorr_zrange(2)));
    % region = [20 220 20 220 tcorr_zrange(1) tcorr_zrange(2)];
    region = [50 150 50 150 0 1000];

    tm = xdata>region(1) & xdata<region(2) & ydata>region(3) & ydata<region(4) & zdata_r>region(5) & zdata_r<region(6);
    zd = zdata_r(tm);
    pd = pdata_corr1(tm);
    fd = fdata(tm);

    tic
        [resultp, resultdp, resultdrift] = fitPhaseTDrift(zd, pd, fd, 1000);
        [~, ~,lplist2,lplist,reslist, lplist_interp] = fitPhaseStack(zd, pd, fd, 1000, -0.03);
    toc

    % check if max(fd) < max(fdata)
    df = max(fdata) - size(lplist_interp,1);
    if df>0 %extend lplist_interp
        lplist_interp = cat(1, lplist_interp, repmat(lplist_interp(end,:), df,1));
    end

    ptdrift = lplist_interp(fdata,2);
    ptdrift = ptdrift - ptdrift(1);

% if flag_doTCorr>0
    disp('apply T-coorection');
    pdata_corr2 = checkPhase(pdata_corr1 - ptdrift);
    
    if figure_flag>0
        subplot(2,2,2);
    %     plot(lplist_interp(:,2));
        plot(resultdrift);
        title('Time corr');
    end
else
    disp('skip T-coorection');
    pdata_corr2 = checkPhase(pdata_corr1);
end

% if figure_flag>0
%     subplot(2,2,2);
% %     plot(lplist_interp(:,2));
%     plot(resultdrift);
%     title('Time corr');
% end
%% step3: image segmentation and phase unwrap
zoomz = 0.1;
zoomp = 40;
pzimg_smoothlen = 6;
[pzimg, funcz, funcp] = phaseZ2Image(zdata_r, pdata_corr2, zoomz, zoomp, zrange);
pzimg_raw = pzimg;
s = size(pzimg);
pzimg = conv2(pzimg, ones(pzimg_smoothlen,pzimg_smoothlen)/(pzimg_smoothlen*pzimg_smoothlen),'same');
if trace_manual >0
    [segbuf, trace, intlistbuf] = calImagePeakCurve_manual(pzimg);
else
    [segbuf, trace, intlistbuf] = calImagePeakCurve(pzimg);
end

% display
if figure_flag>0
    subplot(2,2,3);
    imagesc(pzimg)
%     colormap gray
    hold on
    plot(trace(:,1), trace(:,2),'r.')
    hold off
end

%% fixed segmentation
lblmap = trace2map(segbuf, s);
% lblmap = imclose(lblmap, strel('disk',4));
if figure_flag>0
    subplot(2,2,4);
    imagesc(lblmap);
end

%% assign phase with phase-Z image
% data in pdata, zdata, lblimg, funcz, funcp
resultz_offset = 50;
s = size(lblmap);
tp = funcp(pdata_corr2);
tz = funcz(z);
tmask = tp>0 & tp<=s(1) & tz>0 & tz<=s(2);
lbllist = lblmap(sub2ind(s, tp(tmask), tz(tmask)));

lblmask = lbllist>0;

resultp = pdata_corr2;
temp = resultp(tmask);

temp(lblmask) = temp(lblmask) + lbllist(lblmask).*-2.*pi;
temp(~lblmask) = nan;
resultp(tmask) = temp;
resultp(~tmask) = nan;

pcycle = 250;
resultp = -resultp; % invert the phase!
resultp = resultp-min(resultp);
resultz = resultz_offset + resultp./2./pi.*pcycle;
resultzrange = [0 ceil((max(resultz)+resultz_offset)/50)*50];

tm = ~isnan(resultz);

% if figure_flag>0
%     subplot(2,2,4);
%     t = find(lblmap<0);
%     [ty, tx] = ind2sub(size(lblmap), t);
%     imagesc(pzimg_raw)
%     hold on
%     plot(tx,ty,'r.')
%     hold off
% end
%% TODO: calculate dz
resultdz = resultz - z;
%% TODO: align resultz to zdata?

%% save result
if savefig_flag>0
    saveFigure(gcf, [filename(1:end-4) '_fitPhase.png']);
end