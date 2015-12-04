%function data=generatepppforclimatebin(binnumber)
binnumber=1

%%%%
% This function uses the 5x5 climate bins and the 5x5 maize yield gaps to
% generate a histogram and a map figure for the climate bin specified in
% the input.

% Example: climatebin_ppp(19)
%Specify a bin number 1 - 25

% 12/04/2015, MO, Global Landscapes Initiative, Institute on the
% Environment, University of Minnesota

%%%%LOAD DATA HERE%%%%%
%load global gdp purchasing power parity
load([iddstring '/misc/PerCapitaGDPv10.nc.mat'])
gdp=DS(1).Data;

%load climate bins
load([iddstring '/ClimateBinAnalysis/ClimateLibrary/ClimateMask_maize_GDD8_prec_5x5_RevP.mat'])
bin=BinMatrix;

%load maize yield gap
load([iddstring '/ClimateBinAnalysis/YieldGap/ContourFiltered/YieldGap_maize_2000_BaseGDD_8_MaxYieldPct_95_ContourFilteredClimateSpace_5x5_prec.mat'])
yg=OS.YieldGapFraction;
% a meaning area
a=OS.Area;


select_bin=(bin==binnumber);

%generate histogram
figure
hist(gdp(select_bin))
titlestr = sprintf('Climate bin %d',binnumber);
title(titlestr);

%generate map
bin_ppp = (gdp.*select_bin);
bin_ppp = +bin_ppp;
bin_ppp(bin_ppp==0)=NaN;
NSS.Title = titlestr;
nsg(bin_ppp,NSS)

%generate area weighted histogram
aw=awhist(gdp,a,1:5000:60000);
figure
bar(aw.bincenters,aw.distbyweight);
titlestr = sprintf('Area weighted, Climate bin %d',binnumber);
title(titlestr);
