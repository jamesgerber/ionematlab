function ClimateMask=ClimateDefinitionsToMap(heat, prec, CDS, mask);
% ClimateDefinitionsToMap - get climate bins based on GDD/Precip cutoffs
%
% ClimateMask=ClimateDefinitionsToMap(heat, prec, CDS, mask);
%
%   See also MAKECLIMATESPACE   [they are similar functions]
if nargin<4
    mask=landmasklogical;
end

ClimateMask=datablank(NaN);

for ibin=1:length(CDS)
    CD=CDS(ibin);
    
    Hmin=CD.GDDmin;
    Hmax=CD.GDDmax;
    Pmin=CD.Precmin;
    Pmax=CD.Precmax;

    jj= (heat >= Hmin & heat < Hmax & prec >= Pmin & prec < Pmax & mask);
    
    ClimateMask(jj)=ibin;
end

%%% from MAKECLIMATESPACE
% %         jj=find( T >= Tmin & T <Tmax & W >= Wmin & W <Wmax);
% %         
% %         ClimateBinVector(jj)=ClimateBinNumber;
% %         ClimateDefs{ClimateBinNumber}=...
% %             ['Bin No ' int2str(ClimateBinNumber) '.   ' ...
% %             num2str(Tmin) '< ' TempDataName ' <= ' num2str(Tmax) ',   ' ...
% %             num2str(Wmin) '< ' WaterDataName ' <= ' num2str(Wmax) ];
% %         CDS(ClimateBinNumber).GDDmin=Wmin;
% %         CDS(ClimateBinNumber).GDDmax=Wmax;
% %         CDS(ClimateBinNumber).Precmin=Tmin;
% %         CDS(ClimateBinNumber).Precmax=Tmax;