% fit z-phase script
% init parameters
% filename = 'F:\ROSE-Z\20201030_tom20_MF\sample2_test2\spool_step06.tif';
% filename = filename;
output_16X = 0;
output_Gaussian = 0;
doIntAutoComp = 1; %auto int sompensation

doRCC = 1; %RCC drift correction
%----RCC parameters----
rcc_segframe = 400;
rcc_zoom = 15;
rcc_binz = 10;
rcc_rmax = 50/150;
rcc_pmax = 5e6;
rcc_display = 1; %display RCC result
if exist('filename','var')
    filename_bak = filename;
end
load([filename(1:end-4) '_fitresult_sepfit.mat']);

if exist('filename_bak','var')
    filename = filename_bak;
    clear filename_bak
end

if ~exist('multicolorFlag', 'var')
    multicolorFlag = 1;
end

%% auto int compensation
if doIntAutoComp>0 && exist('smIntList', 'var')
%     disp('DO Auto Int Compensation ..');
    % Compensation for phase #1 and #3, #2 is NOT changed.
    [resultphase1, resultamp1, resultoffset1] = aotoIntComp(smIntList(:,1:3), smInfo(:,1), smInfo(:,2));
    [resultphase2, resultamp2, resultoffset2] = aotoIntComp(smIntList(:,4:6), smInfo(:,1), smInfo(:,2));
%     [resultphase3, resultamp3, resultoffset3] = aotoIntComp(smIntList(:,7:9), smInfo(:,1), smInfo(:,2));
    
    x = smInfo(:,1);
    y = smInfo(:,2);
    p1 = resultphase1;
    p2 = smInfo(:,7);
    p3 = resultphase2;
    fdata = smInfo(:,3);
else
%     disp('NO Auto Int Compensation ..');
    x = smInfo(:,1);
    y = smInfo(:,2);
    %change the phase order
    p1 = smInfo(:,5);
    p2 = smInfo(:,7);
    p3 = smInfo(:,6);
    fdata = smInfo(:,3);
end

p1 = checkPhase(p1);
p2 = checkPhase(p2);
p3 = checkPhase(p3);
%% fit phase plane for resultz

[lp1, lp2, resultp1, resultp2, resultx, resulty, resultdx, resultdy, A] ...
= CalculatePhaseAndFineXY_3d_XYZTcomp(x, y, p1, p3, fdata);

[resultz, resultdz, resultzrange] = CalculatePhaseAndFineZ_fixgap(x, y, zdata, fdata, p2, filename,1);

