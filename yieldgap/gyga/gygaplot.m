function x=gygaplot(filename)
%This function will allow you to take a table from gyga and plot data
%distribution for crop yields. This data can be found at www.yieldgap.org
% MO 12/22/2015 Global Landscapes Initative @ Institute on the Environment.

g=readgenericcsv(filename)

yw=g.YW;
yp=g.YP;
cz=g.CLIMATEZONE;
binlist=unique(cz);
croplist=unique(g.CROP);

% ii=strmatch('Rainfed maize',g.CROP);

for icrop=1:length(croplist)
    crop_match=strncmpi(thiscrop,'Irr',3);
    
    thiscrop=croplist(icrop);

    ii=strmatch(thiscrop,g.CROP);
    figure
    
    for ibin=1:length(binlist)
        thisbin=binlist(ibin);
        jj=find(cz==thisbin);
    
        kk=intersect(ii,jj);
    
        if length(kk)>0
            if crop_match==0
               
                plot(ibin,yw(kk),'o');
                title(thiscrop);
            else
                plot(ibin,yp(kk),'o');
                title(thiscrop);
            
            %plot(thisbin,yw(kk),'o');
            end

        end
        hold on
    end    
end
