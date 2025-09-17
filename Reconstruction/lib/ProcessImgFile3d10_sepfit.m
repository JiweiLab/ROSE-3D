function ProcessImgFile3d10_sepfit(filename, opt)
% seperate fitting version
%
% arg                 default
% saveSubImages         0
% isEM                  1
% EMgain                20
% e2cfactorEM           10.5
% e2cfactorConv         1.85
% e2cfactorCMOS         0.23;%electrons/count
% detThreshold          3
% substractBkg          0
% autoskip              1   %skip if result file exist
% detWindowWidth        7

    saveSubImages = 0;
    isEM = 1;
    EMgain = 20;
%     e2cfactorEM = 10.5;
%     e2cfactorConv = 1.85
    %detection parameter
    detThreshold = 3;
    detWindowWidth = 7;
    autoskip = 1;
    substractBkg = 0;
    multicolorFlag = 1; % a flag of multi color

    % apply options
    if nargin>1 && isstruct(opt)
        %saveSubImages
        if isfield(opt, 'saveSubImages')
            saveSubImages = opt.saveSubImages;
        end
        %isEM
        if isfield(opt, 'isEM')
            isEM = opt.isEM;
        end
        %EMgain
        if isfield(opt, 'EMgain')
            EMgain = opt.EMgain;
        end
%         %e2cfactorEM
%         if isfield(opt, 'e2cfactorEM')
%             e2cfactorEM = opt.e2cfactorEM;
%         end
%         %e2cfactorConv
%         if isfield(opt, 'e2cfactorConv')
%             e2cfactorConv = opt.e2cfactorConv;
%         end
        %detThreshold
        if isfield(opt, 'detThreshold')
            detThreshold = opt.detThreshold;
        end
        %detWindowWidth
        if isfield(opt, 'detWindowWidth')
            detWindowWidth = opt.detWindowWidth;
        end
        
        if isfield(opt, 'autoskip')
            autoskip = opt.autoskip;
        end
        
        if isfield(opt, 'substractBkg')
            substractBkg = opt.substractBkg;
        end
        
        
        %multicolorFlag
        if isfield(opt, 'multicolorFlag')
            multicolorFlag = opt.multicolorFlag;
        end
    end
    
    temp = strfind(filename,'\');
    imgpath = filename(1:temp(end));
    
    imgpath_prefix = filename(1:end-4);
    
    opt.filename = filename;
    opt.imgpath = imgpath;
    opt.imgpath_prefix = imgpath_prefix;
    
    %% check if result exist
    if autoskip >0 && exist([imgpath_prefix '_fitting_sepfit.mat'], 'file')
        return;
    end
    
    %% duplicate and registration of images
    % if new dataset, then copy registration .mat file into the folder
    if ~exist([imgpath 'RegInfo.mat'], 'file')
        copyfile('..\PreProcess\RegInfo.mat', [imgpath 'RegInfo.mat']);
    end
    
    if ~exist([imgpath 'IntComp.mat'], 'file') && exist('..\PreProcess\IntComp.mat', 'file')
        copyfile('..\PreProcess\IntComp.mat', [imgpath 'IntComp.mat']);
    end
    opt.intCompFile = [imgpath 'IntComp.mat'];
    
    if saveSubImages>0
        outfile_prefix = [filename(1:end-4) '_out'];
%         [imgbuf1, imgbuf2b, imgbuf3b, imgbuf4b] = dupRegImages4(filename, [imgpath 'RegInfo.mat'], outfile_prefix);
        [imgbuf1, imgbuf2, imgbuf3, imgbuf4, imgbuf5 ,imgbuf6, imgbuf7, imgbuf8, imgbuf9, imgbuf10] = dupRegImages10_2cam(filename, [imgpath 'RegInfo.mat'], outfile_prefix);
    else
%         [imgbuf1, imgbuf2b, imgbuf3b, imgbuf4b] = dupRegImages4(filename, [imgpath 'RegInfo.mat']);
        [imgbuf1, imgbuf2, imgbuf3, imgbuf4, imgbuf5 ,imgbuf6, imgbuf7, imgbuf8, imgbuf9, imgbuf10] = dupRegImages10_2cam(filename, [imgpath 'RegInfo.mat']);
    end
    
    %% substract background
    if substractBkg>0
        disp('DO background subtraction ..');
        imglen = size(imgbuf1,3);
        imgbuf1 = imgbuf1 - repmat(mean(imgbuf1,3),1,1,imglen);
        imgbuf2 = imgbuf2 - repmat(mean(imgbuf2,3),1,1,imglen);
        imgbuf3 = imgbuf3 - repmat(mean(imgbuf3,3),1,1,imglen);
        imgbuf4 = imgbuf4 - repmat(mean(imgbuf4,3),1,1,imglen);
        imgbuf5 = imgbuf5 - repmat(mean(imgbuf5,3),1,1,imglen);
        imgbuf6 = imgbuf6 - repmat(mean(imgbuf6,3),1,1,imglen);
        imgbuf7 = imgbuf7 - repmat(mean(imgbuf7,3),1,1,imglen);
        imgbuf8 = imgbuf8 - repmat(mean(imgbuf8,3),1,1,imglen);
        imgbuf9 = imgbuf9 - repmat(mean(imgbuf9,3),1,1,imglen);
        imgbuf10 = imgbuf10 - repmat(mean(imgbuf10,3),1,1,imglen);
    end
    %% detection
%     imgfilename_sum = [filename(1:end-4) '_outsum.tif'];
    % imgbuf_sum = imgbuf1 + imgbuf2b + imgbuf3b;
    detectResult = SMDetection(imgbuf1+imgbuf2+imgbuf3+imgbuf4+imgbuf5+imgbuf6+imgbuf7+imgbuf8+imgbuf9, ...
        detThreshold, detWindowWidth, [], [imgpath_prefix '_Detection.mat']);

    %% fitting  
%     [fitresult, smInfo, subimginfo, fitresult_2, states, states_2, smIntList, smInfo_raw, intlist_raw] = SMFitting3d10(imgbuf1, imgbuf2, imgbuf3, imgbuf4, imgbuf5, ...
%         imgbuf6, imgbuf7, imgbuf8, imgbuf9, imgbuf10, ...
%         detectResult, opt);

% fitresult: [fitresult1, fitresult2, fitresult3, fitresult4]
% smInfo
% [x y frame ptn phase1  phase2  phase3  md1  md2  md3  idx   ptn1 ptn2 ptn3 ptndemix]
% [1 2   3    4    5       6        7     8    9    10   11    12   13   14   15]

    [fitresult, smInfo, subimginfo, states, smIntList, resultz, zrange, ...
    smInfo_raw, smIntList_raw, resultz_raw, smInfomask, ...
    resultzList_raw, dwxy, dwxy_raw] = SMFitting3d10_sepfit( ...
    imgbuf1, imgbuf2,imgbuf3, imgbuf4, imgbuf5, ...
    imgbuf6, imgbuf7, imgbuf8, imgbuf9, imgbuf10, ...
    detectResult, opt);
   
    %% save fitting results
    imgsize = size(imgbuf1);
    fitfilepath = [imgpath_prefix '_fitting_sepfit.mat'];
    save(fitfilepath, 'fitresult', 'smInfo', 'subimginfo', 'states', 'smIntList', 'resultz', 'zrange', ...
    'smInfo_raw', 'smIntList_raw', 'resultz_raw', 'smInfomask', ...
    'resultzList_raw','dwxy','dwxy_raw', ...
    'filename', 'multicolorFlag', 'imgsize', 'subimginfo');
end