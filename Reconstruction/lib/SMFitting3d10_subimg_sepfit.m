function [fitresult, smInfo, subimginfo, states, intlist, resultz, zrange, ...
    smInfo_raw, intlist_raw, resultz_raw, smInfomask, resultzList_raw, dwxy, dwxy_raw] = ...
    SMFitting3d10_subimg_sepfit(subimgbuf, subimginfo, opt)
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
% subimginfo:[x,y,frame]
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

%% init parameters
    isEM = 1;
    EMgain = 100;
    e2cfactorEM = 10.5;
    e2cfactorConv = 1.85;%e 2 c factor when EM off
    e2cfactorCMOS = 0.23;%electrons/count
    subimgsize = 11;
    maxPhoton = 50000;
    minstd = 0.5;
    maxstd = 4.0;
    doIntComp = 1;
    doPZComp = 1; %phase-Z t phase
    doWXYComp = 1; %phase to wxy
    intCompFile = [];
    % md mask
    minmd = 0.4;
    maxmd = 2;
    zcalidata = [];
    % apply options
    if nargin>=3 && isstruct(opt)
        %isEM
        if isfield(opt, 'isEM')
            isEM = opt.isEM;
        end
        %EMgain
        if isfield(opt, 'EMgain')
            EMgain = opt.EMgain;
        end
        %e2cfactorEM
        if isfield(opt, 'e2cfactorEM')
            e2cfactorEM = opt.e2cfactorEM;
        end
        %e2cfactorConv
        if isfield(opt, 'e2cfactorConv')
            e2cfactorConv = opt.e2cfactorConv;
        end
        %e2cfactorCMOS
        if isfield(opt, 'e2cfactorCMOS')
            e2cfactorCMOS = opt.e2cfactorCMOS;
        end
        
        %subimgsize
        if isfield(opt, 'subimgsize')
            subimgsize = opt.subimgsize;
        end
        %maxPhoton
        if isfield(opt, 'maxPhoton')
            maxPhoton = opt.maxPhoton;
        end
        %minstd
        if isfield(opt, 'minstd')
            minstd = opt.minstd;
        end
        %maxstd
        if isfield(opt, 'maxstd')
            maxstd = opt.maxstd;
        end
        %intCompFile
        if isfield(opt, 'intCompFile')
            intCompFile = opt.intCompFile;
        end
        %doIntComp
        if isfield(opt, 'doIntComp')
            doIntComp = opt.doIntComp;
        end
        %minmd
        if isfield(opt, 'minmd')
            minmd = opt.minmd;
        end
        %maxmd
        if isfield(opt, 'maxmd')
            maxmd = opt.maxmd;
        end
        %zcalidata
        if isfield(opt, 'zcalidata')
            zcalidata = opt.zcalidata;
        end
        %doPZComp
        if isfield(opt, 'doPZComp')
            doPZComp = opt.doPZComp;
        end
    end
    
    % if opt is a number then opt -> isEM
    if nargin>=5 && isnumeric(opt)
        isEM = opt;
    end

    s = size(subimgbuf);
    subimglen = s(4);
%% if no subimg info then fill zero
if nargin<2 || isempty(subimginfo)
    subimginfo = zeros(subimglen,3);
elseif size(subimginfo, 1) ==1 && size(subimginfo, 2) ==2 %only give a position
    subimginfo = cat( 2, repmat(subimginfo,subimglen,1), zeros(subimglen,1)); 
end

%% if no img10 then fill with 0
if size(subimgbuf, 3) ==9
    subimgbuf = cat(3, subimgbuf, zeros(s(1),s(2),1,s(4)));
end
%% separate fitting sub images
% fitresult1-3:    [x y wx wy int1-3  bkg1-3 ]
%                  [1 2  3  4  5-7    8-10   ]
[fitresult1, states1] = fitGauss3GPU(subimgbuf(:,:,1:3,:));
[fitresult2, states2] = fitGauss3GPU(subimgbuf(:,:,4:6,:));
[fitresult3, states3] = fitGauss3GPU(subimgbuf(:,:,7:9,:));

% fitresult4:    [x y wx wy int1-3  bkg1-3 ]
%                [1 2  3  4  5-8    9-12   ]
[fitresult4, states4] = fitGauss4GPU_demix(cat(3, sum(subimgbuf(:,:,1:3,:),3), ...
    sum(subimgbuf(:,:,4:6,:),3), sum(subimgbuf(:,:,7:9,:),3), subimgbuf(:,:,10,:)));

states = cat(2, states1', states2', states3', states4');
fitresult = cat(2, fitresult1, fitresult2, fitresult3, fitresult4);



%% post process
%smInfo
%[x y frame ptn phase1  phase2  phase3  md1  md2  md3  idx   ptn1 ptn2 ptn3 ptndemix]
%[1 2   3    4    5       6        7     8    9    10   11    12   13   14   15]
%


phase0 = 120/180*pi;
subimgcnt = size(subimgbuf, 4);

smInfo = zeros(subimgcnt, 15); 
%[x y frame ptn phase1  phase2  phase3  md1  md2  md3  idx   ptn1 ptn2 ptn3 ptndemix]
%[1 2   3    4    5       6        7     8    9    10   11    12   13   14   15]
smInfo(:,1) = (fitresult1(:,1) + fitresult2(:,1) + fitresult3(:,1))/3 + subimginfo(:,1);
smInfo(:,2) = (fitresult1(:,2) + fitresult2(:,2) + fitresult3(:,2))/3 + subimginfo(:,2);
smInfo(:,3) = subimginfo(:,3);

