function result = findPeakPhase(pdata, binsize)
    if nargin <2
        binsize = 200;
    end
    [ty, tx] = hist(checkPhase(pdata), binsize);
%     tp = find(ty == max(ty));
    result = tx(ty == max(ty));
    result = result(1);
end