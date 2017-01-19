function stackedhistograms(FDSv,legendfieldname,n)
%
%load FDSvCropname.mat
%stackedhistograms(FDSvCropname,'cropname',9);
%
%load FDSvCountries.mat
%stackedhistograms(FDSvCountries,'countryname',8)
%
%load FDSvContinents.mat	
%stackedhistograms(FDSvContinents,'continentname',8);% 
%
%  load



newfigs=1;
morelegible=1;
if nargin==1
    legendfieldname='cropname';
end

if nargin<3
    % n = number to include in legend
    n=6;
end



%%% this used to be at line 40, but i was having a problem when i reset to
%%% FDVSv_orig and assuming it was sorted.
% sort by totalN

totN=[FDSv.totalN];
[dum,ii]=sort(totN,'ascend');
FDSv=FDSv(ii);
totN=[FDSv.totalN];





FDSv_orig=FDSv;

N=length(FDSv);

correctdistbyweight=1

if correctdistbyweight==1
    
for j=1:N
    Ntot=FDSv(j).totalN;
    FDSv(j).distbyweight=FDSv(j).distbyweightedval./FDSv(j).Napp;
end
end


for j=1:N
    TotalNapp(j)=sum(FDSv(j).Napp.*FDSv(j).distbyweight);
    TotalN20IPCC(j)=sum(FDSv(j).distbyweight.*FDSv(j).N2OresponseIPCC); % for sorting later
    TotalN20NLNRR(j)=sum(FDSv(j).distbyweight.*FDSv(j).N2OresponseNLNRR); % for sorting later
end









% first some stacked histograms from FDS
x=FDSv(1).Napp;
yNapp=FDSv(1).distbyweight;
yN20IPCC=FDSv(1).distbyweight;
yN20NLNRR=FDSv(1).distbyweight;
for j=1:N
    yNapp(j,:)=FDSv(j).distbyweightedval;
    yN20IPCC(j,:)=FDSv(j).distbyweightedval.*FDSv(j).N2OresponseIPCC./x;
    yN20NLNRR(j,:)=FDSv(j).distbyweightedval.*FDSv(j).N2OresponseNLNRR./x;
  end
