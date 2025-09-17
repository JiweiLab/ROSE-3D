function [binmap, pselist] = makeDistHist3D(plist, segframe, pairlist, imgsize, zoom, binz, binmapsize,CUDAthread)
    if nargin<8 || isempty(CUDAthread)
        CUDAthread = 1024; %default thread per block
    end
    if nargin<7 || isempty(binmapsize)
        binmapsize = 20; %default binmap size
    end
    if nargin<6 || isempty(binz)
        binz = 10; %default bin z (10 nm)
    end
    if nargin<5 || isempty(zoom)
        zoom = 15; %default zoom xy (10 nm for 150 nm pixelsize)
    end
    zoomz = 1/binz;
    
    % check parameters
    assert(size(plist,2) == 4, 'makeDistHist3D: plist MUST be a n*4 array (x,y,z,frame)');
    assert(isscalar(segframe), 'makeDistHist3D: segframe MUST be a scalar');
    assert(size(pairlist,2) == 2, 'makeDistHist3D: pairlist MUST be a n*2 array');
    assert(isscalar(imgsize), 'makeDistHist3D: imgsize MUST be a scalar');
    assert(isscalar(zoom), 'makeDistHist3D: zoom MUST be a scalar');
    assert(isscalar(binz), 'makeDistHist3D: binz MUST be a scalar');
    assert(isscalar(binmapsize), 'makeDistHist3D: binmapsize MUST be a scalar');
    assert(isscalar(CUDAthread), 'makeDistHist3D: CUDAthread MUST be a scalar');
    
    [binmap, pselist] = GPUBin3DMex(single(plist),double(imgsize),double(zoom),double(zoomz), ...
        double(binmapsize),int32(pairlist-1),double(segframe),double(CUDAthread));
    %                                    ***
    
    pselist = double(pselist);
end