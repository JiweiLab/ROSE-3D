function result = doPZ_PhaseComp_3ch(plist, zlist, calidata)
% result = doPZ_PhaseComp_3ch(plist, zlist, calidata)
% do compensation of phase and z to phase
% plist: [p1,p2,p3]
% zlist:  [z]
% calidata: cali file path or data buf
%

    if nargin<3 || isempty(calidata)
        calidata = '.\zcaliData_sepfit.mat';
    end

    if ischar(calidata)
        calidata = load(calidata);
    end

    ret1 = CalPwithAst(plist(:,1), zlist, calidata.caliresult_1);
    ret2 = CalPwithAst(plist(:,2), zlist, calidata.caliresult_2);
    ret3 = CalPwithAst(plist(:,3), zlist, calidata.caliresult_3);
    
    result = cat(2, ret1, ret2, ret3);
end

function result = CalPwithAst(plist, zlist, caliresult)
    result = plist - interp2(caliresult.comp_gridz, caliresult.comp_gridp, caliresult.comp_phaseOffset, ...
            zlist, checkPhase(plist),'linear', 0);
end