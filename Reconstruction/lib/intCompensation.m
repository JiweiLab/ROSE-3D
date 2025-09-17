function result = intCompensation(xlist, ylist, intlist, intCompFile)
    if nargin<4 || ~exist(intCompFile, 'file')
        intCompFile = '..\PreProcess\IntComp.mat';
    end
    if ~exist(intCompFile, 'file')
        disp('Warning: NO Int Compensation File Find!')
        result = intlist;
        return
    end
    data = load(intCompFile);
    compbuf = data.compbuf;
    xrange = data.xrange;
    yrange = data.yrange;
    xx = data.xx;
    yy = data.yy;
    s = size(xx);
    
    xlist = round(xlist) - xrange(1) +1;
    ylist = round(ylist) - yrange(1) +1;
    
    tmask = xlist>=1 & xlist<=s(2) & ylist>=1 & ylist<=s(2);
    
    indlist = sub2ind(s, ylist(tmask),xlist(tmask));
    
    result = intlist;
    for m=1:size(intlist,2)
%         temp = intlist(tmask, m);
        
        tcomp = compbuf(:,:,m);
        compdata = tcomp(indlist);
        
        result(tmask, m) = intlist(tmask, m) ./ compdata;
    end
end