%intensity and phase
intlist_raw = cat(2, fitresult1(:,5:7), fitresult2(:,5:7), fitresult3(:,5:7), fitresult4(:,8));

if doIntComp>0
    disp('Do Intensity Compensation ..')
    if isempty(intCompFile)
        if isfield(opt, 'imgpath')
            intCompFile = [opt.imgpath 'IntComp.mat'];
        end
    end
    intlist = intCompensation(smInfo(:,1), smInfo(:,2), intlist_raw, intCompFile);
else
    disp('NO Intensity Compensation ..')
    intlist = intlist_raw;
end
intlist1 = intlist(:,1:3);
intlist2 = intlist(:,4:6);
intlist3 = intlist(:,7:9);
intlist_demix = intlist(:,10)./sum(intlist(:,1:9), 2);


% phasedata1 = zeros(subimgcnt, 4); %[phase1 md1 amp1 offset1]
[phase1, amp1, offset1] = MyCalPhase3Ex_list(intlist1, phase0);
[phase2, amp2, offset2] = MyCalPhase3Ex_list(intlist2, phase0);
[phase3, amp3, offset3] = MyCalPhase3Ex_list(intlist3, phase0);

% cal z
wxybuf = cat(2,fitresult1(:,3:4),fitresult2(:,3:4),fitresult3(:,3:4));
if doWXYComp >0
    pbuf = cat(2, phase1, phase2, phase3, amp1./offset1,amp2./offset2,amp3./offset3);
else
    pbuf = zeros(0,6);
end
[resultz_raw, zrange, resultzList_raw, dwxy_raw] = CalZwithAst_sepfit(wxybuf, pbuf, zcalidata);


% phase-Z to phase compensation
if doPZComp>0
    disp('do phase-Z to phase compensation..');
    temp = doPZ_PhaseComp_3ch(cat(2, phase1, phase2, phase3), resultz_raw, zcalidata);
    phase1 = temp(:,1);
    phase2 = temp(:,2);
    phase3 = temp(:,3);
end

smInfo(:,5) = phase1;
smInfo(:,6) = phase2;
smInfo(:,7) = phase3;
smInfo(:,8) = amp1./offset1;
smInfo(:,9) = amp2./offset2;
smInfo(:,10) = amp3./offset3;
smInfo(:,11) = 1:subimgcnt;

%photon number
smInfo(:,12) = sum(fitresult1(:,5:7), 2).*2.*pi.*fitresult1(:,3).*fitresult1(:,4).*e2cfactorCMOS;
smInfo(:,13) = sum(fitresult2(:,5:7), 2).*2.*pi.*fitresult2(:,3).*fitresult2(:,4).*e2cfactorCMOS;
smInfo(:,14) = sum(fitresult3(:,5:7), 2).*2.*pi.*fitresult3(:,3).*fitresult3(:,4).*e2cfactorCMOS;
smInfo(:,4) = sum(fitresult1(:,5:7), 2).*2.*pi.*fitresult1(:,3).*fitresult1(:,4).*e2cfactorCMOS + ...
    sum(fitresult2(:,5:7), 2).*2.*pi.*fitresult2(:,3).*fitresult2(:,4).*e2cfactorCMOS + ...
    sum(fitresult3(:,5:7), 2).*2.*pi.*fitresult3(:,3).*fitresult3(:,4).*e2cfactorCMOS;
smInfo(:,15) = smInfo(:,4) .* intlist_demix;

smInfomask = fitresult1(:,1)<3 & fitresult1(:,1)>-3 & fitresult1(:,2)<3 & fitresult1(:,2)>-3 & ...%fit mask
    fitresult2(:,1)<3 & fitresult2(:,1)>-3 & fitresult2(:,2)<3 & fitresult2(:,2)>-3 & ...
    fitresult3(:,1)<3 & fitresult3(:,1)>-3 & fitresult3(:,2)<3 & fitresult3(:,2)>-3 & ...
    smInfo(:,4)>0 & smInfo(:,4)<maxPhoton & ...
    fitresult1(:,3) >= minstd & fitresult1(:,3) <= maxstd & fitresult1(:,4) >= minstd & fitresult1(:,4) <= maxstd & ...
    fitresult2(:,3) >= minstd & fitresult2(:,3) <= maxstd & fitresult2(:,4) >= minstd & fitresult2(:,4) <= maxstd & ...
    fitresult3(:,3) >= minstd & fitresult3(:,3) <= maxstd & fitresult3(:,4) >= minstd & fitresult3(:,4) <= maxstd & ...
    smInfo(:,8)>minmd & smInfo(:,8)<maxmd & smInfo(:,9)>minmd & smInfo(:,9)<maxmd & smInfo(:,10)>minmd & smInfo(:,10)<maxmd & ...  % md mask
    abs(dwxy_raw(:,1)) <0.4 & abs(dwxy_raw(:,2)) <0.4;  %dwxy filt

disp(sprintf('SMFitting: mask: %0.2f%% (%d/%d)', sum(smInfomask)/len(smInfomask)*100, sum(smInfomask), len(smInfomask)));
smInfo_raw = smInfo;
intlist_raw = intlist;
smInfo = smInfo(smInfomask, :);
intlist = intlist(smInfomask, :);
resultz = resultz_raw(smInfomask);
dwxy = dwxy_raw(smInfomask,:);

