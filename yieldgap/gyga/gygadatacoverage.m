function x=gygadatacoverage(filename,ncdf)
%This function shows a map of GYGA data coverage, narrowed down by country
% and climate bin. The input only requires a compiled csv of GYGA data and
% a netcdf that shows global coverage of GYGA's 266 climate zones. Both of
% these datasets can be found at www.yieldgap.org
% 12/22/15, MO, Global Landscapes Initiative @ Institute on the Environment

g=readgenericcsv(filename);
cz=g.CLIMATEZONE;
country=g.COUNTRY;
countrylist=unique(country);

binlist=unique(cz);


x=opengeneralnetcdf(ncdf);
all_cz=x(3).Data;
global_binlist=unique(all_cz);

bin_diff=setdiff(global_binlist,binlist);

global_cz=all_cz;



for j=1:length(bin_diff);
    no_bin=bin_diff(j);
    global_cz(global_cz==no_bin)=0;
end



coutline=countrynametooutline(countrylist);
coutline(coutline>0)=1;
global_cz=single(global_cz);
global_cz=global_cz.*coutline;
nsg(global_cz)
