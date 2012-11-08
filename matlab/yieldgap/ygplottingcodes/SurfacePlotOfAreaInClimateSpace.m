function SurfacePlotOfAreaInClimateSpace(cropname,potpercentstr,...
    wetflag)

% function StemPlotOfAreaInClimateSpace(cropname,potpercentstr,...
%     wetflag)
%
% cropname = lowercase crop name (e.g. maize')
%
% potpercentstr = e.g. '95' or '50' ... indicates yield percentile to look
% up from yield gap output
%
% wetflag = 'TMI' or 'prec'
%
%%%%% WARNING: NATHAN CHANGED THIS TO POTENTIAL YIELD - CHANGE TO AREA

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


HeatFlag = 'GDD';
N = 10;
TotalArea=NaN*ones(N,N);

c=1;
clear x y z

for iG=1:N;
    for iP=1:N;
        ibin=(iG-1)*N+iP;
        
        GDDBinCenters(iG)= (OS.CDS(ibin).GDDmin+OS.CDS(ibin).GDDmax)/2;
        PrecBinCenters(iP)=(OS.CDS(ibin).Precmin+OS.CDS(ibin).Precmax)/2;
        
        
        x(c)=GDDBinCenters(iG);
        y(c)=PrecBinCenters(iP);
        
        ii=find(OS.ClimateMask==ibin & CropMaskLogical);
        
        TotalArea(iG,iP)=sum(OS.Area(ii));
        z(c)=sum(OS.Area(ii));
        c=c+1;
    end
end

z=z/max(z);
%TotalAreaNorm=TotalArea/sum(sum(TotalArea));

figure('position',[107   654   560   420])
%surface(GDDBinCenters,PrecBinCenters,TotalAreaNorm.');
TAN=TotalArea;
TAN(end+1,end+1)=0;
surf(x,y,OS.VectorOfPotentialYields);
surf(double(reshape(x,10,10)),double(reshape(y,10,10)),...
    double(reshape(OS.VectorOfPotentialYields,10,10)));
% surface(double(reshape(x,10,10)),double(reshape(y,10,10)),...
%     double(reshape(OS.VectorOfPotentialYields,10,10)));
xlabel(HeatFlag);
ylabel(wetflag)
zlabel([cropname ' yield (t/ha)'])
title([cropname ' ' potpercentstr 'th percentile yield in climate space']);
   %   colorbar
%   zeroxlim(GDDBinEdges(1),GDDBinEdges(end));
%   zeroylim(PrecBinEdges(1),PrecBinEdges(end));
untex
