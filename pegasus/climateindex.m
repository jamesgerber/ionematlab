%%;Purpose of this script is to create a new NetCDF that includes:
%  2 different indicies for quantifying ecosystem regulation of temp and moisture
%   mask advection data with landsea mask used in PEGASUS
%
%Paul West, TNC/SAGE
% June 2008

%%%% Rewritten by JSG and MO for matlab, 11/10/2015

%%%%In order to to run this, your source folder will need the following.
% 1. moist_climreg.nc   %%%diff btwn no veg and potveg + advQ in mm/day
% 2. diffadeltemp_nvpv.nc  %%%diff btwn no veg and potveg in Celsius
% 3. nceppegasus_5min_100715varpbl.nc %%%NCEP reanalysis from Gemma
                
% 4. diffaclimreg_nvpv.nc %%%diff btwn noveg and potveg runs of old climreg index
% 5. surta.nc   %%%landmask used in PEGASUS



%%%%%%%%%%%%%%%%%
%%Input Data
%%%%%%%%%%%%%%%%%

%moistin=opengeneralnetcdf('moist_climreg.nc');
%%%diff btwn no veg and potveg + advQ in mm/day
%deltempin=opengeneralnetcdf('diffadeltemp_nvpv.nc');
%%%diff btwn no veg and potveg in Celsius
%advTin=opengeneralnetcdf('nceppegasus_10min_060808varpbl.nc');
%%%NCEP reanalysis from Gemma
%cregin=opengeneralnetcdf('diffaclimreg_nvpv.nc');
%%%diff btwn noveg and potveg runs of old climreg index
%lsmin=opengeneralnetcdf('surta.nc');
%%%landmask used in PEGASUS

% % % % % these seem OK
% % % % delQ=moistin(3).Data;
% % % % delH=deltempin(5).Data;
% % % % creg=cregin(5).Data;
% % % % lsdata=lsmin(5).Data; % landsurface.

%lat=lsmin(2).Data;
%long=lsmin(1).Data;

delQ=pullfromnetcdfvector('moist_climreg.nc','aaet_diff');
delQ(delQ>100000)=NaN;
delQ(delQ<-100000)=NaN;
delH=pullfromnetcdfvector('diffadeltemp_nvpv.nc','adeltemp');
creg=pullfromnetcdfvector('diffaclimreg_nvpv.nc','aclimreg');
lsdata=pullfromnetcdfvector('surta.nc','surta');
% messed up / needs to be fixed - doesn't align with grid
x=pullfromnetcdfvector('nceppegasus_10min_060808varpbl.nc','lccT_less_advT');
%x=advTin(4).Data;
x=disaggregate_rate(x,2);
x=x(:,end:-1:1);
advT=x;


%x=advTin(8).Data;
x=pullfromnetcdfvector('nceppegasus_10min_060808varpbl.nc','advQ_ave');
x=disaggregate_rate(x,2);
x=x(:,end:-1:1);
advQ=x;




% % %mask for advection data
% % lsdata(lsdata==0)=NaN;
% % advT=(advT.*lsdata);
% % advQ=(advQ.*lsdata);

% 
advT(lsdata==0)=NaN;
advT(advT==-999)=NaN;
advQ(lsdata==0)=NaN;
advQ(advQ==-999)=NaN;



if length(delH)==2160
    delH=disaggregate_rate(delH,2);
end

if length(delQ)==2160
    delQ=disaggregate_rate(delQ,2);
end

if length(advT)==2160
    advT=disaggregate_rate(advT,2);
end

if length(advQ)==2160
    advQ=disaggregate_rate(advQ,2);
end
%%%%%%%%%%%%%%%
%%Calculations
%%%%%%%%%%%%%%%
%%
% calculate climate regulation index with 'canceling term'
Hindex1= (delH./(abs(delH)+0.000001)) .* (abs(delH)./(abs(delH)+abs(advT)+0.0000001)) .* (abs(delH + advT)./(abs(delH)+abs(advT)+0.000001));
Qindex1= (delQ./(abs(delQ)+0.000001)) .* (abs(delQ)./(abs(delQ)+abs(advQ)+0.0000001)) .* (abs(delQ + advQ)./(abs(delQ)+abs(advQ)+0.000001));

%index that scales LCC effects by advection
Hindex2=delH .* (abs(delH)./(abs(delH)+abs(advT)+0.000001));
Qindex2=delQ .* (abs(delQ)./(abs(delQ)+abs(advQ)+0.000001));


%index that has a sign and the relative magnitude of LCC effects vs. advection
Hindex3= sign(delH) .* (abs(delH)./(abs(delH)+abs(advT)+0.000001));
%old version Qindex3= (delQ/(abs(delQ)+0.000001)) *(abs(delQ)/(abs(delQ)+abs(advQ)+0.000001))
Qindex3= sign(delQ) .*(abs(delQ)./(abs(delQ)+abs(advQ)+0.000001));
% % % % if (all(delQ<0)) then
% % % % 	Qindex3= (-1 * (abs(delQ)/(abs(delQ)+abs(advQ)+0.000001)))
% % % % else 
% % % % 	if (all(delQ>0)) then
% % % % 		Qindex3= (1 * (abs(delQ)/(abs(delQ)+abs(advQ)+0.000001)))
% % % % 	else 
% % % % 		Qindex3= (1/(abs(advQ)+0.000001))
% % % % 	end if
% % % % end if
%%
   
% index that is the ratio of turbulent fluxes to outgoing sw and lw radiation with LCC (noveg-potveg scenarios)
TurbFlux = creg;


