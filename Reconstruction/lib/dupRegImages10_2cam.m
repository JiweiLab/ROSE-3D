function [imgbuf1, imgbuf2b, imgbuf3b, imgbuf4b, imgbuf5b, imgbuf6b, imgbuf7b, imgbuf8b, imgbuf9b, imgbuf10b] = ...
    dupRegImages10_2cam(imgpath, matfile, outfile_prefix)

% duplicate and registration images, registed images expanded align to
% image #1
%
%filename like this: spool_A(1).tif, spool_B(1).tif
%

%输出图像的顺序
output_idx = [5,4,3,2,1,6,7,8,9,10];

tpos = strfind(imgpath, '\');
folderpath = imgpath(1:tpos(end));

if nargin<2 || isempty(matfile)
    matfile = '..\PreProcess\RegInfo.mat';
end
if ischar(imgpath) %check if RegInfo.mat exist in the image path
    
    matfile_check = [folderpath 'RegInfo.mat'];
    if exist(matfile_check,'file')
        matfile = matfile_check;
        disp('RegInfo.mat exist.');
    else %if not exist, copy the RegInfo to the image path
        copyfile(matfile, matfile_check);
        disp('copy RegInfo.mat.');
    end
end

% try to copy int comp file
if ~exist([folderpath 'IntComp.mat'], 'file') && exist('..\PreProcess\IntComp.mat', 'file')
    copyfile('..\PreProcess\IntComp.mat', [folderpath 'IntComp.mat']);
    disp('copy IntComp.mat.');
end

% try to copy pix comp file
if ~exist([folderpath 'pixComp.mat'], 'file') && exist('..\PreProcess\pixComp.mat', 'file')
    copyfile('..\PreProcess\pixComp.mat', [folderpath 'pixComp.mat']);
    disp('copy pixComp.mat.');
end

%replace _A to _B
tpos = strfind(imgpath, '_A');
if isempty(tpos)
    error('Filename error! (need _A and _B)');
end
tpos = tpos(end);
imgpath2 = [imgpath(1:tpos-1) '_B' imgpath(tpos+2:end)];

%% load parameters
temp = load(matfile);
roibuf = temp.roibuf;
tform2 = temp.tform2;
tform3 = temp.tform3;
tform4 = temp.tform4;
tform5 = temp.tform5;
tform6 = temp.tform6;
tform7 = temp.tform7;
tform8 = temp.tform8;
tform9 = temp.tform9;
tform10 = temp.tform10;

%% Load Images
if ischar(imgpath)
    imgbuf = cell(1,2);
    imgbuf{1} = tiffread(imgpath);
    imgbuf{2} = tiffread(imgpath2);
else
    error('NOT completed.');
    imgbuf = imgpath;
end
s1 = size(imgbuf{1});
s2 = size(imgbuf{2});
s = {s1,s2};

imglen = size(imgbuf{1}, 3);


%% make data list
imgbuflist = cell(1,9);
imgidxlist = roibuf(:,5);
tformbuf = {[], tform2, tform3, tform4, tform5, tform6, tform7,tform8,tform9,tform10};
imgbuflist{1} = imgbuf{imgidxlist(1)}(roibuf(1,2):roibuf(1,4), roibuf(1,1):roibuf(1,3),:);

for m=2:10
    %% dup and reg subimg
    % roi 1 & 2 [xs, ys, xe, ye]
    roi1 = roibuf(1,:);
    roi2 = roibuf(m,:);

    %subimg width and height
    tw = roi1(3) - roi1(1) +1;
    th = roi1(4) - roi1(2) +1;

    % current tform, transformPointsForward, transformPointsInverse
    ctf = tformbuf{m};

    %--- step1: rect(roi1) -inverse--tform2-> rect(roi1p)
    plist_r1 = [1,1; tw,1; 1,th; tw,th];
    plist_r1p = ctf.transformPointsInverse(plist_r1);
    plist_r1p(:,1) = plist_r1p(:,1) -1 + roi2(1);
    plist_r1p(:,2) = plist_r1p(:,2) -1 + roi2(2);

    %--- step2: duplicate subimg
    % duplicate rect
    xs = floor(min(plist_r1p(:,1)));
    xe = ceil(max(plist_r1p(:,1)));
    ys = floor(min(plist_r1p(:,2)));
    ye = ceil(max(plist_r1p(:,2)));
    % valid rect 注意出原图范围的情况，目前还没有出
    if xs<1
        xsp = 1;
    else
        xsp = xs;
    end
    if ys<1
        ysp = 1;
    else
        ysp = ys;
    end
    if xe>s{imgidxlist(m)}(2)
        xep = s{imgidxlist(m)}(2);
    else
        xep = xe;
    end
    if ye>s{imgidxlist(m)}(1)
        yep = s{imgidxlist(m)}(1);
    else
        yep = ye;
    end

    txs = xsp - xs +1;
    txe = txs + xep - xsp;
    tys = ysp - ys +1;
    tye = tys + yep - ysp;

    temp = imgbuf{imgidxlist(m)}(ysp:yep, xsp:xep, 1);
    minint = min(temp(:));
    subimgbuf = ones([ye-ys+1, xe-xs+1, imglen],'like',imgbuf{imgidxlist(m)}).*minint;
    subimgbuf(tys:tye, txs:txe, :) = imgbuf{imgidxlist(m)}(ysp:yep, xsp:xep, :);
    roioffsetx = xs - roi2(1);
    roioffsety = ys - roi2(2);

    %--- step3: make new tform
    ctf2 = ctf;
    ctf2.T(3,1) = ctf2.T(3,1) + roioffsetx * ctf2.T(1,1)+ roioffsety * ctf2.T(2,1); %check!
    ctf2.T(3,2) = ctf2.T(3,2) + roioffsetx * ctf2.T(1,2)+ roioffsety * ctf2.T(2,2);

    %--- step4: transform
    imref = imref2d([th, tw]);
    imgbuflist{m} = imwarp(subimgbuf, ctf2,'OutputView',imref);

end
%% make sub-images
clear imgbuf
imgbuf1 = imgbuflist{output_idx(1)};
imgbuf2b = imgbuflist{output_idx(2)};
imgbuf3b = imgbuflist{output_idx(3)};
imgbuf4b = imgbuflist{output_idx(4)};
imgbuf5b = imgbuflist{output_idx(5)};
imgbuf6b = imgbuflist{output_idx(6)};
imgbuf7b = imgbuflist{output_idx(7)};
imgbuf8b = imgbuflist{output_idx(8)};
imgbuf9b = imgbuflist{output_idx(9)};
imgbuf10b = imgbuflist{output_idx(10)};

%% save images
if nargin >=3
    tiffwriteStack(imgbuf1, [outfile_prefix '1.tif']);
    tiffwriteStack(imgbuf2b, [outfile_prefix '2.tif']);
    tiffwriteStack(imgbuf3b, [outfile_prefix '3.tif']);
    tiffwriteStack(imgbuf4b, [outfile_prefix '4.tif']);
    tiffwriteStack(imgbuf5b, [outfile_prefix '5.tif']);
    tiffwriteStack(imgbuf6b, [outfile_prefix '6.tif']);
    tiffwriteStack(imgbuf7b, [outfile_prefix '7.tif']);
    tiffwriteStack(imgbuf8b, [outfile_prefix '8.tif']);
    tiffwriteStack(imgbuf9b, [outfile_prefix '9.tif']);
    tiffwriteStack(imgbuf10b, [outfile_prefix '10.tif']);
    tiffwriteStack(imgbuf1+imgbuf2b+imgbuf3b+imgbuf4b+imgbuf5b+imgbuf6b+imgbuf7b+imgbuf8b+imgbuf9b, ...
        [outfile_prefix 'sum.tif']);
end
