
for N=[10]

%GDDBinEdges=[0:500:9500 13000];
%GDDBinEdges=[0:1000:9000 13000];
%GDDBinEdges=[0:2000:8000 13000];

x=linspace(0,10000,N+1);
GDDBinEdges=[x(1:end-1) 13000];

[Long,Lat,WorldClimprec]=OpenNetCDF('/Library/IonE/data/Climate/WorldClim_5min_prec.nc');
WorldClimprec=sum(WorldClimprec,4);

for Temp=[5 8 0];

  for jwf=1:3;
    
    switch jwf
     case 1
      WetFlag='prec_on_gdd'
      
      x=linspace(0,3000,N+1);
PrecBinEdges=[x(1:end-1) 10000];
      
      
     case 2
      WetFlag='prec'
    %  PrecBinEdges=[0:150:2850 10000];
    %  PrecBinEdges=[0:300:2700 10000];      
    %  PrecBinEdges=[0:600:2400 10000];
    x=linspace(0,3000,N+1);
    PrecBinEdges=[x(1:end-1) 10000];
     case 3
      WetFlag='aei'
    %  PrecBinEdges=[0:.05:1];      
    %  PrecBinEdges=[0:.1:1];
     % PrecBinEdges=[0:.2:1];
    
          x=linspace(0,1,N+1);
          PrecBinEdges=[x(1:end-1) 1];
    end
    





GDDTempstr=num2str(Temp);



 [Long,Lat,GDD]=OpenNetCDF(['~jsgerber/sandbox/jsg003_YieldGapWork/' ...
		    'GDDLibrary/GDD' GDDTempstr '.nc']);

switch WetFlag
  case 'prec_on_gdd'
   [Long,Lat,PrecOnGDD]=OpenNetCDF(['/Users/jsgerber/sandbox/jsg003_YieldGapWork/GDDLibrary/PrecWhenGDD' ...
		    GDDTempstr '.nc']);
 Prec=PrecOnGDD;
 case 'prec'
  Prec=WorldClimprec;
 case 'aei'
  [Long,Lat,aei]=OpenNetCDF(['/Users/jsgerber/sandbox/' ...
		    'jsg003_YieldGapWork/5min_aei.nc']);
 Prec=aei;
 otherwise
  error
end

%[BinMatrix,GDDBins,PrecBins,ClimateDefs]=MakeClimateSpace(GDD,Prec,GDDBinEdges,PrecBinEdges);
[BinMatrix,GDDBins,PrecBins,ClimateDefs]=MakeClimateSpace(Prec,GDD,PrecBinEdges,GDDBinEdges);

FileName=['GDD' GDDTempstr '_' WetFlag '_' int2str(length(GDDBinEdges)-1) ...
	  'x' int2str(length(PrecBinEdges)-1) '_RevA'];


save(FileName,'BinMatrix','GDDBins','PrecBins','ClimateDefs','GDDBinEdges','PrecBinEdges','Prec','GDD');
DAS.Description='Climate Space Library, Revision A.  October 14, 2009';
WriteNetCDF(Long,Lat,single(BinMatrix),'ClimateMask',[FileName '.nc'],DAS);
end
end
end