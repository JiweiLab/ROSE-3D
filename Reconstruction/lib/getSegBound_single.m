function [ret] = getSegBound_single(trace, s, maxwidth)
if nargin <3
    maxwidth = 15;
end
ret = zeros(0,2);

t1 = interpTrace(trace, s);
ylist = min(t1(:,2)) : max(t1(:,2));
ylen = length(ylist);
ret1a = zeros(ylen, 2);
ret1b = zeros(ylen, 2);
for m=1:ylen
    cy = ylist(m);
    tidx1 = find(t1(:,2) == cy);
    tidx1 = tidx1(1);
    cx1 = t1(tidx1,1);
    tx1 = cx1 + maxwidth;
    tx2 = cx1 - maxwidth;
    ret1a(m,:) = [tx1, cy];
    ret1b(m,:) = [tx2, cy];
end

ret = cat(1, ret, ret1a, ret1b);

%close top
if min(t1(:,2)) >1
    cy = min(t1(:,2));
    tidx1 = find(t1(:,2) == cy);
    tidx1 = tidx1(1);
    cx1 = t1(tidx1,1);
    tx1 = cx1 + maxwidth;
    tx2 = cx1 - maxwidth;
    
    xlist = tx2 : tx1;
    ylist = ones(size(xlist)) .* cy;
    
    ret = cat(1, ret, [xlist', ylist']);
end

%close bottom
if max(t1(:,2)) < s(1)
    cy = max(t1(:,2));
    tidx1 = find(t1(:,2) == cy);
    tidx1 = tidx1(1);
    cx1 = t1(tidx1,1);
    tx1 = cx1 + maxwidth;
    tx2 = cx1 - maxwidth;
    
    xlist = tx2 : tx1;
    ylist = ones(size(xlist)) .* cy;
    
    ret = cat(1, ret, [xlist', ylist']);
end