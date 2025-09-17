function tiffwrite(A,FileStr,idx)
%% Writting a row*column*N matrix to a stack of tiff image
% ****************************************************************
% tiffwrite(A);
% tiffwrite(A,FileStr);
% tiffwrite(A,FileStr,idx);
% ****************************************************************
% Author:ZYD,IBP,CAS 11/30/2009

if nargin==1
[filename, pathname] = uiputfile( ...
    {'*.tif;*.tiff', 'All TIF-Files (*.tif,*.tiff)'; ...
        '*.*','All Files (*.*)'}, ...
    'Save Image File');
if isequal([filename,pathname],[0,0])
    return
else
    if isempty(strfind(filename,'.tif'))
        filename=strcat(filename,'.tif');
    end
    FileStr = fullfile(pathname,filename);
end
end

if exist(FileStr,'file')
    delete(FileStr);
end
tfilestr = [FileStr '.tmp'];

ImageNumber=length(A(1,1,:));
if nargin==3
    index=idx;
    if length(index)==1
       T=uint16(A(:,:,index));
       imwrite(T,tfilestr,'tif','Compression','none','WriteMode','overwrite');
    else
       n=index(2)-index(1)+1;
       v=index(1):index(2);
       if(ImageNumber>1)
        h=waitbar(0,'Writting images,please wait...');
       end
       for j=1:n
           T=uint16(A(:,:,v(j)));
           imwrite(T,tfilestr,'tif','Compression','none','WriteMode','append');
           if(ImageNumber>1)
            waitbar(j/n);
           end
%             pause(0.0001);
       end
%        close(h);
%        pause(eps)
    end
else
    if(ImageNumber>1)
        h=waitbar(0,'Writting images,please wait...');
    end
    for j=1:ImageNumber
        T=uint16(A(:,:,j));
        imwrite(T,tfilestr,'tif','Compression','none','WriteMode','append');
        if(ImageNumber>1)
            waitbar(j/ImageNumber);
        end
%         pause(0.0001);
    end    
%     close(h);
%     pause(eps)
end

movefile(tfilestr,FileStr);
if(ImageNumber>1)
    close(h);
end
pause(eps);
