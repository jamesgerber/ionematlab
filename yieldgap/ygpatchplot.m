function [xvect,yvect]=ygpatchplot(CDS,Vector)
% YGPatchPlot - make a patch plot given a vector and a CDS structure
%
%  basedir= ...
%  '/Users/jsgerber/sandbox/jsg003_YieldGapWork/DeltaClimate/ClimateSpace0/YieldGaps/ContourFiltered'
%
%  load([basedir '/' 'YieldGap_MaizeHiIncome_MaxYieldPct'...
%  '_95_ContourFilteredClimateSpace_5x5_prec.mat']);
% figure
% ygpatchplot(OS.CDS,OS.VectorOfPotentialYields);
% title([OS.cropname]);
% caxis([0 10])
% colorbar
% finemap('yield')

for ibin=1:length(CDS)
    
    S=CDS(ibin);
    x(1)=S.GDDmin;
    x(2)=S.GDDmin;
    x(3)=S.GDDmax;
    x(4)=S.GDDmax;
    x(5)=S.GDDmin;
    
    y(1)=S.Precmin;
    y(2)=S.Precmax;
    y(3)=S.Precmax;
    y(4)=S.Precmin;
    y(5)=S.Precmin;
    x=double(x);y=double(y);
    
    xvect(ibin)=mean([S.GDDmin S.GDDmax]);
    yvect(ibin)=mean([S.Precmin S.Precmax]);
    
    patch(x,y,Vector(ibin)*[1 1 1 1 1],Vector(ibin));
end


return

Filter='ContourFiltered'
Filter='AreaFiltered'
nbyn='10x10'
crop='Maize'; cax=[0 13];


basedir= ...
    ['/Users/jsgerber/sandbox/jsg003_YieldGapWork/DeltaClimate/ClimateSpace0/YieldGaps/' Filter]

load([basedir '/' 'YieldGap_' crop 'LoIncome_MaxYieldPct'...
    '_95_' Filter 'ClimateSpace_' nbyn '_prec.mat']);
figure
ygpatchplot(OS.CDS,OS.VectorOfPotentialYields);
title([OS.cropname]);
caxis(cax)
zeroxlim(0,8000);
zeroylim(0, 3500);
colorbar
finemap('revsixteencolors')

load([basedir '/' 'YieldGap_' crop 'HiIncome_MaxYieldPct'...
    '_95_' Filter 'ClimateSpace_' nbyn '_prec.mat']);
figure
ygpatchplot(OS.CDS,OS.VectorOfPotentialYields);
title([OS.cropname]);
caxis(cax)
zeroxlim(0,8000);
zeroylim(0, 3500);
colorbar
finemap('revsixteencolors')

load([basedir '/' 'YieldGap_' crop '_MaxYieldPct'...
    '_95_' Filter 'ClimateSpace_' nbyn '_prec.mat']);
figure
ygpatchplot(OS.CDS,OS.VectorOfPotentialYields);
title([OS.cropname]);
caxis(cax)
zeroxlim(0,8000);
zeroylim(0, 3500);
colorbar
finemap('revsixteencolors')


load([basedir '/' 'YieldGap_soybeanLoIncome_MaxYieldPct'...
    '_95_ContourFilteredClimateSpace_5x5_prec.mat']);
figure
ygpatchplot(OS.CDS,OS.VectorOfPotentialYields);
title([OS.cropname]);
caxis([0 4])
zeroxlim(0,8000);
zeroylim(0, 3500);
colorbar
finemap('revsixteencolors')


load([basedir '/' 'YieldGap_soybeanHiIncome_MaxYieldPct'...
    '_95_ContourFilteredClimateSpace_5x5_prec.mat']);
figure
ygpatchplot(OS.CDS,OS.VectorOfPotentialYields);
title([OS.cropname]);
caxis([0 4])
zeroxlim(0,8000);
zeroylim(0, 3500);
colorbar
finemap('revsixteencolors')

load([basedir '/' 'YieldGap_soybean_MaxYieldPct'...
    '_95_ContourFilteredClimateSpace_5x5_prec.mat']);
figure
ygpatchplot(OS.CDS,OS.VectorOfPotentialYields);
title([OS.cropname]);
caxis([0 4])
zeroxlim(0,8000);
zeroylim(0, 3500);
colorbar
finemap('revsixteencolors')