function [yieldmap,areamap,deepakindexmap,CDSindexmap,CDSwithDR3]=CDStoRasters_allocatetomap(CDSvect,years,areamap,location)
% CDStoRasters - make a raster from a CropDataStructure
% [yield,area,deepakindexmap,CDSindexmap]=CDStoRasters(CDSvect,years)
%
%  or 
% CDStoRasters(CDSvect,years,filesavelocation)



persistent gadm0codes namelist0 raster0 uniqueadminunitcode0 
persistent gadm1codes namelist1 raster1 uniqueadminunitcode1 
persistent gadm2codes namelist2 raster2 uniqueadminunitcode2

if isempty(namelist0)
load ~/sandbox/jsg015_GlobalAdministrativeAreas/gadmver36/gadm36_level0raster5minVer0.mat
load ~/sandbox/jsg015_GlobalAdministrativeAreas/gadmver36/gadm36_level1raster5minVer0.mat
load ~/sandbox/jsg015_GlobalAdministrativeAreas/gadmver36/gadm36_level2raster5minVer0.mat
end



if nargin==3
    % not clear if we were called as
%    CDStoRasters_allocatetomap(CDSvect,years,location)
%    or
%    CDStoRasters_allocatetomap(CDSvect,years,areamap)
    
    if ischar(areamap)
        location=areamap;
        
        x=load('/ionedata/cropmask/ncmat/Cropland2005_5m.mat');
        areamap=x.Svector(3).Data;
    else
        % do nothing ... wasn't a string, so assume it's a map 
    end
end

if nargin==2
    x=load('/ionedata/cropmask/ncmat/Cropland2005_5m.mat');
    areamap=x.Svector(3).Data;
end
    
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
                
                % define iiPU - set of indices corresponding to this
                % political unit.  if GADM available choose that, otherwise
                % choose deepak units.   Keep count of how often GADM
                % chosen.
                C=CDS;  % easy coding below

                if isempty(CDS.sage.deepakindices)
                    % this is a gadm situation
                    
                    
                    
                    C=CDS;  % easy coding below
                    % look for GID_2 first
                    if isfield(C.gadm,'GID_2')
                        idxC=strmatch(C.gadm.GID_2,gadm2codes);
                        if numel(idxC)~=1
                            error
                        end
                        iiPU=find(raster2==uniqueadminunitcode2(idxC));
                    elseif isfield(C.gadm,'GID_1')
                        idxC=strmatch(C.gadm.GID_1,gadm1codes);
                        if numel(idxC)~=1
                            error
                        end
                        iiPU=find(raster1==uniqueadminunitcode1(idxC));
                    elseif isfield(C.gadm,'GID_0')
                        idxC=strmatch(C.gadm.GID_0,gadm0codes);
                        if numel(idxC)~=1
                            error
                        end
                        iiPU=find(raster0==uniqueadminunitcode0(idxC));
                        
                    else
                        disp([' how did we get here??? '])
                        keyboard
                    end
                else
                    
                    if ~isfield(C.gadm,'GID_1')
                        % if we are here, there are deepak indices ... but
                        % it's a GADM country ... so let's use GADM0
                        % indices
                        
                        idxC=strmatch(C.gadm.GID_0,gadm0codes);
                        if numel(idxC)~=1
                            error
                        end
                        iiPU=find(raster0==uniqueadminunitcode0(idxC));

                    else
                    
                    iiPU=CDS.deepakindices;
                    end
                end
                
                    % areamap(iiPU)=CDS.data.area(idx);
                    yieldmap(iiPU)=CDS.data.yield(idx);
                    deepakindexmap(iiPU)=m;
                    CDSindexmap(iiPU)=m;
                    
                    %     thisarea=CDS.data.area(idx)
                    % to allocate area ... want the property that
                    %sum(areamap(iiPU).*fma(iiPU)=CDS.data.area(idx);
                    % also want proportional allocation
                    areamap(iiPU)=iiPU*CDS.data.area(idx)./sum(iiPU.*fma(iiPU));
                    debugflag=1;
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