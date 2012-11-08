function YieldGapToNetCDF(filename,extrainfo)
% YieldGapToNetCDF - turn yield gap codes into a bunch of netcdfs
%
% Syntax
%
%   YieldGapToNetCDF(filename,'extrainfo')  will put string extrainfo into
%   filename
%
% Example
%
% a=dir('YieldGap_*.mat');
% for j=1:length(a);
%  YieldGapToNetCDF(a(j).name);
%  !gzip *.nc
% end
% 
% %% see other examples at end of code base itself

if nargin<2
    extrainfo='';
end


load(filename,'OS','FS');

clear DAS

DAS.CodeRevision=[ num2str(OS.RevData.CodeRevisionNo)];
DAS.ProcessingDate=[ OS.RevData.ProcessingDate];
DAS.FullFileNameKey=filename;
DAS.ClimateSpaceRevision=FS.ClimateSpaceRev;
DAS.PercentileForMaxYield=FS.PercentileForMaxYield;

%ShortFileBase=makesafestring(['YieldGap_' OS.cropname]);
[a,b]=fileparts(filename);
ShortFileBase=[makesafestring(b) extrainfo];


DAS.Description='Climate Bins';
WriteNetCDF(single(OS.ClimateMask),'BinMatrix',[ShortFileBase '_BinMatrix.nc'],DAS);

DAS.Units='tons/ha';
DAS.Description='Yield Potential';
WriteNetCDF(single(OS.potentialyield),'YieldPotential',[ShortFileBase '_YieldPotential.nc'],DAS);

MissingYield=OS.potentialyield-OS.Yield;
MissingYield(MissingYield<0)=0;

DAS.Description='Yield Gap'
WriteNetCDF(single(MissingYield),'YieldGap',[ShortFileBase '_YieldGap.nc'],DAS);

!gzip -f *.nc


return


%%% example code

C=ReadGenericCSV('croptype_NPK.csv',2);

%for j=1:length(C.CROPNAME);
    for j=[1:41 43:45 47:119 121:length(C.CROPNAME) ]
  %  for j=[1:length(C.CROPNAME)]
    thiscrop=C.CROPNAME{j};
    
    
    
    FS.ClimateSpaceRev='P';
    FS.CropNames=thiscrop;
    FS.ClimateSpaceN=10;
    FS.WetFlag='prec';
    FS.PercentileForMaxYield=95;
    OutputDirBase=[iddstring '/ClimateBinAnalysis/YieldGap/'];
    FileName=YieldGapFunctionFileNames_CropName(FS,OutputDirBase);
    
    
    YieldGapToNetCDF(FileName);
    
end