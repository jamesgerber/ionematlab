function [BinMatrix,ClimateDefs]=...
    ClimateDataStructureToClimateBins(CDS,Heat,Prec,CultivatedArea,HeatFlag,WetFlag);
% ClimateDataStructureToClimateBins
%
%  Called by MakeClimateSpaceLibraryFunctionRevH

DataQualityGood=(isfinite(CultivatedArea) & CultivatedArea>eps & isfinite(Heat) & isfinite(Prec) );
BinMatrix=0*Heat;

for j=1:length(CDS)
    CD=CDS(j);
    ii=find(Prec>=CD.Precmin & Prec < CD.Precmax & ...
        Heat >=CD.GDDmin & Heat < CD.GDDmax & DataQualityGood);
    
    BinMatrix(ii)=j;
    ClimateDefs{j}=...
        ['Bin No ' int2str(j) '.   ' ...
        num2str(CD.GDDmin) '< ' HeatFlag ' <= ' num2str(CD.GDDmax) ',   ' ...
        num2str(CD.Precmin) '< ' WetFlag ' <= ' num2str(CD.Precmax) ];
end