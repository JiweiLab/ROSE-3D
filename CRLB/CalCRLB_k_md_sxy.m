function result = CalCRLB_k_md_sxy(N,b,P,k,md,sx,sy,a)

%% CRLB test

if nargin <1
    N = 1000;
end

if nargin <2
    b = 10; %in photons
end

if nargin <3
    P = 0;
end

if nargin <4
    k = 1; % noise factor
end

if nargin <5
    md = 1; %modulation depth
end

if nargin <6
    sx = 160; %nm
end

if nargin <7
    sy = 160; %nm
end

if nargin <8
    a = 150; %nm
end

s = sqrt(sx*sy);

N1 = N*(1+sin(P-pi*2/3))/3;
s1 = k*N1+4*pi*s.^2*b.^2/a.^2;
N2 = N*(1+sin(P))/3;
s2 = k*N2+4*pi*s.^2*b.^2/a.^2;
N3 = N*(1+sin(P+pi*2/3))/3;
s3 = k*N3+4*pi*s.^2*b^2/a.^2;

bkg = 4*pi*s^2*b^2/a^2;

EAP1 = (N/3*md*cos(P-2/3*pi))^2* (k^2/2/(s1)^2 + 1/(s1));

EBP1 = (N/3*md*cos(P))^2* (k^2/2/(s2)^2 + 1/(s2));

ECP1 = (N/3*md*cos(P+2/3*pi))^2* (k^2/2/(s3)^2 + 1/(s3));

I = EAP1 + EBP1 + ECP1;

CRLB = sqrt(1/I);

result = CRLB;
