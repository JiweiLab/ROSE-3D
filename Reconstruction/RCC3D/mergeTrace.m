%merge two traces
function [resultt, resulttx] = mergeTrace(tracebuf, txrange)
tracelen = length(tracebuf);
offsetlist = zeros(tracelen,1);
tracebuf_corr = cell(tracelen, 1);
tracebuf_corr{1} = tracebuf{1};
for tcnt = 1:(tracelen-1)
    t1 = tracebuf_corr{tcnt};
    t2 = tracebuf{tcnt+1};
    tx1range = txrange(tcnt,:);
    tx2range = txrange(tcnt+1,:);
    
    oRange = [tx2range(1), tx1range(2)];%overlap range
    olen = oRange(2)-oRange(1)+1;
    t1_overlap = t1(end-olen+1:end);
    t2_overlap = t2(1:olen);
    t2_offset = mean(t2_overlap-t1_overlap);
    t2=t2-t2_offset;
    
    offsetlist(tcnt+1) = t2_offset;
    tracebuf_corr{tcnt+1} = t2;
end

%merge traces
fs = txrange(1,1);
fe = txrange(end,2);
resulttx = [fs,fe];
flen = fe-fs+1;
resultt = zeros(flen,1);
resulttw = zeros(flen,1);
for m=1:tracelen
    tfs = txrange(m,1)-fs+1;
    tfe = txrange(m,2)-fs+1;
    resultt(tfs:tfe) = resultt(tfs:tfe) + tracebuf_corr{m};
    resulttw(tfs:tfe) = resulttw(tfs:tfe) + 1;
end

resultt = resultt./resulttw;

%% display traces
% plot(txrange(1,1):txrange(1,2), tracebuf_corr{1});
% hold on
% for m=2:tracelen
%     plot(txrange(m,1):txrange(m,2), tracebuf_corr{m});
% end
% hold off


end