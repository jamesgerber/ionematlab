function [SOVfinite,Output]=removenansfromsov(SOV);
% removenansfromsov 
%
%  [SOVfinite,OS]=removenansfromsov(SOV);
a=fieldnames(SOV);

thisfield=getfield(SOV,a{1});

badindices=logical(zeros(size(thisfield)));   % logical of zeros

for j=1:numel(a);

    fielddata=getfield(SOV,a{j});
    
    badindices=badindices | ~isfinite(fielddata);
    
    numbad(j)=numel(find(~isfinite(fielddata)));
    
end   


Output.fieldnames=a;
Output.numbad=numbad;
Output.keepindices=~badindices;


disp([ num2str(numel(find(badindices))) ' non-finite elements out of ' num2str(numel(fielddata))]);

SOVfinite=subsetofstructureofvectors(SOV,~badindices);
