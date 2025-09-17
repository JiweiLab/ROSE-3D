function [resultz, zrange, resultz_raw, dwxy] = CalZwithAst_sepfit(wxybuf, pdata, calidata)
% resultz = CalZwithAst_sepfit(wxybuf, pdata, calidata)
% wxybuf: [wx1, wy1, wx2, wy2, wx3, wy3]
% pdata:  [p1, p2, p3, md1, md2, md3]
% calidata: cali file path or data buf
%

    if nargin<3 || isempty(calidata)
        calidata = '.\zcaliData_sepfit.mat';
    end

    if ischar(calidata)
        calidata = load(calidata);
    end

    [zdata1, zrange, dwxy1] = CalZwithAstNew_dist(wxybuf(:,1), wxybuf(:,2), calidata.caliresult_1, pdata(:,1), pdata(:,4));
    [zdata2, ~, dwxy2] = CalZwithAstNew_dist(wxybuf(:,3), wxybuf(:,4), calidata.caliresult_2, pdata(:,2), pdata(:,5));
    [zdata3, ~, dwxy3] = CalZwithAstNew_dist(wxybuf(:,5), wxybuf(:,6), calidata.caliresult_3, pdata(:,3), pdata(:,6));
    
    resultz = (zdata1 + zdata2 + zdata3)/3;
    resultz_raw = [zdata1, zdata2, zdata3];
    dwxy = (dwxy1+dwxy2+dwxy3)/2;
end