function [TE,TMI,PEmonthly]= MakeThornthwaitePE(tmean,annualmeanprec);
%  MakeThornthwaitePE - Calculate Thornthwaite potential evaporation
%
%
%   SYNTAX:
%
%       [TE,TMI]= MakeThornthwaitePE(tmean,annualmeanprec);
%
%   EXAMPLE:
%[Long,Lat,tmean]=OpenNetCDF(...
%    '/Library/IonE/data/Climate/WorldClim_5min_tmean.nc');
%[Long,Lat,prec]=OpenNetCDF(...
%    '/Library/IonE/data/Climate/WorldClim_5min_prec.nc');
%
%    annualmeanprec=sum(prec,4)/12;
%
%       [TE,TMI]= MakeThornthwaitePE(temp,annualmeanprec);
%       save(['Thornthwaite'], 'TE','TMI')
%       clear DAS
%       DAS.DateProcessed=date;
%       DataName=['TE'];
%       FileName=['TE.nc'];
%       DAS.Description=['Thornthwaite Potential Evaporation']
%       WriteNetCDF(Long,Lat,TE,DataName,FileName,DAS);
%       end

%      annualmeantemp=sum(tmean,4)/12;


if nargin<2;help(mfilename);return;end

%TEMatrix         =zeros(size(tmean,1),size(tmean,2));;
AnnualThermalIndex       =zeros(size(tmean,1),size(tmean,2));;

%annualmeanprec=sum(prec,4)/12;

[Long,LatVector]=InferLongLat(tmean(:,:,1,1));


NumDaysInMonth=[31 28 31 30 31 30 31 31 30 31 30 31];

% first go through monthly to calculate I
for Month=1:12;
  TemperatureMatrix=tmean(:,:,1,Month);
  TemperatureMatrix(TemperatureMatrix<0)=0;
  AnnualThermalIndex=AnnualThermalIndex+(TemperatureMatrix./5).^(1.514);
end

I=AnnualThermalIndex;

clear TemperatureMatrix;
clear AnnualThermalIndex;
%now determine a
a=(6.75e-7)*I.^3-(7.71e-5)*I.^2+(1.792e-2)*I+0.49239;
TE=a*0;

%now get monthly ET values
for Month=1:12
    
    monthlymeantemp=tmean(:,:,1,Month);
    monthlymeantemp(monthlymeantemp<0)=0;
    
    %Correction factors
    dmonth=NumDaysInMonth(Month)/30;  %correction factor.
    J=sum(NumDaysInMonth(1:Month))-15;  %CumulativeNumDays;
    dhours=single(CBMDaylight(J,LatVector)/12);
    dhoursmatrix=repmat(dhours(:).',2*length(dhours),1);     

    ThisMonth=16*dmonth*dhoursmatrix.*(10*monthlymeantemp./I).^a;
    PEmonthly(:,:,Month)=ThisMonth;
    TE=TE+ThisMonth;
end

%TE=sum(PEmonthly(:,:,:),3);
%annualmeantemp(annualmeantemp<0)=0;
TMI=annualmeanprec./TE;

return