%writing output to netcdf
%delete('climregegindex_final.nc');
% nccreate('climregeindex_final.nc','latitude', 'Dimensions',{'latitude' 2160});
% nccreate('climregeindex_final.nc','longitude', 'Dimensions',{'longitude' 4320});
% nccreate('climregeindex_final.nc','avg_advQ', 'Dimensions',{'latitude' 2160 'longitude' 4320});
% nccreate('climregeindex_final.nc','avg_advT', 'Dimensions',{'latitude' 2160 'longitude' 4320});
% nccreate('climregeindex_final.nc','IndexH1', 'Dimensions',{'latitude' 2160 'longitude' 4320});
% nccreate('climregeindex_final.nc','IndexH2', 'Dimensions',{'latitude' 2160 'longitude' 4320});
% nccreate('climregeindex_final.nc','IndexH3', 'Dimensions',{'latitude' 2160 'longitude' 4320});
% nccreate('climregeindex_final.nc','IndexQ1', 'Dimensions',{'latitude' 2160 'longitude' 4320});
% nccreate('climregeindex_final.nc','IndexQ2', 'Dimensions',{'latitude' 2160 'longitude' 4320});
% nccreate('climregeindex_final.nc','IndexQ3', 'Dimensions',{'latitude' 2160 'longitude' 4320});
% nccreate('climregeindex_final.nc','Turb2swlw', 'Dimensions',{'latitude' 2160 'longitude' 4320});
% 
% 
% ncwrite('climregeindex_final.nc','latitude',lat);
% ncwrite('climregeindex_final.nc','longitude',long);
% ncwrite('climregeindex_final.nc','avg_advQ',advQ);
% ncwrite('climregeindex_final.nc','avg_advT',advT);
% ncwrite('climregeindex_final.nc','IndexH1',Hindex1);
% ncwrite('climregeindex_final.nc','IndexQ1',Qindex1);
% ncwrite('climregeindex_final.nc','IndexH2',Hindex2);
% ncwrite('climregeindex_final.nc','IndexQ2',Qindex2);
% ncwrite('climregeindex_final.nc','IndexH3',Hindex3);
% ncwrite('climregeindex_final.nc','IndexQ3',Qindex3);
% ncwrite('climregeindex_final.nc','Turb2swlw',TurbFlux);

Long=[-180:180];
Lat=[-90:90];
% DAS.units='unitless';
% DAS.title='Latitude';
% DAS.missing_value=-9e10;
% DAS.underscoreFillValue=-9e10;
% writenetcdf(lat,'latitude','climregeindex_final.nc',DAS);
% 
% Long=[-180:180];
% Lat=[-90:90];
% DAS.units='unitless';
% DAS.title='Longitude';
% DAS.missing_value=-9e10;
% DAS.underscoreFillValue=-9e10;
% writenetcdf(long,'longtitude','climregeindex_final.nc',DAS);

DAS.units='Celsius';
DAS.title='average daily advected heat';
DAS.missing_value=-9e10;
DAS.underscoreFillValue=-9e10;
writenetcdf(advT,'avg_advT','climregeindex_final_advT.nc',DAS);

DAS.units='mm/day';
DAS.title='average advected moisture';
DAS.missing_value=-9e10;
DAS.underscoreFillValue=-9e10;
writenetcdf(advQ,'avg_advQ','climregeindex_final_advQ.nc',DAS);

DAS.units='unitless';
DAS.title='heat regulating index with sign, relative strength, & canceling term';
DAS.missing_value=-9e10;
DAS.underscoreFillValue=-9e10;
writenetcdf(Hindex1,'IndexH1','climregeindex_final_IndexH1.nc',DAS);

DAS.units='unitless';
DAS.title='moisture regulating index with sign, relative strength, & canceling term';
DAS.missing_value=-9e10;
DAS.underscoreFillValue=-9e10;
writenetcdf(Qindex1,'IndexQ1','climregeindex_final_IndexQ1.nc',DAS);

DAS.units='Celsius';
DAS.title='heat index of LCC delH scaled to advection';
DAS.missing_value=-9e10;
DAS.underscoreFillValue=-9e10;
writenetcdf(Hindex2,'IndexH2','climregeindex_final_IndexH2.nc',DAS);

DAS.units='mm/day';
DAS.title='moisture index of LCC delQ scaled to advection';
DAS.missing_value=-9e10;
DAS.underscoreFillValue=-9e10;
writenetcdf(Qindex2,'IndexQ2','climregeindex_final_IndexQ2.nc',DAS);

DAS.units='unitless';
DAS.title='heat regualting index with sign and relaticve strength of LCC delH and advection';
DAS.missing_value=-9e10;
DAS.underscoreFillValue=-9e10;
writenetcdf(Hindex3,'IndexH3','climregeindex_final_IndexH3.nc',DAS);

DAS.units='unitless';
DAS.title='moisture regualting index with sign and relative strength of LCC delQ and advection';
DAS.missing_value=-9e10;
DAS.underscoreFillValue=-9e10;
writenetcdf(Qindex3,'IndexQ3','climregeindex_final_IndexQ3.nc',DAS);

DAS.units='unitless';
DAS.title='ratio of turbulent fluxes to outgoing sw and lw radiation (noveg-potveg)';
DAS.missing_value=-9e10;
DAS.underscoreFillValue=-9e10;
writenetcdf(TurbFlux,'Turb2swlw','climregeindex_final_Turb2swlw.nc',DAS);
