function [iiPUmap,iiDImap]=testCDSpuAllocation(CDSvect)
% testCDSpuAllocation - visually check coverage of admin units.

iiPUmap=datablank;
iiDImap=datablank;

for j=1:numel(CDSvect);
    iipu=CDSvect(j).iiPU;
    iiPUmap(iipu)=iiPUmap(iipu)+1;
    iidi=CDSvect(j).deepakindices;
    iiDImap(iidi)=iiDImap(iidi)+1;
end
    