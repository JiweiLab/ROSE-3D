function filelist = getFileList_Fusion_2cam(filepath)
% filelist = getFileList(filepath)
% get file list of a imge series for fusion sCMOS
% file name like: spool(1).tif, spool(2).tif ..
%
% tpos = strfind(filepath, '(');
% tpos = tpos(end);
tpos2 = strfind(filepath, '\');
tpos2 = tpos2(end);

% fileprefix = filepath(1:tpos);
filepolder = filepath(1:tpos2);

filedirlist = dir(sprintf('%s*_A*MMStack_Pos0*.tif', filepolder));
filecnt = len(filedirlist);
fileidx = ones(filecnt, 1).*-1;
filelist = cell(filecnt, 1);

for m=1:filecnt
    tfile = filedirlist(m);
    filename = strcat(filepolder, tfile.name);
    tp1 = strfind(filename, 'MMStack_Pos0');
    tp1 = tp1(end);
    tp2 = strfind(filename, '.ome.tif');
    if isempty(tp2)
        continue
    else
        tp2 = tp2(end);
    end
    
    midname = filename((tp1+12):(tp2-1));
    
%     disp(midname)
    if isempty(midname)
        fileidx(m)=0;
        filelist{m} = filename;
    elseif midname(1) == '_' && all(isstrprop(midname(2:end), 'digit'))
        temp = str2double(midname(2:end)) ;
        fileidx(m)=temp;
        filelist{m} = filename;
    else
        fileidx(m)=-1;
        filelist{m} = '';
    end
end

tmask = fileidx>=0;
fileidx = fileidx(tmask);
filelist = filelist(tmask);

[~,I] = sort(fileidx);
filelist = filelist(I);
% filecnt = 1;
% while(1)
%     tfilecnt = filecnt+1;
%     tfilename = sprintf('%s_X%d.tif',fileprefix,tfilecnt); 
%     if exist(tfilename, 'file')
%         filecnt = tfilecnt;
%     else
%         break;
%     end
% end
% 
% filelist = cell(filecnt,1);
% filelist{1} = filepath;
% for m=2:filecnt
%     filelist{m} = sprintf('%s_X%d.tif',fileprefix,m); 
% end

end