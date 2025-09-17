function [fitresult, gof] = fitXYPhase_cfit(xx, yy, toffsetmap_unwrap)
%CREATEFIT(XX,YY,TOFFSETMAP_UNWRAP)
%  Create a fit.
%
%  Data for 'untitled fit 2' fit:
%      X Input : xx
%      Y Input : yy
%      Z Output: toffsetmap_unwrap
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  另请参阅 FIT, CFIT, SFIT.

%  由 MATLAB 于 07-Dec-2020 16:46:53 自动生成


%% Fit: 'untitled fit 2'.
[xData, yData, zData] = prepareSurfaceData( xx, yy, toffsetmap_unwrap );

% Set up fittype and options.
ft = fittype( 'poly11' );

% Fit model to data.
[fitresult, gof] = fit( [xData, yData], zData, ft );

% % Plot fit with data.
% figure( 'Name', 'untitled fit 2' );
% h = plot( fitresult, [xData, yData], zData );
% legend( h, 'untitled fit 2', 'toffsetmap_unwrap vs. xx, yy', 'Location', 'NorthEast' );
% % Label axes
% xlabel xx
% ylabel yy
% zlabel toffsetmap_unwrap
% grid on
% view( -3.1, 9.2 );


