function data=generatepppforclimatebin(binnumber)
%binnumber=1

% some settings


%%%%
% This function uses the 5x5 climate bins and the 5x5 maize yield gaps to
% generate a histogram and a map figure for the climate bin specified in
% the input.

% Example: climatebin_ppp(19)
%Specify a bin number 1 - 25

% 12/04/2015, MO, Global Landscapes Initiative, Institute on the
% Environment, University of Minnesota



PPPMax=300;

delPPP=20;
60000;

%%%%LOAD DATA HERE%%%%%
%load global gdp purchasing power parity
load([iddstring '/misc/PerCapitaGDPv10.nc.mat'])
gdp=DS(1).Data;


%load n application
[S,existflag] = getfertdata('maize','N');
f=S.Data(:,:,1);
gdp=f;
%load climate bins
load([iddstring '/ClimateBinAnalysis/ClimateLibrary/ClimateMask_maize_GDD8_prec_5x5_RevP.mat'])
bin=BinMatrix;

%load maize yield gap
load([iddstring '/ClimateBinAnalysis/YieldGap/ContourFiltered/YieldGap_maize_2000_BaseGDD_8_MaxYieldPct_95_ContourFilteredClimateSpace_5x5_prec.mat'])
yg=OS.YieldGapFraction;
% a meaning area
a=OS.Area;

%% first make map - then we can pull out colormap


select_bin=(bin==binnumber);
titlestr = sprintf('Climate bin %d',binnumber);
%title(titlestr);

%generate map
bin_ppp = (gdp.*select_bin);
bin_ppp = +bin_ppp;
bin_ppp(bin_ppp==0)=NaN;
NSS.Title = titlestr;
NSGS=nsg(bin_ppp,NSS,'caxis',[0 PPPMax]);




%% area-weighted histogram

% %generate histogram
% figure
% hist(gdp(select_bin))
% titlestr = sprintf('Climate bin %d',binnumber);
% title(titlestr);



%%generate area weighted histogram
%aw=awhist(gdp,a,1:5000:PPPMax); % Mariana - this was wrong.  next line limited to bin.
aw=awhist(gdp(select_bin),a(select_bin),1:delPPP:PPPMax);
figure(99)

%axes(hax);
    [jp,EES]=subplot_mp(5,5,binnumber,1);
for j=1:length(aw.bincenters);

    x=aw.bincenters(j);
    y=aw.distbyweight(j);
    
    hl=line([x x],[0 y]);
   % hl=bar([x ],[ y],4);
    hold on
    N=size(NSGS.cmap_final,1);
    ThisColorIndex= floor(N* (x-NSGS.coloraxis(1))/(NSGS.coloraxis(2)-NSGS.coloraxis(1)))+1;
    ThisColorIndex=min(ThisColorIndex,N-1);  % can't over run, and last value is no data
    ThisColorIndex=max(ThisColorIndex,2);  % can't underrun, and first value is ocean
    
    newcolor=NSGS.cmap_final(ThisColorIndex,:);
    
    set(hl,'Color',newcolor,'linewidth',2);
end
hold off
    
%bar(aw.bincenters,aw.distbyweight);




titlestr = sprintf('Area weighted, Climate bin %d',binnumber);


return
%%
for j=1:25
    generatepppforclimatebin(j)
  %  pause   
end
