function [zdata, zrange, dwxy] = CalZwithAstNew_dist(wxlist, wylist, calidatabuf, pdata, mddata)
%Calculate Z value with wx and wy with phase-z compensation
%zdata = CalZwithAst(wxlist, wylist, calidata)
%calidata: mat file path, default: ..\zcaliData.mat
%
    if nargin<4 || isempty(pdata)
        doComp = 0;
    else
        doComp = 1;
    end
    
    if nargin<5 && doComp>0 %default of md 
        mddata = ones(pdata);
    end
    
%     if nargin<4 || isempty(calidatabuf)
%         calidatabuf = '..\zcaliData.mat';
%     end
%     calidatabuf = load(calidatabuf);
%     wxyrlist = wxlist-wylist;
%     zdata = polyval(databuf.zcali_pw2z, wxyrlist);
    zrange = calidatabuf.zrange;
    zrange_ext = zrange;
    zrange_ext(1) = zrange_ext(1)-200;
    zrange_ext(2) = zrange_ext(2)+200;
    zdata = fitZwithWXY(wxlist, wylist,calidatabuf.zcali_pz2wx, calidatabuf.zcali_pz2wy, zrange_ext, 1);
    if doComp>0
        wx_comp = wxlist ./ (interp2(calidatabuf.comp_gridz, calidatabuf.comp_gridp, calidatabuf.comp_widthRatioX, ...
            zdata, checkPhase(pdata),'linear', 1).*mddata + 1-mddata);
        wy_comp = wylist ./ (interp2(calidatabuf.comp_gridz, calidatabuf.comp_gridp, calidatabuf.comp_widthRatioY, ...
            zdata, checkPhase(pdata),'linear', 1).*mddata + 1-mddata);
        [zdata, dwxy] = fitZwithWXY_dist(wx_comp, wy_comp, calidatabuf.zcali_pz2wx, calidatabuf.zcali_pz2wy, zrange_ext, 1);
    else
        
    end
end