% figure
% h=bar(x,yNapp','stacked')

% now final bins
DEL=40;
END=400;
FBC=[20:DEL:END]
FBE=[1:DEL:END Inf]


for m=1:length(FBC);
    ii=find(x>=FBE(m) & x <=FBE(m+1));
    meanofx(m)=mean(x(ii));
    yNapp_forplot(1:N,m)=sum(yNapp(:,ii),2);
    yN20IPCC_forplot(1:N,m)=sum(yN20IPCC(:,ii),2);
    yN20NLNRR_forplot(1:N,m)=sum(yN20NLNRR(:,ii),2);
end

%%% now pre-arrange legends / custom colors
% N = length FDSv




cmap=copper(N);
cmap=cmap(N:-1:1,:);  % reverse it.

cmap=cmap*0+[.4];



%% first map.  Don't need to resort.
[dum,ii]=sort(TotalNapp,'ascend');
FDSv=FDSv_orig(ii);
TotalNappsorted=TotalNapp(ii);


for j=N:-1:(N-n+1);
    
%    color=cropcolor(FDSv(j).cropname);
%    legvect{j}=[FDSv(j).cropname ' ' num2str(TotalNappsorted(j)/1e6,3)];  

    legendstring=getfield(FDSv(j),legendfieldname);
        [color,displaystring]=LegendToColor(legendstring);

       % % legendstring=strrep(legendstring,'rice_irr75', 'irrigated rice');
       % % legendstring=strrep(legendstring,'rice_rf75', 'rainfed rice');

%legvect{j}=[legendstring ' ' num2str(TotalNappsorted(j)/1e6,3)];  
%legvect{j}=[sprintf('%s',displaystring) ' ' sprintf('%5.1f',TotalNappsorted(j)/1e9) ' Tg'];
legvect{j}=[sprintf('%s',displaystring) ' ' twosigfigs(TotalNappsorted(j)/1e9) ' Tg'];

cmap(j,:)=color;
    
end




if newfigs==1
    figure('position',[584   807   806   295]);
else
    figure
    hsp(1)=subplot(3,1,1);
end


h=bar(FBC,yNapp_forplot'/1e9,'stacked');
xlabel(' kg N ha^{-1} ')
ylabel(' Tg N ')
title([' (a) Total applied N  ' ])
%titlestr=sprintf('(a) \t\t\t\t\t%s',' Total applied N. ');
%title(titlestr)
xtl=get(gca,'xticklabel')
xtl(end,end+1)='+';
set(gca,'xticklabel',xtl);
hlegend=legend(h(N:-1:(N-n+1)),legvect(N:-1:(N-n+1)));
colormap(cmap);
grid on
set(hlegend,'LineWidth',1.5)
%legend boxoff  % can't get it to work so turn box off

if morelegible==1;
    hxl=get(gca,'XLabel');
    set(hxl,'FontSize',13)
    set(hxl,'FontWeight','bold')
    hxl=get(gca,'YLabel');
    set(hxl,'FontSize',13)
    set(hxl,'FontWeight','bold')
    hxl=get(gca,'Title');
    set(hxl,'FontSize',15)
    set(hxl,'FontWeight','bold')
    set(gca,'FontSize',13)
  %  ht=text(-40,16.75,' (a) ')
  %  set(ht,'FontSize',15)
  %  set(ht,'FontWeight','bold')
 %   uplegend
 %   uplegend
end


if newfigs==1
    OutputFig('Force',['TotalNapplied' legendfieldname ],'-r150')
    print(['TotalNapplied' legendfieldname ],'-depsc')
end


%% second map.  sort by IPCC

[dum,ii]=sort(TotalN20IPCC,'ascend');
FDSv=FDSv_orig(ii);
TotalN20IPCCsorted=TotalN20IPCC(ii);

%%
%   yNapp_forplot
yN20IPCC_forplot_sorted=yN20IPCC_forplot(ii,:);

%%
for j=N:-1:(N-n+1);
    
    %     color=cropcolor(FDSv(j).cropname);
    %     legvect{j}=[FDSv(j).cropname ' ' num2str(TotalN20IPCCsorted(j)/1e6,3)];
    legendstring=getfield(FDSv(j),legendfieldname);
        [color,displaystring]=LegendToColor(legendstring);

   legendstring=strrep(legendstring,'rice_irr75', 'irrigated rice');
        legendstring=strrep(legendstring,'rice_rf75', 'rainfed rice');

    %  legvect{j}=[legendstring ' ' num2str(TotalN20IPCCsorted(j)/1e6,3)];
    legvect{j}=[sprintf('%s',displaystring) ' ' sprintf('%5.3f',TotalN20IPCCsorted(j)/1e9) ' Tg'];
  %  legvect{j}=[sprintf('%s',displaystring) ' ' twosigfigs(TotalN20IPCCsorted(j)/1e9) ' Tg'];
    
    cmap(j,:)=color;
    
end

if newfigs==1
    figure('position',[584   807   806   295]);
else
    hsp(2)=subplot(3,1,2);
end

h=bar(FBC,yN20IPCC_forplot_sorted'/1e9,'stacked');
xlabel(' kg N ha^{-1} ')
ylabel(' Tg N_2O-N ')
title([' (b) Total N_2O response (Linear model)  '])
xtl=get(gca,'xticklabel')
xtl(end,end+1)='+';
set(gca,'xticklabel',xtl);
hlegend=legend(h(N:-1:(N-n+1)),legvect(N:-1:(N-n+1)));
colormap(cmap);
grid on
set(hlegend,'LineWidth',1.5);

ylims=get(gca,'YLim');

if morelegible==1;
    hxl=get(gca,'XLabel');
    set(hxl,'FontSize',13)
    set(hxl,'FontWeight','bold')
    hxl=get(gca,'YLabel');
    set(hxl,'FontSize',13)
    set(hxl,'FontWeight','bold')
    hxl=get(gca,'Title');
    set(hxl,'FontSize',15)
    set(hxl,'FontWeight','bold')
    set(gca,'FontSize',13)
 %   ht=text(-40,.1675,' (b) ')
 %   set(ht,'FontSize',15)
 %   set(ht,'FontWeight','bold')

 %   uplegend
 %   uplegend
end
if newfigs==1
OutputFig('Force',['TotalN2OresponseIPCC' legendfieldname ],'-r150')
    print(['TotalN2OresponseIPCC' legendfieldname ],'-depsc')

end

%% third map.  sort by NLNRR

[dum,ii]=sort(TotalN20NLNRR,'ascend');
FDSv=FDSv_orig(ii);
TotalN20NLNRRsorted=TotalN20NLNRR(ii);

  yN20NLNRR_forplot_sorted=yN20NLNRR_forplot(ii,:);

for j=N:-1:(N-n+1);

     legendstring=getfield(FDSv(j),legendfieldname);
     
        [color,displaystring]=LegendToColor(legendstring);

     
   legendstring=strrep(legendstring,'rice_irr75', 'irrigated rice');
        legendstring=strrep(legendstring,'rice_rf75', 'rainfed rice');

%    color=cropcolor(FDSv(j).cropname);
%    legvect{j}=[FDSv(j).cropname ' ' num2str(TotalN20NLNRRsorted(j)/1e6,3)];
%     legvect{j}=[sprintf('%-10s',legendstring) ' ' sprintf('%5.0f',TotalN20NLNRRsorted(j)/1e6) ' Mt'];
     legvect{j}=[sprintf('%s',displaystring) ' ' sprintf('%5.3f',TotalN20NLNRRsorted(j)/1e9) ' Tg'];
  %   legvect{j}=[sprintf('%s',displaystring) ' ' twosigfigs(TotalN20NLNRRsorted(j)/1e9) ' Tg'];
    cmap(j,:)=color;
    
end

if newfigs==1
    figure('position',[584   807   806   295]);
else
    hsp(3)=subplot(3,1,3)
end
h=bar(FBC,yN20NLNRR_forplot_sorted'/1e9,'stacked');
xlabel(' kg N ha^{-1} ')
ylabel(' Tg N_2O-N ')
title([' (c) Total N_2O response (NLNRR_{700} method)  '])
xtl=get(gca,'xticklabel')
xtl(end,end+1)='+';
set(gca,'xticklabel',xtl)
hlegend=legend(h(N:-1:(N-n+1)),legvect(N:-1:(N-n+1)));
colormap(cmap);
grid on
set(hlegend,'LineWidth',1.5)
set(gca,'YLim',ylims)
if morelegible==1;
    hxl=get(gca,'XLabel');
    set(hxl,'FontSize',13)
    set(hxl,'FontWeight','bold')
    hxl=get(gca,'YLabel');
    set(hxl,'FontSize',13)
    set(hxl,'FontWeight','bold')
    hxl=get(gca,'Title');
    set(hxl,'FontSize',15)
    set(hxl,'FontWeight','bold')
    set(gca,'FontSize',13)
  %  ht=text(-40,0.1675,' (c) ')
  %  set(ht,'FontSize',15)
  %  set(ht,'FontWeight','bold')

 %   uplegend
 %   uplegend
end
if newfigs==1
    OutputFig('Force',['TotalN2OresponseLNLRR' legendfieldname ],'-r150')
    print(['TotalN2OresponseLNLRR' legendfieldname ],'-depsc')
    
else
    OutputFig('Force',['N2O_threehistograms_' legendfieldname ],'-r150')
end

% 