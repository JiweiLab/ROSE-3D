function result = myUnwrap2D(phasemap)
    result = phasemap;
    ts = size(result);
    % start point is the center!
    startpoint = [round((ts(2)+1)/2), round((ts(1)+1)/2)]; %x, y
    statmap = zeros(size(result)); %status: 0:unchecked, 1:need check, 2: checked
    wrapmap = zeros(size(result)); 

    statmap(startpoint(2),startpoint(1)) = 1;
    checkList = startpoint;
    checkxlist = [-1, -1, -1, 0, 0, 0, 1, 1, 1];
    checkylist = [-1, 0, 1, -1, 0, 1, -1, 0, 1];
    while(1)
        cpoint = checkList(1,:);
        cx = cpoint(1);
        cy = cpoint(2);
        cval = result(cy,cx);

        %find surroundings
        txlist = cx + checkxlist;
        tylist = cy + checkylist;
        tm = txlist>0 & txlist<=ts(2) & tylist>0 & tylist<=ts(1);
        txlist = txlist(tm);
        tylist = tylist(tm);
        tidxlist = sub2ind(ts, tylist, txlist);
        statlist = statmap(tidxlist);
        tmask = statlist==2;
        vallist = result(tidxlist);
        dvallist = cval - vallist;
        dvallist = dvallist(tmask);
        %check unwrap
        if ~isempty(dvallist)
            temp = mean(dvallist);
%             subplot(2,2,1)
%             plot(dvallist);
            result(cy,cx) = result(cy,cx) + (checkPhase(temp) - temp);
            wrapmap(cy,cx) = temp - checkPhase(temp);
        end
        statmap(cy, cx) = 2;

        % add points
        for m=1:len(tidxlist)
            tidx = tidxlist(m);
            if statmap(tidx) ==0
                checkList = cat(1, checkList, [txlist(m), tylist(m)]);
                statmap(tylist(m), txlist(m)) = 1;
%                 disp(sprintf('add point: %d, %d',tylist(m), txlist(m) ));
            end
        end

        % remove head
        checkList = checkList(2:end,:);
        if isempty(checkList)
            break;
        end
    end
    
end