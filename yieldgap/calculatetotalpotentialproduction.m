function OS=CalculateTotalPotentialProduction(croplist,FS);
% CalculateTotalPotential - Calculate total potential for a list of crops
%
%  Syntax
%          OS=CalculateTotalPotential(croplist,FS);
%
%      where croplist may be one crop or a cell vector of names
%
%
%   calculation carried out for production (tons as harvested) dry
%   production (tons) and calories
%
%   FS must contain fields
%
%   FS.ClimateSpaceRev
%   FS.ClimateSpaceN
%   FS.WetFlag
%   FS.PercentileForMaxYield;
%
%   Optional Field
%   FS.DataYear
%
%  example
%   FS.ClimateSpaceRev='P';
%   FS.ClimateSpaceN=10;
%   FS.PercentileForMaxYield=95;
%   %FS.DataYear=2000;
%   FS.WetFlag='prec';
%
%   OS=CalculateTotalPotentialProduction(sixteencrops,FS)
%
%   C=getcropcharacteristics;
%   mnames=C.CROPNAME;
%  ii=strmatch('coir',mnames);
%mnames=mnames([1:ii-1   ii+1:length(mnames)]);
%ii=strmatch('gums',mnames);
%mnames=mnames([1:ii-1   ii+1:length(mnames)]);
%ii=strmatch('popcorn',mnames);
%mnames=mnames([1:ii-1   ii+1:length(mnames)]);
%
%   OS=CalculateTotalPotentialProduction(mnames,FS)

TotalProductionTons=DataBlank(0);
TotalDryProductionTons=DataBlank(0);
TotalCalorieProduction=DataBlank(0);
SumArea=DataBlank(0);


% code below wants a cell array.  make sure it is one.
if ischar(croplist)
    croplist={croplist};
end




for j=1:length(croplist)
    FS.CropNames=croplist(j);
    
    CC=getcropcharacteristics(croplist(j));
    
    OutputDirBase=[iddstring '/ClimateBinAnalysis/YieldGap/'];
    FileName=YieldGapFunctionFileNames_CropName(FS,OutputDirBase)
    
    x=load(FileName);
    iigood=x.OS.Area > 0 & x.OS.Area < 9e9 ...
        & ~isnan(x.OS.potentialyield) & ~isnan(x.OS.Area);
    Production=x.OS.potentialyield.*x.OS.Area;
    DryProduction=x.OS.potentialyield.*x.OS.Area.*CC.Dry_Fraction;
    TotalProductionTons(iigood)=TotalProductionTons(iigood)+Production(iigood);
    TotalDryProductionTons(iigood)=TotalDryProductionTons(iigood)+DryProduction(iigood);

    SumArea(iigood)=SumArea(iigood)+x.OS.Area(iigood);
end
TotalPotentialProductivity=TotalProductionTons./SumArea;
TotalDryPotentialProductivity=TotalDryProductionTons./SumArea;
iigood=SumArea>0 & ~isnan(TotalPotentialProductivity);;
TotalPotentialProductivity(~iigood)=NaN;
TotalDryPotentialProductivity(~iigood)=NaN;

OS.CropList=croplist;
OS.TotalProductionTons=TotalProductionTons;
OS.TotalPotentialProductivity=TotalPotentialProductivity;
OS.TotalDryPotentialProductivity=TotalDryPotentialProductivity;
OS.SumArea=SumArea;


