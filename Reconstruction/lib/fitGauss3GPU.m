function [fitresult, states] = fitGauss3GPU(subimgbuf, initstd)
% fitting sub images with 3 Gaussian model
%result:    [x y wx wy int1 int2 int3 bkg1 bkg2 bkg3 exitflag]
%           [1 2  3  4  5    6    7     8    9    10   11   ]
% fitresult = fitGauss3GPU(subimgbuf)
    if nargin <2
        initstd = 1.2;
    end

    s = size(subimgbuf);
    if len(s)<4
        s = [s 1];
    end
    hs = (s(1)-1)/2; %half width of subimage
    subimgcnt = s(4);

    % make initial parameter
    initpar = zeros(10, subimgcnt);
    initpar(1,:) = hs;
    initpar(2,:) = hs;
    initpar(3,:) = initstd;
    initpar(4,:) = initstd;
    initpar(5,:) = max(reshape(subimgbuf(:,:,1,:), s(1)*s(2), s(4)),[],1);
    initpar(6,:) = max(reshape(subimgbuf(:,:,2,:), s(1)*s(2), s(4)),[],1);
    initpar(7,:) = max(reshape(subimgbuf(:,:,3,:), s(1)*s(2), s(4)),[],1);
    initpar(8,:) = min(reshape(subimgbuf(:,:,1,:), s(1)*s(2), s(4)),[],1);
    initpar(9,:) = min(reshape(subimgbuf(:,:,2,:), s(1)*s(2), s(4)),[],1);
    initpar(10,:) = min(reshape(subimgbuf(:,:,3,:), s(1)*s(2), s(4)),[],1);
    %parameter: [x y wx wy int1 int2 int3 bkg1 bkg2 bkg3 exitflag]
    %           [1 2  3  4  5    6    7    8    9    10   11   ]
    [tfitresult, ~] = gpufitEx(subimgbuf, 13, initpar, 'est_id',EstimatorID.LSE);
    [fitresult, states] = gpufitEx(subimgbuf, 13, tfitresult, 'est_id',EstimatorID.MLE);
    fitresult = fitresult';
    fitresult(:,1) = fitresult(:,1) - hs;
    fitresult(:,2) = fitresult(:,2) - hs;

    % swap x and y
    fitresult(:,1:2) = fitresult(:,[2,1]);
    % swap wx and wy
    fitresult(:,3:4) = fitresult(:,[4,3]);
end