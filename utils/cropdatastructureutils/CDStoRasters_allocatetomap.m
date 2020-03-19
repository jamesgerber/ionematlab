function [yieldmap,areamap,deepakindexmap,CDSindexmap,CDSwithDR3]=CDStoRasters_allocatetomap(CDSvect,years,cropareamap,location)
% CDStoRasters - make a raster from a CropDataStructure
% [yield,area,deepakindexmap,CDSindexmap]=CDStoRasters(CDSvect,years)
% [yield,area,deepakindexmap,CDSindexmap]=CDStoRasters(CDSvect,years,areamap)
% [yield,area,deepakindexmap,CDSindexmap]=CDStoRasters(CDSvect,years,areamap,location)
% [yield,area,deepakindexmap,CDSindexmap]=CDStoRasters(CDSvect,years,location)
% % use default area map (
%
%
%  or 
% CDStoRasters(CDSvect,years,filesavelocation)


if nargin==3
    % not clear if we were called as
    CDStoRasters_allocatetomap(CDSvect,years,location)
    or
    CDStoRasters_allocatetomap(CDSvect,years,cropareamap)
    
    if ischar(cropareamap)
        location=cropareamap;
        
        x=load('/ionedata/cropmask/ncmat/Cropland2005_5m.mat');
        cropareamap=x.Svector(3).Data;
    else
        % do nothing ... wasn't a string, so assume it's a map 
    end
end


if nargin==2
    x=load('/ionedata/cropmask/ncmat/Cropland2005_5m.mat');
    cropareamap=x.Svector(3).Data;
end
    

cropareamap(cropareamap<0)=0;

    if nargout==0
        mkdir(location)
    end

                    testflag=0;
                debugflag=0;

    
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
                
                % define iiPU - set of indices corresponding to this
                % political unit.  if GADM available choose that, otherwise
                % choose deepak units.   Keep count of how often GADM
                % chosen.
                
                iiPU=CDS.deepakindices;
                 deepakindexmap(CDS.deepakindices)=m;
                CDSindexmap(CDS.iiPU)=m;
               
                
                % areamap(CDS.iiPU)=CDS.data.area(idx);
                yieldmap(iiPU)=CDS.data.yield(idx);
                
                %     thisarea=CDS.data.area(idx)
                % to allocate area ... want the property that
                %sum(areamap(CDS.iiPU).*fma(CDS.iiPU)=CDS.data.area(idx);
                % also want proportional allocation
                
               % % this guarantees proportional to crop area map
               % areamap(CDS.iiPU)=cropareamap(CDS.iiPU)*Normfactor;
                
               % % Normfactor has to have the property that
               % sum(areamap.*fma)=CDS.data.area(idx);
                
               Normfactor= CDS.data.area(idx)./...
                   sum(fma(iiPU).*double(cropareamap(iiPU)));
                
               areamap(iiPU)=cropareamap(iiPU)*Normfactor;
                
                if testflag==1
                    
                    CDS.data.area(idx)
                    sum(areamap(iiPU).*fma(iiPU))
                end
                           
                
                if debugflag==1
                    sum(sum(areamap.*fma))
                end
                
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