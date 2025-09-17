function tiffwriteStack(t, filepath)
    h=waitbar(0,'Writing image...');
    width = size(t,2);
    height = size(t,1);
    imglen = size(t,3);

    fp = fopen([filepath '.tmp'],'wb');
    offset = int32(0);
    fwrite(fp,18761,'uint16');%head
    offset = offset+2;
    fwrite(fp,42,'uint16');%42
    offset = offset+2;
    fwrite(fp,offset+4+width*height*2,'uint32');%offset of ifd0
    offset = offset+4;

    for imgcnt = 1:imglen
        waitbar(imgcnt/imglen,h);
        imgoffset = offset;
        timg = t(:,:,imgcnt);
        fwrite(fp, timg', 'uint16');
        offset = offset+length(timg(:))*2;

    %     timg = t(:,:,imgcnt);
        fwrite(fp, 11,'uint16');%
        offset = offset+2;

        fwrite(fp, [256 4],'uint16'); fwrite(fp, 1,'uint32'); fwrite(fp, width,'uint32'); offset = offset+12;   %width
        fwrite(fp, [257 4],'uint16'); fwrite(fp, 1,'uint32'); fwrite(fp, height,'uint32'); offset = offset+12;   %heith
        fwrite(fp, [258 3],'uint16'); fwrite(fp, 1,'uint32'); fwrite(fp, 16,'uint32'); offset = offset+12;   %bitdepth
        fwrite(fp, [259 3],'uint16'); fwrite(fp, 1,'uint32'); fwrite(fp, 1,'uint32'); offset = offset+12;   %compress
        fwrite(fp, [262 3],'uint16'); fwrite(fp, 1,'uint32'); fwrite(fp, 1,'uint32'); offset = offset+12;   %
        fwrite(fp, [273 4],'uint16'); fwrite(fp, 1,'uint32'); fwrite(fp, imgoffset,'uint32'); offset = offset+12;   %strip offset
        fwrite(fp, [278 4],'uint16'); fwrite(fp, 1,'uint32'); fwrite(fp, height,'uint32'); offset = offset+12;   %rows per strip
        fwrite(fp, [279 4],'uint16'); fwrite(fp, 1,'uint32'); fwrite(fp, length(timg(:))*2,'uint32'); offset = offset+12;   %byte cnt
        fwrite(fp, [282 5],'uint16'); fwrite(fp, 1,'uint32'); fwrite(fp, offset+3*12+4,'uint32'); offset = offset+12;   %x
        fwrite(fp, [283 5],'uint16'); fwrite(fp, 1,'uint32'); fwrite(fp, offset+2*12+4+8,'uint32'); offset = offset+12;   %y
        fwrite(fp, [296 3],'uint16'); fwrite(fp, 1,'uint32'); fwrite(fp, 1,'uint32'); offset = offset+12;   %unit
        if(imgcnt ~= imglen)
            fwrite(fp,offset+4+16+length(timg(:))*2,'uint32');   %tail
        else
            fwrite(fp,0,'uint32');   %tail
        end
        offset = offset+4;

        fwrite(fp, [300 1 300 1], 'uint32');
        offset = offset+16;
    %     
    %     fwrite(fp, timg(:), 'uint16');
    %     offset = offset+length(timg(:))*2;

    %     fwrite(fp, zeros(1,16), 'uint8');
    %     offset = offset+16;
    end

    fclose(fp);
    close(h);
    movefile([filepath '.tmp'],filepath);
end