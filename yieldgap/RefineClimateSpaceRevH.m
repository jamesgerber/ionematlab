function [BinMatrix,ClimateDefs,CDS]=RefineClimateSpaceRevH(Heat,Prec, ...
						  Area,CDS,xbins,ybins,ContourMask);
%RefineClimateSpaceRevH
%
%   called from MakeClimateSpaceLibraryFunctionRevH
%
%  [BinMatrix,ClimateDefs,CDS]=RefineClimateSpaceRevH(Heat,Prec,Area,CDS);
%
%
%

DataQualityGood=(isfinite(Area) & Area>eps & isfinite(Heat) & isfinite(Prec) );

N=sqrt(length(CDS));

for k=1:N
    tmparea=0;
for j=1:N; %N+2; %  climate bin away from an edge (if N>2)

    m=N*(j-1)+k;
    ii=find(Prec>=CDS(m).Precmin & Prec < CDS(m).Precmax & ...
    Heat >=CDS(m).GDDmin & Heat < CDS(m).GDDmax & DataQualityGood);

areavect(j,k)=sum(Area(ii));
tmparea=tmparea+sum(Area(ii));
end
tmparea
end

keyboard
