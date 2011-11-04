function StemPlotOfPotentialYieldInClimateSpace(cropname,potpercentstr,...
    wetflag)

% function StemPlotOfPotentialYieldInClimateSpace(cropname,potpercentstr,...
%     wetflag)
%
% cropname = lowercase crop name (e.g. maize')
%
% potpercentstr = e.g. '95' or '50' ... indicates yield percentile to look
% up from yield gap output
%
% wetflag = 'TMI' or 'prec'
%


climspace = '10x10';
disp(['loading ' cropname ' ' climspace ' ' potpercentstr ...
    'th percentile potential yields and climate mask']);
FNS.ClimateSpaceRev = 'P';
FNS.ClimateSpaceN=10;
FNS.WetFlag=wetflag;
OutputDirBase=[iddstring 'ClimateBinAnalysis/YieldGap'];
FNS.CropNames = cropname;
FNS.PercentileForMaxYield=potpercentstr;
FileName=YieldGapFunctionFileNames_CropName(FNS,OutputDirBase);
load(FileName);

N=FS.ClimateSpaceN;

TotalArea=NaN*ones(N,N);

c=1;
CultivatedArea=OS.Area;
clear x y z

for iG=1:N;
    for iP=1:N;
        ibin=(iG-1)*N+iP;
        
        GDDBinCenters(iG)= (OS.CDS(ibin).GDDmin+OS.CDS(ibin).GDDmax)/2;
        PrecBinCenters(iP)=(OS.CDS(ibin).Precmin+OS.CDS(ibin).Precmax)/2;
        
        
        x(c)=GDDBinCenters(iG);
        y(c)=PrecBinCenters(iP);
        
        ii=find(OS.ClimateMask==ibin & CropMaskLogical);
        
        TotalArea(iG,iP)=sum(CultivatedArea(ii));
        z(c)=sum(CultivatedArea(ii));
        c=c+1;
    end
end

figure
stem3(x,y,OS.VectorOfPotentialYields)
xlabel('GDD');
ylabel('Precipitation')
