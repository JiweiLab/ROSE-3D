function result = CalMeanCRLB_sxy(N,b,k,md,sx, sy,a, swcycle)

%% CRLB test

if nargin <1
    N = 1000;
end

if nargin <2
    b = 10; %in photons
end

if nargin <3
    k = 1; %nm
end

if nargin <4
    md = 1; %nm
end

if nargin <5
    sx = 160; %nm
end

if nargin <6
    sy = 160; %nm
end

if nargin <7
    a = 150; %nm
end

if nargin <8
    swcycle = 250; %nm
end

plist = 0:0.01:(2*pi);
resultlist = zeros(size(plist));

for m=1:length(plist)
    resultlist(m) = CalCRLB_k_md_sxy(N, b, plist(m), k, md, sx, sy, a)/2/pi*swcycle;
end

result = mean(resultlist);
