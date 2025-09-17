function [trace, intlistbuf] = calImagePeakCurve_half(pzimg, x0, y0, initdir)
% initdir = pi/2; %90deg start
max_step = 70;
% disp(sprintf('ImageCurve search: max_step: %d', max_step));

searchr = 8;
sangleList = -40:5:40;
sangleList = sangleList/180*pi;

s = size(pzimg);
[xx, yy] = meshgrid(1:s(2), 1:s(1));

intlistbuf = zeros(0, len(sangleList));
trace = [x0 y0 initdir 0];
% tcnt = 1;
cx = x0;
cy = y0;
cdir = initdir;
% diffdir = 0;
%check if at the edge
if cdir<0 && cy - searchr <=searchr
    cy = s(1)-searchr;
    trace = cat(1, trace, [cx cy cdir 0]);
end
if cdir>0 && cy + searchr*2 > s(1)
    cy = searchr;
    trace = cat(1, trace, [cx cy cdir 0]);
end

stepcnt = 0;
while(1)
    txlist = cx + searchr * cos(sangleList+cdir);
    tylist = cy + searchr * sin(sangleList+cdir);
    intlist = interp2(xx,yy,pzimg,txlist, tylist, 'cubic');
%     plot(sangleList+cdir, intlist);
%     if any(isnan(intlist))
%         break
%     end
    [fitx0, ~, ~, ~] = fitGauss1D(sangleList+cdir, intlist, 0.5);
    ndir = fitx0;
    diffdir = ndir - cdir;
    nx = cx + searchr*cos(cdir + diffdir/2);
    ny = cy + searchr*sin(cdir + diffdir/2);
    
    trace = cat(1, trace, [nx ny ndir diffdir]);
    intlistbuf = cat(1,intlistbuf,intlist);
    cx=nx;
    cy=ny;
    cdir=ndir;
    if cdir<0 && cy - searchr <=searchr
        cy = s(1)-searchr;
        trace = cat(1, trace, [cx cy cdir diffdir]);
    end
    if cdir>0 && cy + searchr*2 > s(1)
        cy = searchr;
        trace = cat(1, trace, [cx cy cdir diffdir]);
    end
    %stop condition
    if cx + searchr >s(2) || cx - searchr <=0 || ...
            abs(diffdir) > 90/180*pi  || abs(ndir - initdir) > 90/180*pi || ...
            ~((cdir>0 && cdir<2.7) || (cdir<0 && cdir>-2.7))
        break;
    end
    
    % exit when run too long
    stepcnt = stepcnt+1;
    if stepcnt >= max_step
        break;
    end
end
trace=trace(1:end-1,:);

end