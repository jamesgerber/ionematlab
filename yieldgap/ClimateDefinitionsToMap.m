function ClimateMask=ClimateDefinitionsToMap(heat, prec, CDS, mask);
% ClimateDefinitionsToMap - get climate bins based on GDD/Precip cutoffs
%
% ClimateMask=ClimateDefinitionsToMap(heat, prec, CDS, mask);
%
%   See also MAKECLIMATESPACE   [they are similar functions]
%
%
%  % Example:  
%  %probably doesn't work.  i'm doing this without being able to
%  %test it.  You can yell at me.
% 
% thiscrop='maize';
% FS.ClimateSpaceRev='P';
% FS.CropNames=thiscrop;
% FS.ClimateSpaceN=10;
% FS.WetFlag='prec';
% FS.PercentileForMaxYield=95;
% OutputDirBase=[iddstring '/ClimateBinAnalysis/YieldGap/'];
% 
%     % OutputDirBase=['~/sandbox/ClimateChangePEGASUSWork/RecalculateEverything/ClimateSpace0/YieldGaps/'];
%     FileName=YieldGapFunctionFileNames_CropName(FS,OutputDirBase);
%     
%     
%     x=load(FileName);
%     py=x.OS.potentialyield;
%     
%     % now extend the yield
%     
%     % first need to make a full climate mask
%     
%     ClimateMaskFile=['/Volumes/ionedata/ClimateBinAnalysis/ClimateLibrary/' x.OS.ClimateMaskFile '.mat'];
%     y=load(ClimateMaskFile);
%     cmask=ClimateDefinitionsToMap(y.GDD,y.Prec,y.CDS);
%     
%  %   cmask=x.OS.ClimateMask;
%     vpy=x.OS.VectorOfPotentialYields;
%     epy=datablank(NaN);
%     
%     for ibin=1:length(vpy);
%         ii=cmask==ibin;
%         epy(ii)=vpy(ibin);
%     end
    
    
    
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