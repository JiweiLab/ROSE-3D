filename = '..\data-100\spool_A_MMStack_Pos0.ome.tif';

saveSubImages=0;
multicolorFlag = 1; %2 for 660&647; 3 for 647,660&680

%detection parameter
detThreshold = 3;

%make opt
opt = [];
opt.detThreshold = detThreshold;
opt.autoskip = 1; %do NOT skip exist results if set to 0
opt.substractBkg = 0;%substrack background
opt.doIntComp = 1; % int compensation
opt.multicolorFlag = multicolorFlag; % int compensation

imgpath_prefix = filename(1:end-4);

filelist = getFileList_Fusion_2cam(filename);
filecnt = len(filelist);
%% Process files and save fitting results
for m=1:filecnt
    disp(sprintf('Processing File: %s (%d/%d)', filelist{m}, m, filecnt));
    ProcessImgFile3d10_sepfit(filelist{m}, opt)
end

%% merge fitting results
    % fitresult:    [x y wx wy int1-9  bkg1-9 exitflag]
    %               [1 2  3  4  5-13    14-22    23]
    %
    %smInfo
    %[x y frame ptn phase1  phase2  phase3  md1  md2  md3  idx   ptn1 ptn2 ptn3 ptndemix]
    %[1 2   3    4    5       6        7     8    9    10   11    12   13   14   15]

fitresult = zeros(0,42);
smInfo = zeros(0,15);
smIntList = zeros(0,10);
cframe = 0;
cidx = 0;
zdata = [];
zrange = [];

for m=1:filecnt
    
    tdata = load([filelist{m}(1:end-4) '_fitting_sepfit.mat']);
    tfitresult = tdata.fitresult;
    tsmInfo = tdata.smInfo;
    tsmIntList = tdata.smIntList;
    tresultz = tdata.resultz;
    tzrange = tdata.zrange;
    
    % change frame, idx
    tsmInfo(:,3) = tsmInfo(:,3) + cframe;
    tsmInfo(:,11) = tsmInfo(:,11) + cidx;
    
    % merge results
    fitresult = cat(1, fitresult, tfitresult);
    smInfo = cat(1, smInfo, tsmInfo);
    smIntList = cat(1, smIntList, tsmIntList);
    zdata = cat(1, zdata, tresultz);
    if m==1
        zrange = tzrange;
    else
        zrange = [min(zrange(1), tzrange(1)), max(zrange(2), tzrange(2))];
    end
    
    %update cframe and cidx
    if isfield(tdata, 'imgsize')
        tsize = tdata.imgsize;
        cimglen = tsize(3);
    else
        cimglen = getImgLen(filelist{m});
    end
    
    cframe = cframe + cimglen;
    cidx = cidx + size(tfitresult, 1);
    
    disp(sprintf('Merging File: %s, %d frames, %d molecules', filelist{m},cimglen,size(tfitresult, 1) ));
end

%% save the results

save([imgpath_prefix '_fitresult_sepfit.mat'], ...
    'filename','fitresult','smInfo','opt','filelist','multicolorFlag', 'smIntList', ...
    'zdata','zrange' ...
    ,'-v7.3');

%% display smInfo
mask = smInfo(:,11);
th = figure(1);
subplot(2,3,1);
hist(smInfo(:,4),100);
title(sprintf('Photons, %d, %d', round(mean(smInfo(:,4))), round(median(smInfo(:,4)))));

subplot(2,3,2);
hist(smInfo(:,8:10),100);
title(sprintf('MD mean:%0.2f, %0.2f, %0.2f, std = %0.2f, %0.2f, %0.2f',...
    mean(smInfo(:,8)), mean(smInfo(:,9)),mean(smInfo(:,10)), ...
    std(smInfo(:,8)), std(smInfo(:,9)), std(smInfo(:,10)) ));

subplot(2,3,3);
hist(fitresult(mask,3)./fitresult(mask,4),100);
title('wxyRatio');

subplot(2,3,4);
hist(zdata,100);
title('z');

subplot(2,3,5);
temp = smInfo(:,12)./smInfo(:,13);
tm = temp>0 & temp<2;
hist(temp(tm), 100)
title('Int ratio 1-2');

subplot(2,3,6);
temp = smInfo(:,12)./smInfo(:,14);
tm = temp>0 & temp<2;
hist(temp(tm), 100)
title('Int ratio 1-3');

saveFigure(th, [filename(1:end-4) '_fitresult.png']);

% gen preview image
% timg = PointSet2Image(smInfo(:,1),smInfo(:,2), 8);
% tiffwrite(uint16(timg),[filename(1:end-4) '_Preview_8X.tif']);

%% do post processing
run_PostProcess_3D_sepfit
