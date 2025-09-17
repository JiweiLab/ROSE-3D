function [fitresult, states] = fitGauss4GPU_demix(subimgbuf, initstd)
% fitting sub images with 3 Gaussian model
%result:    [x y wx wy int1 int2 int3 int4 bkg1 bkg2 bkg3 bkg4 exitflag]
%           [1 2  3  4  5    6    7    8    9    10   11   12    13]
% fitresult = fitGauss3GPU(subimgbuf)

%constants from constants.h:
% enum ModelID {
%     GAUSS_1D = 0,
%     GAUSS_2D = 1,
%     GAUSS_2D_ELLIPTIC = 2,
%     GAUSS_2D_ROTATED = 3,
%     CAUCHY_2D_ELLIPTIC = 4,
%     LINEAR_1D = 5,
%     FLETCHER_POWELL_HELIX = 6,
%     BROWN_DENNIS = 7,
% 	GAUSS_2D_6P = 8,
% 	GAUSS_2D_2P = 9,
% 	GAUSS_2D_3P = 10,
% 	GAUSS_2D_4P = 11,
% 	GAUSS_2D_1P_ELLIPTIC = 12,
% 	GAUSS_2D_3P_ELLIPTIC = 13,
% 	GAUSS_2D_4P_ELLIPTIC = 14,
% 	GAUSS_2D_6P_ELLIPTIC = 15,
% 	GAUSS_2D_9P_ELLIPTIC = 16,
% 	GAUSS_2D_10P_ELLIPTIC = 17,
% 	GAUSS_2D_3P3_ELLIPTIC = 18,
% 	GAUSS_2D_4P_ELLIPTIC_DEMIX = 114
% };
% 
% // estimator ID
% enum EstimatorID { LSE = 0, MLE = 1 };
% 
% // fit state
% enum FitState { CONVERGED = 0, MAX_ITERATION = 1, SINGULAR_HESSIAN = 2, NEG_CURVATURE_MLE = 3, GPU_NOT_READY = 4 };
% 
% // return state
% enum ReturnState { OK = 0, ERROR = -1 };
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
    initpar = zeros(12, subimgcnt);
    initpar(1,:) = hs;
    initpar(2,:) = hs;
    initpar(3,:) = initstd;
    initpar(4,:) = initstd;
    initpar(5,:) = max(reshape(subimgbuf(:,:,1,:), s(1)*s(2), s(4)),[],1);
    initpar(6,:) = max(reshape(subimgbuf(:,:,2,:), s(1)*s(2), s(4)),[],1);
    initpar(7,:) = max(reshape(subimgbuf(:,:,3,:), s(1)*s(2), s(4)),[],1);
    initpar(8,:) = max(reshape(subimgbuf(:,:,4,:), s(1)*s(2), s(4)),[],1);
    initpar(9,:) = min(reshape(subimgbuf(:,:,1,:), s(1)*s(2), s(4)),[],1);
    initpar(10,:) = min(reshape(subimgbuf(:,:,2,:), s(1)*s(2), s(4)),[],1);
    initpar(11,:) = min(reshape(subimgbuf(:,:,3,:), s(1)*s(2), s(4)),[],1);
    initpar(12,:) = min(reshape(subimgbuf(:,:,4,:), s(1)*s(2), s(4)),[],1);
    %parameter: [x y wx wy int1 int2 int3 bkg1 bkg2 bkg3 exitflag]
    %           [1 2  3  4  5    6    7    8    9    10   11   ]
    [tfitresult, ~] = gpufitEx(subimgbuf, 114, initpar, 'est_id',EstimatorID.LSE);
    [fitresult, states] = gpufitEx(subimgbuf, 114, tfitresult, 'est_id',EstimatorID.MLE);
    fitresult = fitresult';
    fitresult(:,1) = fitresult(:,1) - hs;
    fitresult(:,2) = fitresult(:,2) - hs;

    % swap x and y
    fitresult(:,1:2) = fitresult(:,[2,1]);
    % swap wx and wy
    fitresult(:,3:4) = fitresult(:,[4,3]);
end