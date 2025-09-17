%% Z vs CRLB localization precision 
% parameters
N = 10000; %photon
bconv = 16.5;  % background of conventional
brose = 5.5; % background of ROSE, std of photon for each image
k = 1; % noise conv factor
md = 0.95; %modulation depth
a = 150; %pixel size in nm
swcycle = 260; %fringe width in nm

zlist = 0:100:1200; %axial position in nm
simlen = length(zlist);
zlist_show = zlist - mean(zlist);

% astigmatism curve in 640 channel
z2wxcoef = [2.975e-10,2.286e-06,-0.0046,3.0674];
z2wycoef = [-4.441e-10,3.932e-06,-0.0027,1.54];

%% make exy list
wxlist = polyval(z2wxcoef, zlist); %wx in pix
wylist = polyval(z2wycoef, zlist); %wy in pix

%% cal CRLB
crlb_gauss_x = zeros(simlen,1);
crlb_gauss_y = zeros(simlen,1);
crlb_rose = zeros(simlen,1);
for m=1:simlen
    crlb_gauss_x(m) = CalCRLB_G(N, bconv, wxlist(m).*a, a);
    crlb_gauss_y(m) = CalCRLB_G(N, bconv, wylist(m).*a, a);
    crlb_rose(m) = CalMeanCRLB_sxy(N/3,brose,k,md,wxlist(m).*a, wylist(m).*a,a, swcycle);
end
%% display
figure;
set(gcf, 'Position', [300, 300, 900, 400]);

% CRLB
subplot(1,2,1)
plot(zlist_show, crlb_gauss_x,'LineWidth', 1)
hold on
plot(zlist_show, crlb_gauss_y,'LineWidth', 1)
plot(zlist_show, crlb_rose,'LineWidth', 1)
hold off
title('CRLB');
legend('ConvX','ConvY','ROSE-3D');
box off;
grid on;
xlim([zlist_show(1)-50, zlist_show(end)+50]);
ylim([0, max(max(crlb_gauss_x), max(crlb_gauss_y))+1]);
set(gca, 'TickDir', 'out', 'fontsize',12,'LineWidth', 1);

% enhancement
subplot(1,2,2)
plot(zlist_show, crlb_gauss_x./crlb_rose,'LineWidth', 1)
hold on
plot(zlist_show, crlb_gauss_y./crlb_rose,'LineWidth', 1)
hold off
title('Enhancement');
legend('X','Y');
xlim([zlist_show(1)-50, zlist_show(end)+50]);
ylim([0 8]);
box off;
grid on;
set(gca, 'TickDir', 'out', 'fontsize',12,'LineWidth', 1);