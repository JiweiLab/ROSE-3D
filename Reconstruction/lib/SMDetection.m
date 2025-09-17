function detectResult = SMDetection(imgfile, threshold, windowWidth, dettype, save2mat)
% detectResults = SMDetection(imgfile, threshold, windowWidth, dettype, save2mat)
% Detect single particles in image file, Result will be saved to [imgfile(1:end-4) '_Detection.mat']
% dettype : 
% 1: W2; 2:W3; 3:W2+W3; 4:W2*W3

if nargin<2 || isempty(threshold) || threshold<0
    threshold = 3;
end

if nargin<3 || isempty(windowWidth) || windowWidth<0
    windowWidth = 7;
end

%1: W2; 2:W3; 3:W2+W3; 4:W2*W3
if nargin<4 || isempty(dettype)
    dettype = 1; 
end

assert(any(1:4 == dettype),'SMDetection: dettype Error! MUST be one of: 1: W2; 2:W3; 3:W2+W3; 4:W2*W3');

if nargin<5 || isempty(save2mat)
    save2mat = [];
end

%% load image
if ischar(imgfile)
    imgbuf = LoadTiff16bitRaw(imgfile);
else
    imgbuf = imgfile;
end
s = size(imgbuf);
imglen = size(imgbuf, 3);

%% detection

[detectResult] = DWTParticalDetection(imgbuf, threshold, dettype, windowWidth);
detectCntList = zeros(len(detectResult), 1);
for m=1:len(detectCntList)
    detectCntList(m) = size(detectResult{m},1);
end
detectCnt = sum(detectCntList);

%% save detection result
if ~isempty(save2mat)
%     if ischar(save2mat)
      savepath =save2mat;
%     else
%         savepath =[imgfile(1:end-4) '_Detection.mat'];
%     end
    if ischar(imgfile)
        save(savepath, 'detectResult', 'imgfile', 'threshold', ...
        'dettype', 'windowWidth', 'detectCntList', 'detectCnt');
    else
        save(savepath, 'detectResult', 'threshold', ...
        'dettype', 'windowWidth', 'detectCntList', 'detectCnt');
    end
%     save(savepath, 'detectResult', 'imgfile', 'threshold', ...
%         'dettype', 'windowWidth', 'detectCntList', 'detectCnt');
end
