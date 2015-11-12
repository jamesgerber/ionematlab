function viewinputmaps(inputdir)
% viewinputmaps - make maps of files for PEGASUS input

wd=pwd;

    cd(inputdir)

try
    Sv=OpenGeneralNetCDF('awc.nc');
    S=Sv(5);
    
    netcdfmap(S)
    S=Sv(6);
    netcdfmap(S)
    S=Sv(7);
    netcdfmap(S)
    
    S=OpenNetCDF('surta.nc');
    nsg(S.Data,'units',S.units,'title',S.Title,'filename','figures/')
    
    S=OpenNetCDF('vegtype.nc');
    nsg(S.Data,'units',S.units,'title',S.Title,'filename','figures/')
    
    %  prec.clim.nc	surta.nc	topo.clim.nc
    %  sun.clim.nc	temp.clim.nc	vegtype.nc
    

catch
    cd(wd)
    error(lasterr)
end
cd(wd)

function netcdfmap(S)

NSS.title=S.varname;
NSS.filename='figures/';
nsg(S.Data,NSS)

hax=axes('position',[0.4362 0.1938 0.5188 0.1865]);
as=S.Attributes;

y=.05;
dely= .9/length(as);
for j=1:length(as)
    text(.05,y,[as(j).attname '    ' num2str(as(j).attrvalue)],'interpreter','none');
    y=y+dely;
end
set(hax,'XTickLabel',[])
set(hax,'YTickLabel',[])
