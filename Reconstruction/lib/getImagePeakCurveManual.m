function [trace] = getImagePeakCurveManual(pzimg)
%% get ginput trace
hfig = figure();
imagesc(pzimg);
tr = round(ginput());
hold on
plot(tr(:,1), tr(:,2),'r.');
hold off
trlen = size(tr,1);
pzs = size(pzimg);

%% interp input points [current-point next-point)
tr_interp = zeros(0,2);
for m=1:(trlen-1)
    cx = tr(m,1);
    cy = tr(m,2);
    nx = tr(m+1,1);
    ny = tr(m+1,2);
    if cy < ny
        % wrap1 cy -> 1
        tylist = cy : -5: 1;
        tylist = tylist';
        txlist = ones(size(tylist)) * cx;
        tr_interp = cat(1, tr_interp, [txlist tylist]);
        % wrap2 height -> ny
        tylist = pzs(1) : -5: ny;
        tylist = tylist';
        txlist = ones(size(tylist)) * nx;
        tr_interp = cat(1, tr_interp, [txlist tylist]);
    else
        %normal
        tylist = cy : -5: ny;
        tylist = tylist(1:end-1);
        tylist = tylist';
        txlist = round(interp1([cy, ny], [cx,nx], tylist));
        tr_interp = cat(1, tr_interp, [txlist tylist]);
    end
end

%add last point
tr_interp = cat(1, tr_interp, [nx ny]);


%% refine input points
searchlenx = 4; % -4pix ~ 4 pix in x
searchleny = 1; % -2pix ~ 2 pix in y (cum)
resulttr = tr_interp;
for m=1:trlen
    cx = tr_interp(m,1);
    cy = tr_interp(m,2);
    xs = cx - searchlenx;
    xe = cx + searchlenx;
    ys = cy - searchleny;
    ye = cy + searchleny;
    
    %check validate
    if xs<1
        xs=1;
    end
    if ys<1
        ys=1;
    end
    if xe > pzs(2)
        xe = pzs(2);
    end
    if ye > pzs(1)
        ye = pzs(1);
    end
    
    timg = pzimg(ys:ye, xs:xe);
    timg2 = sum(timg, 1);
    tpos = mean(find(timg2 == max(timg2(:))));
    
    resulttr(m,1) = xs + tpos -1;
end
    
imagesc(pzimg);
hold on
plot(tr_interp(:,1), tr_interp(:,2),'r.');
hold off
hold on
plot(resulttr(:,1), resulttr(:,2),'g.');
hold off


%% exit
ginput(1);
close(hfig);

trace = resulttr;