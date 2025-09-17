
% -------------------------------------------------------------------------
% Matlab version of 3D redundant drift correction method
% Input:    coords:             localization coordinates [x y z frame], 
%           segpara:            segmentation parameters (time wimdow, frame)
%           imsize:             image size (pixel)
%           pixelsize:          camera pixel size (nm)
%           binsize:            spatial bin pixel size (nm)
%           rmax:               error threshold for re-calculate the drift (pixel)
% Output:   coordscorr:         localization coordinates after correction [xc yc] 
%           finaldrift:         drift curve (save A and b matrix for other analysis)
% By Yina Wang @ Hust 2013.09.09
% -------------------------------------------------------------------------
% modified by lusheng Gu 2020.8

function [coordscorr, finaldrift, A, b, rowerr] = RCC_mod_3D_GPU(coords, segframe, zoom, binz, rmax)
% coords = plist;
% segframe = 200;
% zoom = 15;
% binz = 10;
% rmax = 0.5;

nframe = max(coords(:,4));
%% make drift matrix
nseg = ceil(nframe/segframe);

npair = nseg*(nseg-1)/2;
pairlist = zeros(npair,2);
pairlist_autoidx = zeros(npair, 1);
pairlist_auto = [(1:nseg)', (1:nseg)'];

paircnt = 0;
for m=1:(nseg-1)
    for n=(m+1):nseg
        paircnt = paircnt +1;
        pairlist(paircnt,:) = [m,n];
        pairlist_autoidx(paircnt) = m;
    end
end
pairlist = pairlist(1:paircnt,:);
pairlist_autoidx = pairlist_autoidx(1:paircnt);

%cal image size
imgsize = max(max(coords(:,1)),max(coords(:,2)))+5;

[binmap, pselist] = makeDistHist3D(coords, segframe, pairlist, imgsize, zoom, binz, 20);
[binmap_auto, pselist_auto] = makeDistHist3D(coords, segframe, pairlist_auto, imgsize, zoom, binz, 20);

%% gpu fit
bmaps = size(binmap);
subimgbuf = single(reshape(binmap,[bmaps(1)*bmaps(2), bmaps(3)*bmaps(4)]));
subimglen = bmaps(3)*bmaps(4);

%fit subimages for xcorr
%parameter:
%[amp, x, y, ws, wy, offset]
initpar = zeros(6, subimglen);
initpar(1,:) = max(subimgbuf,[],1) - min(subimgbuf,[],1);
initpar(2,:) = bmaps(1)/2-1;
initpar(3,:) = bmaps(1)/2-1;
initpar(4,:) = 2;
initpar(5,:) = 2;
initpar(6,:) = min(subimgbuf,[],1);
[par_lse] = gpufitEx(subimgbuf, ModelID.GAUSS_2D_ELLIPTIC, initpar, 'est_id', EstimatorID.LSE);
[par_mle] = gpufitEx(subimgbuf, ModelID.GAUSS_2D_ELLIPTIC, par_lse, 'est_id', EstimatorID.MLE);

bmaps_auto = size(binmap_auto);
subimgbuf = single(reshape(binmap_auto,[bmaps_auto(1)*bmaps_auto(2), bmaps_auto(3)*bmaps_auto(4)]));
subimglen = bmaps_auto(3)*bmaps_auto(4);
%fit subimages for autocorr
%parameter:
%[amp, x, y, ws, wy, offset]
initpar = zeros(6, subimglen);
initpar(1,:) = max(subimgbuf,[],1) - min(subimgbuf,[],1);
initpar(2,:) = bmaps(1)/2-1;
initpar(3,:) = bmaps(1)/2-1;
initpar(4,:) = 2;
initpar(5,:) = 2;
initpar(6,:) = min(subimgbuf,[],1);
[par_lse] = gpufitEx(subimgbuf, ModelID.GAUSS_2D_ELLIPTIC, initpar, 'est_id', EstimatorID.LSE);
[par_mle_auto] = gpufitEx(subimgbuf, ModelID.GAUSS_2D_ELLIPTIC, par_lse, 'est_id', EstimatorID.MLE);

%% cal drift
% order: 1:x,y; 2:x,z; 3: y,z
driftlist_raw = reshape(par_mle(2:3,:), [2,npair,3]);
driftlistauto_raw = reshape(par_mle_auto(2:3,:), [2,nseg,3]);
driftlist = driftlist_raw - driftlistauto_raw(:,pairlist_autoidx,:);
driftx = (driftlist(1,:,1) + driftlist(1,:,2))/2;
drifty = (driftlist(2,:,1) + driftlist(1,:,3))/2;
driftz = (driftlist(2,:,2) + driftlist(2,:,3))/2;
%flip direction
% driftx = -driftx;
% drifty = -drifty;
% driftz = -driftz;

% make mat A and imshift
% A: npair * nseg-1
% imshift: npair * 3
% driftmat = nseg-1 * 3
% imshift = A * driftmat
imshift = [driftx', drifty', driftz']; % shifts between any two bin steps in x and y direction
A = zeros(npair, nseg-1); %set equations

p=0;
for m=1:(nseg-1)
    for n=(m+1):nseg
        p=p+1;
        A(p,m:n-1) = 1;
    end
end

%% solve overdetermined equations and refine the calculated drift
tm = abs(imshift(:,1))<rmax*zoom & abs(imshift(:,2))<rmax*zoom & abs(imshift(:,3))<rmax*zoom;
A = A(tm,:);
b = imshift(tm,:);
drift = pinv(A)*b;
err = A*drift-b;

%% drop too large errors
% b=imshift;
rowerr = sqrt(err(:,1).^2 + err(:,2).^2 + err(:,3).^2);

% rowerr(:,2)=1:1:nbinframe*(nbinframe-1)/2;
% rowerr=flipud(sortrows(rowerr,1));
% clear index
% index=rowerr(rowerr(:,1)>rmax*zoomfactor,2);
% for i=1:size(index,1)
%     flag = index(i);
%     tmp=A;
%     tmp(flag,:)=[];
%     if rank(tmp,1)==(nbinframe-1)
%         A(flag,:)=[];
%         b(flag,:)=[];
%         sindex=find(index>flag);
%         index(sindex)=index(sindex)-1;
%     else
%         tmp=A;
%     end
% end
rowmask = rowerr <= rmax*zoom;
A = A(rowmask,:);
b = b(rowmask,:);

drift1 = pinv(A)*b;

drift = cumsum(drift1, 1);

%% drift interpolation
indexinterp=zeros(nseg+1,1);
indexinterp(1)=1;
indexinterp(2:nseg+1)=round(segframe/2):segframe:segframe*nseg-1;
indexinterp(nseg+1)=nframe;

finaldrift(:,1) = interp1(indexinterp,[0 drift(:,1)' drift(nseg-1,1)],1:nframe,'spline');
finaldrift(:,2) = interp1(indexinterp,[0 drift(:,2)' drift(nseg-1,2)],1:nframe,'spline');
finaldrift(:,3) = interp1(indexinterp,[0 drift(:,3)' drift(nseg-1,3)],1:nframe,'spline');
finaldrift(:,1:2) = finaldrift(:,1:2)./zoom;
finaldrift(:,3) = finaldrift(:,3).*binz;
% make corrected coords
coordscorr = coords;
coordscorr(:,1) = coordscorr(:,1) - finaldrift(coordscorr(:,4),1);
coordscorr(:,2) = coordscorr(:,2) - finaldrift(coordscorr(:,4),2);
coordscorr(:,3) = coordscorr(:,3) - finaldrift(coordscorr(:,4),3);

end