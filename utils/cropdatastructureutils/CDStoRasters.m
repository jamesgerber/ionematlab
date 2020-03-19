function [yieldmap,areamap,deepakindexmap,CDSindexmap,CDSwithDR3]=CDStoRasters(CDSvect,years,location)
% CDStoRasters - make a raster from a CropDataStructure
% [yield,area,deepakindexmap,CDSindexmap]=CDStoRasters(CDSvect,years)
%
%  or 
% CDStoRasters(CDSvect,years,filesavelocation)


if nargout==0
    mkdir(location)
end

counter=0;
for jyrs=1:numel(years)
    yr=years(jyrs)
    areamap=datablank;
    yieldmap=datablank;
    deepakindexmap=datablank;
    CDSindexmap=datablank;
    for m=1:numel(CDSvect)
        CDS=CDSvect(m);
        if ~isempty(CDS.data)
            idx=find(CDS.data.year==yr);
            
            if numel(idx)==1
                areamap(CDS.deepakindices)=CDS.data.area(idx);
                yieldmap(CDS.deepakindices)=CDS.data.yield(idx);
                deepakindexmap(CDS.deepakindices)=m;
                CDSindexmap(CDS.deepakindices)=m;
            end
        end
        
        if ~isempty(CDS.DR3)
            counter=counter+1;
            CDSwithDR3(counter)=CDS;
        end
        
    end
    if nargout==0;
    save([location '/areamap' int2str(yr)],'areamap');
    save([location '/yieldmap' int2str(yr)],'yieldmap');
    
    end
    
end
if nargout==0
save([location '/deepakindexmap' int2str(yr)],'deepakindexmap');
end