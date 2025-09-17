function [fitresult, smInfo, subimginfo, states, intlist, resultz, zrange, ...
    smInfo_raw, intlist_raw, resultz_raw, smInfomask, ...
    resultzList_raw, dwxy, dwxy_raw] = SMFitting3d10_sepfit( ...
    imgbuf1, imgbuf2,imgbuf3, imgbuf4, imgbuf5, ...
    imgbuf6, imgbuf7, imgbuf8, imgbuf9, imgbuf10, ...
    detfile, opt)
% [fitresult, smInfo] = SMFitting3d(imgbuf1, imgbuf2,imgbuf3, imgbuf4, imgbuf5, ...
%     imgbuf6, imgbuf7, imgbuf8, imgbuf9, ...
%     detfile, opt)
% fitresult:    [x y wx wy int1-9  bkg1-9 exitflag]
%               [1 2  3  4  5-13    14-22    23]
%
%smInfo
%[x y frame ptn phase1  phase2  phase3  md1  md2  md3  idx   ptn1 ptn2 ptn3 ptndemix]
%[1 2   3    4    5       6        7     8    9    10   11    12   13   14   15]
%
% smIntList:[int 1-10]
%
%
% opt:
%     isEM = 1;
%     EMgain = 100;
%     e2cfactorEM = 10.5;
%     e2cfactorConv = 1.85;%e 2 c factor when EM off
%     e2cfactorCMOS         0.23;%electrons/count
%     subimgsize = 7;
%     maxPhoton = 50000;
%     minstd = 0.5;
%     maxstd = 2.5;
subimgsize = 11;
if nargin>=12 && isstruct(opt)  
    %subimgsize
    if isfield(opt, 'subimgsize')
        subimgsize = opt.subimgsize;
    end    
end
%% load detection results
if ischar(detfile)
    tempdata = load(detfile);
    detectResult = tempdata.detectResult;
else
    detectResult = detfile;
end

%% subimg
% [subimgbuf, subimginfo] = makeSubimg4(imgbuf1, imgbuf2, imgbuf3, imgbuf4, detectResult, subimgsize);
[subimgbuf, subimginfo] = makeSubimg10(imgbuf1, imgbuf2, imgbuf3, imgbuf4, imgbuf5, ...
    imgbuf6, imgbuf7, imgbuf8, imgbuf9, imgbuf10, ...
    detectResult, subimgsize);

%% fitting and post process
% [fitresult, smInfo, subimginfo, states, intlist, smInfo_raw, intlist_raw] = ...
%     SMFitting3d10_subimg_sepfit(subimgbuf, subimginfo, opt);

[fitresult, smInfo, subimginfo, states, intlist, resultz, zrange, ...
    smInfo_raw, intlist_raw, resultz_raw, smInfomask, resultzList_raw, dwxy, dwxy_raw] = ...
    SMFitting3d10_subimg_sepfit(subimgbuf, subimginfo, opt);
