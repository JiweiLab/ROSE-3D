function [result, dyeList] = calDemix3_3D(intlist1, intlist2, colorflag)
% classify dyes with demixing text3 method, using two hard threshold to
% determin the AF647 and CF660
%colorflag: 2: AF647 & CF660C or AF647 & CF680
%colorflag: 3: AF647 & CF660C & CF680 (default)
    if nargin<3
        colorflag = 3;
    end
%     demixdata = load('..\MultiColor\demix_240914_647_660_680_crosstalk1.mat');
    demixdata = load('.\demix_647_660_680_crosstalk1_241106.mat');
    if colorflag ==2
        intmin = 1;
%         demixdata = load('..\MultiColor\demix_240914_647_660_680_crosstalk1.mat');
        thresholdList = demixdata.thresholdList;
        dyeList = demixdata.dyeList;

        intdiff = real(log10(intlist1) - log10(intlist2));

        result=zeros(size(intlist1));
        result(intdiff<thresholdList(1)) = 1;
        result(intdiff>thresholdList(2)) = 2;
        result(intdiff>=thresholdList(1) & intdiff<=thresholdList(2)) = 0;
        result(intlist1<intmin | intlist2<intmin) = 0;
    elseif colorflag ==3
        disp('NOTICE: calDemix3: There is up-to 1% crosstalk between channels.');
        intmin = 1;
%         demixdata = load('..\MultiColor\demix_240914_647_660_680_crosstalk1.mat');
        thresholdList = demixdata.thresholdList;
        dyeList = demixdata.dyeList;

        intdiff = real(log10(intlist1) - log10(intlist2));

        result=zeros(size(intlist1));
        result(intdiff<thresholdList(1)) = 1;
        result(intdiff>thresholdList(2) & intdiff<thresholdList(3)) = 2;
        result(intdiff>thresholdList(4)) = 3;
        result(intdiff>=thresholdList(1) & intdiff<=thresholdList(2)) = 0;
        result(intdiff>=thresholdList(3) & intdiff<=thresholdList(4)) = 0;
        result(intlist1<intmin | intlist2<intmin) = 0;
    else
%         demixdata = load('..\MultiColor\demix_240914_647_660_680_crosstalk1.mat');
        result=ones(size(intlist1));
        dyeList = demixdata.dyeList;
    end
    
end