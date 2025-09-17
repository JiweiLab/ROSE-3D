function result = CalCRLB_G(N, b, s, a)

if nargin <3
    s = 130; %nm
end

if nargin <4
    a = 150; %nm
end

CRLB = (s^2+a^2/12)/N + 8*pi*s^4*b^2/a^2/N^2;

result = sqrt(CRLB);