%% RCC
if doRCC >0 && max(fdata) > 500
    disp('RCC drift correction..');
    cd('.\RCC3D');
    coords = [resultx, resulty, resultz, fdata];
    [coordscorr, finaldrift, seginfo, driftbuf] = RCC_3D_Ex(coords, rcc_segframe, rcc_zoom, rcc_binz, rcc_rmax, rcc_pmax);
    
    coords_gaus = [x, y, zdata, fdata];
    [coordscorr_gaus, finaldrift_gaus, seginfo_gaus, driftbuf_gaus] = RCC_3D_Ex(coords_gaus, rcc_segframe, rcc_zoom, rcc_binz, rcc_rmax, rcc_pmax);
    cd('..\');
    if rcc_display>0
        figure
        set(gcf,'position',[150,0,800,600]);
        subplot(2,1,1);
        plot(finaldrift(:,1:2));
        title('drift XY (pixel)');
        subplot(2,1,2);
        plot(finaldrift(:,3));
        title('drift Z (nm)');
        
        saveFigure(gcf, [filename(1:end-4) '_RCC.png']);
    end
    
end
%% multicolor 
[dyresult, dyeList] = calDemix3_3D(smInfo(:,4), smInfo(:,15), multicolorFlag);
if multicolorFlag ==3
    mask_dye1 = dyresult==1;
    mask_dye2 = dyresult==2;
    mask_dye3 = dyresult==3;
elseif multicolorFlag ==2
    mask_dye1 = dyresult==1;
    mask_dye2 = dyresult==2;
else
    
end
%% save result to file
if multicolorFlag ==3
    save([filename(1:end-4) '_fitZresult.mat'], 'filename', 'dyeList', 'resultz', 'resultzrange', 'resultx', 'resulty', ...
        'mask_dye1', 'mask_dye2', 'mask_dye3', 'multicolorFlag');
elseif multicolorFlag ==2
    save([filename(1:end-4) '_fitZresult.mat'], 'filename', 'dyeList', 'resultz', 'resultzrange', 'resultx', 'resulty', ...
        'mask_dye1', 'mask_dye2', 'multicolorFlag');
else
    save([filename(1:end-4) '_fitZresult.mat'], 'filename', 'resultz', 'resultzrange', 'resultx', 'resulty', ...
        'multicolorFlag');
end

if doRCC >0 && max(fdata) > 500
    save([filename(1:end-4) '_RCCresult.mat'], 'filename', 'coordscorr', 'coords', 'finaldrift', 'seginfo', 'driftbuf' ...
        , 'coordscorr_gaus', 'coords_gaus', 'finaldrift_gaus', 'seginfo_gaus', 'driftbuf_gaus');
    finalx = coordscorr(:,1);
    finaly = coordscorr(:,2);
    finalz = coordscorr(:,3);
else
    finalx = resultx;
    finaly = resulty;
    finalz = resultz(:);
end

%% gen images
if multicolorFlag >1
    %output 2 dye image
    timg = PointSet2Image3D(finalx(mask_dye1), finaly(mask_dye1), finalz(mask_dye1),8, resultzrange(1):20:resultzrange(2),[0 230 0 230]);
    tiffwrite(timg,[filename(1:end-4) '_out3D_647_8X.tif']);
    timg = PointSet2Image3D(finalx(mask_dye2), finaly(mask_dye2), finalz(mask_dye2),8, resultzrange(1):20:resultzrange(2),[0 230 0 230]);
    tiffwrite(timg,[filename(1:end-4) '_out3D_660_8X.tif']);
    if multicolorFlag ==3
        timg = PointSet2Image3D(finalx(mask_dye3), finaly(mask_dye3), finalz(mask_dye3),8, resultzrange(1):20:resultzrange(2),[0 230 0 230]);
        tiffwrite(timg,[filename(1:end-4) '_out3D_680_8X.tif']);
    end
else
    timg = PointSet2Image3D(finalx, finaly, finalz,8, resultzrange(1):20:resultzrange(2),[0 230 0 230]);
    tiffwrite(timg,[filename(1:end-4) '_out3D_8X.tif']);
end
%%
if output_16X>0
    if multicolorFlag >1
        timg = PointSet2Image3D(finalx(mask_dye1), finaly(mask_dye1), finalz(mask_dye1),16, resultzrange(1):10:resultzrange(2),[0 240 0 240]);
        tiffwrite(timg,[filename(1:end-4) '_out3D_647_16X.tif']);
        timg = PointSet2Image3D(finalx(mask_dye2), finaly(mask_dye2), finalz(mask_dye2),16, resultzrange(1):10:resultzrange(2),[0 240 0 240]);
        tiffwrite(timg,[filename(1:end-4) '_out3D_660_16X.tif']);
        if multicolorFlag ==3
            timg = PointSet2Image3D(finalx(mask_dye3), finaly(mask_dye3), finalz(mask_dye3),16, resultzrange(1):10:resultzrange(2),[0 240 0 240]);
            tiffwrite(timg,[filename(1:end-4) '_out3D_680_16X.tif']);
        end
    else
        timg = PointSet2Image3D(finalx, finaly, finalz,16, resultzrange(1):10:resultzrange(2),[0 240 0 240]);
        tiffwrite(timg,[filename(1:end-4) '_out3D_16X.tif']);
    end
end

%% output gaussian image
if output_Gaussian>0
    timg = PointSet2Image3D(coordscorr_gaus(:,1), coordscorr_gaus(:,2), coordscorr_gaus(:,3),8, (min(coordscorr_gaus(:,3)-20)):20:(max(coordscorr_gaus(:,3)+20)),[0 250 0 250]);
    tiffwrite(timg,[filename(1:end-4) '_out3D_Gauss_8X.tif']);
end
