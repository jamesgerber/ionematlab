function [GDD]=...
    MakeGDDRev2(tmean,Tmin,Tmax,StartDay,EndDay,prec);
%  MakeGDD - Calculate GDD, Prec on GDD, and GSL
%
%
%   SYNTAX:
%
%       [GDD,PrecWhenGDD,GSL]=MakeGDD(tmean,Tmin,StartDay,EndDay);
%
%   EXAMPLE:
%[Long,Lat,tmean]=OpenNetCDF(...
%    '/Library/IonE/data/Climate/WorldClim_5min_tmean.nc');
%[Long,Lat,prec]=OpenNetCDF(...
%    '/Library/IonE/data/Climate/WorldClim_5min_prec.nc');
%
%       for Tmin=[0:12];
%       [GDD,PrecwhenGDD,GSL]=MakeGDDAndPrecip(tmean,Tmin,1,365,prec);
%       save(['GDD' num2str(Tmin)], 'GDD','PrecwhenGDD')
%       save(['GSL' num2str(Tmin)], 'GDD','PrecwhenGDD')
%       DAS.DateProcessed=date;
%       DataName=['GDD' num2str(Tmin)];
%       FileName=['GDD' num2str(Tmin) '.nc'];
%       DAS.Description=['Growing Degree Days based on Tmin=' ...
%       num2str(Tmin)]
%       DAS.Units='Degrees C - day'
%       WriteNetCDF(Long,Lat,GDD,DataName,FileName,DAS);
%       DAS.Units='mm';
%       DAS.Description=['Precipitation on Growing Degree Days based on ' ...
%       'Tmin= ' num2str(Tmin)]
%       DataName=['PrecWhenGDD' num2str(Tmin)];
%       FileName=['PrecWhenGDD' num2str(Tmin) '.nc'];
%       WriteNetCDF(Long,Lat,PrecwhenGDD,DataName,FileName,DAS);
%       DAS.Description=['Growing Season Length based on ' ...
%       'Tmin= ' num2str(Tmin)]
%       DataName=['GSL' num2str(Tmin)];
%       FileName=['GSL' num2str(Tmin) '.nc'];
%       WriteNetCDF(Long,Lat,GSL,DataName,FileName,DAS);
%       end

if nargin<2;help(mfilename);return;end

if nargin<3
  StartDay=1;
end

if nargin<4
  EndDay=365;
end

smv=datenum(0,1:12,0,0,0,0);
emv=datenum(0,2:13,0,0,0,0);
MidMonthVector=(smv+emv)/2;
MidMonthVector(end+1)=MidMonthVector(1)+365;  % Tack January onto the end
MidMonthVector(2:end+1)=MidMonthVector;  % create a space at the
                                       % beginning
MidMonthVector(1)=MidMonthVector(end-1)-365;  % tack Dec. at the beginning
MonthIndexVector=[12 1:12 1];
iiv=[1:14];
mmv=MidMonthVector;

DayVector=[StartDay:EndDay];

zeromatrix=zeros(size(tmean,1),size(tmean,2));

GDDMatrix         =zeromatrix;
PrecWhenGDDMatrix =zeromatrix;
GSLMatrix         =zeromatrix;

NumDaysInMonth=[31 28 31 30 31 30 31 31 30 31 30 31];

for Day=DayVector;
  % express each day as a linear superposition of two months.
  
  FractionalMonth=interp1(mmv,iiv,Day);
  FirstMonthIndex=floor(FractionalMonth);
  SecondMonthFraction=FractionalMonth-floor(FractionalMonth);
  FirstMonthFraction=1-  SecondMonthFraction;
  CalendarFirstMonthIndex=MonthIndexVector(FirstMonthIndex);
  CalendarSecondMonthIndex=MonthIndexVector(FirstMonthIndex+1);
  
  % explanation of previous code by example:  if Day = 20 (e.g. 15%
  % of the way from mid-january to mid-february, mix 85% of the
  % January temperature and 15% of the February temperature to get
  % the temperature for the 20th day.
  
  TemperatureMatrix=tmean(:,:,1,CalendarFirstMonthIndex)*FirstMonthFraction+...
      tmean(:,:,1,CalendarSecondMonthIndex)*SecondMonthFraction;
  
  PrecipitationMatrix=...
      prec(:,:,1,CalendarFirstMonthIndex)*FirstMonthFraction/NumDaysInMonth(CalendarFirstMonthIndex)+...
      prec(:,:,1,CalendarSecondMonthIndex)*SecondMonthFraction/NumDaysInMonth(CalendarSecondMonthIndex);

  
  
  GDDContribution=max(TemperatureMatrix-Tmin,zeromatrix);
  GDDContribution=min(GDDContribution,datablank(Tmax-Tmin));
  LogicalGDDContribution=GDDContribution>0;
  PrecWhenGDDContribution=PrecipitationMatrix.*double(LogicalGDDContribution);
  %maximize agains zeromatrix to assure that we only add positive contributions
  GDDMatrix=GDDMatrix+GDDContribution;
  PrecWhenGDDMatrix=PrecWhenGDDMatrix+PrecWhenGDDContribution;
  GSLMatrix=GSLMatrix+LogicalGDDContribution;
  Day
end


GDD=GDDMatrix;
MissingValue=tmean(1,1,1,1);
ii=find(tmean(:,:,1,1)==MissingValue);
GDD(ii)=MissingValue;

PrecWhenGDD=PrecWhenGDDMatrix;
PrecWhenGDD(ii)=MissingValue;
GSL=GSLMatrix;
GSL(ii)=MissingValue;

