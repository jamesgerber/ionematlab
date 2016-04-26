% Primary Script for N2O Analysis



% list of crops for analysis
[croplist,cropnumlist]=N2OAnalysis_cropnames;

%croplist={'rice_noninundated','rice_inundated','maize','wheat','soybean'};
%cropnumlist=1:5;

extratitleinfo='';
MaxNApp=700;
bins=[1:1:700];
IGNORERICE=0;

%% prepare to populate metavectors
% prepare to populate metavectors - these are vectors which store some data
% for every individual point 

% need to make a map which can be connected to a value for binning.



load([iddstring 'AdminBoundary2010/SageNumberCountryMap'],'SageNumberMap')
countrynumbermap=SageNumberMap;

%load([iddstring 'misc/ContinentMap'],'ContinentMap')
%continentnumbermap=ContinentMap;

load('customregionmap');
continentnumbermap=customregionmap;


% adding a map at the state level
load /Library/IonE/data/AdminBoundary2010/Raster_NetCDF/2_States_5min/ncmat/glctry.mat
statelevelmap=DS.Data;


metaav=[];
metanv=[];
metacountrynum=[];
metacontinentnum=[];
metacropnum=[];
metastate=[];
metaidx=[];
metaDQ=[];


counter=1;
clear FDS FDSv

globalmaxvalue=0;

%% BLANK MATRICES TO POPULATE AS WE GO.

totalarea=datablank(0);
totalNapp=datablank(0);
totalNapp_subnational=datablank(0);
totalNapp_national=datablank(0);
totalNapp_subNapp0=datablank(0);
totalNapp_superNapp0=datablank(0);
totalN2ONLNRR=datablank(0);
totalN2ONLNRR_national=datablank(0);
totalN2ONLNRR_subnational=datablank(0);
totalN2OresponseNLNRR=datablank(0);
totaldN2OdNresponseNLNRR=datablank(0);
totalN2OIPCC=datablank(0);
totalN2OresponseIPCC=datablank(0);
totaldN2OdNresponseIPCC=datablank(0);



totaltruncatedNapp=0;  %this will keep track of how much N is truncated


if IGNORERICE==1
    warndlg([' Ignoring rice IPCC result ']);
end
for j=1:length(croplist)
    
    cropname=croplist{j};
    nutrient='N';

    
    if isequal(cropname(1:min(4,end)),'rice')
        if isequal(cropname,'rice_inundated')
            callcropname='rice';
        elseif isequal(cropname,'rice_noninundated')
            callcropname='rice';
        else
            warndlg('unexpected rice crop.')
            callcropname=cropname;
            
        end
    else
        callcropname=cropname;
    end
        
            
    
    fertcropname=cropname;
    
    if isequal(cropname(1:min(4,end)),'rice')
        fertcropname='rice';
    end
          
    [S,existflag] = getfertdata(fertcropname,nutrient);
 

    if existflag==0
                disp(['no synethic fert for ' cropname])

        % no synthetic data, but we proceed becasue there is manure applied
        Nsynthetic=datablank;;
        NappDQ=NaN;
    else
        Nsynthetic=S.Data(:,:,1);
        NappDQ=S.Data(:,:,2);     
    end
    x=getManure(callcropname);

 %   if existflag==0        
    if (max(nansum(Nsynthetic(:))) +max(nansum(x.N(:))) )==0        
        disp(['no fert for ' cropname])
    else
        

        


        

        legacy=1;
        if legacy==1
         %   warning('manure set to zero')
            Napp=Nsynthetic+x.N;
            ii=isfinite(Napp) & Napp < 9e9 & Napp > 0 ;
        %    length(find(ii))
        %    length(find(Napp>0))
        else
            Napp=Nsynthetic+x.N;
            ii=isfinite(Napp) & Napp < 9e9 & Napp > 0 ;
            Napp=Nsynthetic;
%            length(find(ii))
%            length(find(Napp>0))
        end
        
        c=getdata(cropname);
        croparea=c.Data(:,:,1);
        iigood=ii & croparea < 9e9;
        cropdataquality=c.Data(:,:,2);
        
        cav=croparea(iigood);
        ThisCropNAppVector=Napp(iigood);
        fmav=fma(iigood);
        
        if numel(unique(ThisCropNAppVector))==1
            warndlg([' only one value of NApp for ' cropname ]);
        end
         
        
        ii=find(ThisCropNAppVector>MaxNApp);
        
        totaltruncatedNapp=totaltruncatedNapp+sum( (ThisCropNAppVector(ii)-MaxNApp).*cav(ii).*fmav(ii));

        
        if sum( (ThisCropNAppVector(ii)-MaxNApp).*cav(ii).*fmav(ii)) > 0

            globalmaxvalue=max(globalmaxvalue,max(ThisCropNAppVector(ii)))

            
            disp([' found Napp very large for ' cropname ', total applied N over ' int2str(MaxNApp) ...
                ' kg/ha is ' num2str(sum( (ThisCropNAppVector(ii)-MaxNApp).*cav(ii).*fmav(ii)))]);
            ThisCropNAppVector(ii)=MaxNApp;
            disp([' found largeness for ' cropname ', total applied N is ' num2str(sum( (ThisCropNAppVector).*cav.*fmav))]);
  

        end
        

        
        % now figure out how much national, how much subnational
        q=c.Data(:,:,3);

        iisubnational=q > 0.5 & q < 9e10 ;
        iinational=q <=0.5   ;
 
        % this allows to determine how much applied above/below a
        % particular amount.
        iisuperNapp0= q <= 0.5 & q < 9e10 & isfinite(Napp) & Napp >=60 ;
        iisubNapp0= q <= 0.5 & q < 9e10 & isfinite(Napp) & Napp <60   ;
        
        ThisCropNAppVector_subnational=ThisCropNAppVector;
        ThisCropNAppVector_national=ThisCropNAppVector;
        ThisCropNAppVector_subnational(~iisubnational(iigood))=0;
        ThisCropNAppVector_national(~iinational(iigood))=0;

        
        ThisCropNAppVector_superNapp0=ThisCropNAppVector;
        ThisCropNAppVector_subNapp0=ThisCropNAppVector;
        ThisCropNAppVector_superNapp0(~iisuperNapp0(iigood))=0;
        ThisCropNAppVector_subNapp0(~iisubNapp0(iigood))=0;

        
        ThisCropN2OVectorIPCC=Nfunction(ThisCropNAppVector,'IPCC',callcropname);
        ThisCropN2OresponseVectorIPCC=Nfunction(ThisCropNAppVector,'IPCC',callcropname)./ThisCropNAppVector;
        ThisCropdN2OdNresponseVectorIPCC=Nfunction(ThisCropNAppVector,'derivIPCC',callcropname);
        %         ThisCropN2OVectorNLNRR=Nfunction(ThisCropNAppVector,'meanNLNRR',cropname)...
        %             -Nfunction(0,'meanNLNRR',cropname);
        %         ThisCropN2OresponseVectorNLNRR=Nfunction(ThisCropNAppVector,'meanNLNRRresponse',cropname)./ThisCropNAppVector;
        %         ThisCropdN2OdNresponseVectorNLNRR=Nfunction(ThisCropNAppVector,'derivmeanNLNRR',cropname);
        ThisCropN2OVectorNLNRR=Nfunction(ThisCropNAppVector,'meanNLNRRzyi_ricesep700',callcropname)...
            -Nfunction(0,'meanNLNRRzyi_ricesep700',callcropname);
        ThisCropN2OresponseVectorNLNRR=Nfunction(ThisCropNAppVector,'meanNLNRRzyi_ricesep700',callcropname)./ThisCropNAppVector;
        ThisCropdN2OdNresponseVectorNLNRR=Nfunction(ThisCropNAppVector,'derivmeanNLNRR_ricesep700',callcropname);
        
        totalNapp(iigood)=totalNapp(iigood)+ThisCropNAppVector.*croparea(iigood);
        totalNapp_subnational(iigood)=totalNapp_subnational(iigood)+ThisCropNAppVector_subnational.*croparea(iigood);
        totalNapp_national(iigood)=totalNapp_national(iigood)+ThisCropNAppVector_national.*croparea(iigood);
 
        totalNapp_subNapp0(iigood)=totalNapp_subNapp0(iigood)+ThisCropNAppVector_superNapp0.*croparea(iigood);
        totalNapp_superNapp0(iigood)=totalNapp_superNapp0(iigood)+ThisCropNAppVector_subNapp0.*croparea(iigood);
 
        
        totalarea(iigood)=totalarea(iigood)+croparea(iigood);
        
        totalN2OIPCC(iigood)=totalN2OIPCC(iigood)+ThisCropN2OVectorIPCC.*croparea(iigood);
        totalN2OresponseIPCC(iigood)=totalN2OresponseIPCC(iigood)+ThisCropN2OresponseVectorIPCC.*croparea(iigood);
        totaldN2OdNresponseIPCC(iigood)=totaldN2OdNresponseIPCC(iigood)+ThisCropdN2OdNresponseVectorIPCC.*croparea(iigood);
        totalN2ONLNRR(iigood)=totalN2ONLNRR(iigood)+ThisCropN2OVectorNLNRR.*croparea(iigood);
        totalN2OresponseNLNRR(iigood)=totalN2OresponseNLNRR(iigood)+ThisCropN2OresponseVectorNLNRR.*croparea(iigood);
        totaldN2OdNresponseNLNRR(iigood)=totaldN2OdNresponseNLNRR(iigood)+ThisCropdN2OdNresponseVectorNLNRR.*croparea(iigood);
       % max(max(totalN2OIPCC));
       % max(max(totalN2ONLNRR));
        
        ignorehistogramstuff=0;
        
        if ignorehistogramstuff==0
        %% here is code for histograms

        
        av=double(cav.*fmav);
        nv=ThisCropNAppVector;
        
        edges=[0:.5:700];
        FDS.Napp=(edges(2:end) + edges(1:end-1) )/2;
        M=awhist(nv,av,edges);
        FDS.cropname=cropname;
        FDS.totalN=sum(M.distbyweightedval);
        FDS.N2OresponseIPCC=Nfunction(FDS.Napp,'IPCC',callcropname);
        FDS.N2OresponseNLNRR=Nfunction(FDS.Napp,'meanNLNRRzyi_ricesep700',callcropname);
        FDS.edges=edges;
        FDS.distbyweightedval=M.distbyweightedval;
        FDS.distbyweight=M.distbyweight;
        
        FDSv(counter)=FDS;
        counter=counter+1;
        
        metacountrynum=[metacountrynum ; countrynumbermap(iigood)];
        metacropnum=[metacropnum ; cropnumlist(j)*ones(size(find(iigood)))];
        metacontinentnum=[metacontinentnum ; continentnumbermap(iigood)];
        metaav=[metaav ;av];
        metanv=[metanv ; nv];
        metastate=[metastate ; statelevelmap(iigood)];
        metaidx=[metaidx ; find(iigood)];
%        metaDQ=[metaDQ ; NappDQ(iigood)];
        end
    end
end
FDSvCropname=FDSv;
save FDSvCropname FDSv FDSvCropname
metaav=double(metaav);
metanv=double(metanv);
%save metavectors_all      metaav metanv  
save metavectors metacountrynum metacropnum  metacontinentnum  metaav metanv metastate metaidx


totaltruncatedNapp;

totalNapp_perha=totalNapp./totalarea;
totalN2OIPCC_perha=totalN2OIPCC./totalarea;
totalN2OresponseIPCC_perha=totalN2OresponseIPCC./totalarea;
totaldN2OdNresponseIPCC_perha=totaldN2OdNresponseIPCC./totalarea;
totalN2ONLNRR_perha=totalN2ONLNRR./totalarea;
totalN2OresponseNLNRR_perha=totalN2OresponseNLNRR./totalarea;
totaldN2OdNresponseNLNRR_perha=totaldN2OdNresponseNLNRR./totalarea;

sum(metanv.*metaav)
sumtotalNapp=sum(sum(totalNapp.*fma))


sumtotalNapp_national=sum(sum(totalNapp_national.*fma))
sumtotalNapp_subnational=sum(sum(totalNapp_subnational.*fma))

sumtotalNapp_subNapp0=sum(sum(totalNapp_subNapp0.*fma))
sumtotalNapp_superNapp0=sum(sum(totalNapp_superNapp0.*fma))


sumtotalNappFromMaps=sum(sum(totalNapp.*fma))
sumtotalN2OIPCCFromMaps=sum(sum(totalN2OIPCC.*fma))
sumtotalN2ONLNRRFromMaps=sum(sum(totalN2ONLNRR.*fma))
%%

save working_makeresponsemaps_allcrops

%%%load working_makeresponsemaps_allcrops
%%  make plots


% 3 quantities of interest:
%
%1  total N2O in units of kg/ha
%2  total N2O response in units of kg N2O vs kg Napp
%3  incremental N2O response in units of Delta kg N2O / Delta kg Napp

%maps 2 and 3 are the same for IPCC, different for NLNRR
% also, note that since it is a response, must subtract off Napp=0.
clear NSS
NSS.cmap='eggplant';
NSS.panoplytriangles=[0 1];
NSS.caxis=[0 300];
NSS.units='kg N ha^{-1}';
NSS.makeplotdatafile='on';
nsg(totalNapp_perha,NSS,'filename',['Total applied N ' extratitleinfo ' '])
%nsg(totalNapp_perha,NSS,'title',['Total applied N ' extratitleinfo ' '],'filename','on')

%%

clear NSS
NSS.cmap='poppy';
NSS.panoplytriangles=[0 1];
NSS.caxis=[0 2.5];
NSS.units='kg N_20-N ha^{-1}';
%NSS.title=[' Total N_2O response.  Linear (IPCC)  model. ' extratitleinfo ' '];
NSS.filename='TotalN2OIPCC';
NSS.makeplotdatafile='on';
NSS.userinterppreference='tex';

nsg(totalN2OIPCC_perha,NSS);




%%
clear NSS
NSS.makeplotdatafile='on';

NSS.cmap='poppy';
NSS.panoplytriangles=[0 1];
NSS.caxis=[0 2.5];
NSS.units='kg N_2O-N ha^{-1}';
NSS.title=[' Total N_2O response. NLNRR_{700} model '];
NSS.filename=['TotalN2ONLNRR' extratitleinfo];
NSS.userinterppreference='tex';

nsg(totalN2ONLNRR_perha,NSS);
% % % % 
% % % % 
% % % % %% those are difficult to see.  maybe a relative figure?
% % % % 
% % % % clear NSS
% % % % NSS.cmap='jet';
% % % % NSS.title=[' Relative N2O emissions change: (NLNRR)/IPCC ' extratitleinfo ' '];
% % % % NSS.caxis=[.5 2];
% % % % NSS.units='kg/kg';
% % % % NSS.filename=['relN2Oemissionschange extratitleinfo]';
% % % % NSS.panoplytriangles=[0 1];
% % % % 
% % % % nsg((totalN2ONLNRR_perha)./(totalN2OIPCC_perha),NSS);
% % % % 
% % % % 
% % % % %% those are difficult to see.  maybe a relative figure?
% % % % 
% % % % clear NSS
% % % NSS.cmap='jet';
% % % NSS.title=[' Relative N2O emissions change: (NLNRR)/IPCC ' extratitleinfo ' '];
% % % NSS.caxis=[0 2];
% % % NSS.units='kg/kg';
% % % NSS.filename='relN2Oemissionschange0to2';
% % % NSS.panoplytriangles=[0 1];
% % % 
% % nsg((totalN2ONLNRR_perha)./(totalN2OIPCC_perha),NSS);
% % 
% % 
% % clear NSS
% % NSS.cmap='revred_white_blue_deep';
% % NSS.title=[' Relative N2O emissions change: (NLNRR)/IPCC -1 ' extratitleinfo ' '];
% % NSS.caxis=[-.5 1];
% NSS.units='kg/kg';
% NSS.modifycolormap='stretch';
% 
% NSS.filename='relN2Oemissionschange_minusone';
% NSS.panoplytriangles=[1 1];
% 
% nsg((totalN2ONLNRR_perha)./(totalN2OIPCC_perha)-1,NSS);


% % 
% % %% now try subtracting off?
% % 
% % clear NSS
% % NSS.cmap='revred_white_blue_deep';
% % NSS.title=[' Relative N2O emissions change: (NLNRR - IPCC) ' extratitleinfo ' '];
% % NSS.caxis=[-.5 1.5];
% % NSS.modifycolormap='stretch';
% % NSS.units='kg';
% % NSS.filename='absN2Oemissionschange';
% % NSS.panoplytriangles=[0 0];
% % 
% % nsg((totalN2ONLNRR_perha)-(totalN2OIPCC_perha),NSS);


%%
cmap='redpurpblue';
clear NSS
NSS.makeplotdatafile='on';

nsg(totalN2OresponseIPCC_perha,'title',[' Total N_2O response to unit change, linear (IPCC) method ' extratitleinfo ' '],'units','kg/kg','caxis',[0 .015],'filename','on','cmap',cmap);
nsg(totalN2OresponseNLNRR_perha,'title',[' Total N_2O response to unit change, non-linear method ' extratitleinfo ' '],'units','kg/kg','caxis',[0 .015],'filename','on','cmap',cmap);

%%
% categorical map with different values

%totaldN2OdNresponseNLNRR_perha;
%totaldN2OdNresponseIPCC_perha;

clear NSS
NSS.cmap='revred_white_blue_deep';
%NSS.title=[' Incremental N2O response ' extratitleinfo ' '];
NSS.title=[' Change in N_2O in response to change in N application.  NLNRR _{700} model. ' extratitleinfo ' '];
NSS.userinterppreference='tex'
NSS.caxis=[0.005 .025];
NSS.modifycolormap='stretch';
NSS.stretchcolormapcentervalue=0.01;
NSS.units='kg N_2O-N kg^{-1} ';
NSS.filename=['dN2OdN_emissionschange_NLNRR' extratitleinfo];
NSS.panoplytriangles=[0 1];
NSS.makeplotdatafile='on';
nsg(totaldN2OdNresponseNLNRR_perha,NSS);

%%
% % %%
% % clear NSS
% % NSS.cmap='revred_white_blue_deep';
% % NSS.title=[' Relative incremental N2O response ' extratitleinfo ' '];
% % NSS.caxis=[0 3];
% % NSS.modifycolormap='stretch';
% % NSS.stretchcolormapcentervalue=1;
% % NSS.units='kg/kg';
% % NSS.filename='relative_dN2OdN_emissionschange';
% % NSS.panoplytriangles=[0 1];
% % nsg(totaldN2OdNresponseNLNRR_perha./totaldN2OdNresponseIPCC_perha,NSS);

%%
%map of who emits more/less
clear NSS
NSS.cmap='dark_orange_white_purple_deep';
NSS.title=[' N_2O emissions difference:   IPCC model - NLNRR model'  ' '];
NSS.caxis=[-0.05 0.2];
NSS.modifycolormap='stretch';
NSS.stretchcolormapcentervalue=0;
NSS.units='kg N_2O-N/ha';
    NSS.userinterppreference='tex'

NSS.filename='absdifference_N2O_emissionschange';
NSS.panoplytriangles=[1 1];
nsg((totalN2OIPCC_perha-totalN2ONLNRR_perha).*totalarea,NSS);

%%

% % % % % 
% % % % % 
% % % % % % total applied Napp
% % % % % 
% % % % % % now histograms
% % % % % 
% % % % % % first some stacked histograms from FDS
% % % % % x=FDSv(1).Napp;
% % % % % yNapp=FDSv(1).distbyweight;
% % % % % yN20IPCC=FDSv(1).distbyweight;
% % % % % yN20NLNRR=FDSv(1).distbyweight;
% % % % % for j=1:length(FDSv)
% % % % %     yNapp(j,:)=FDSv(j).distbyweightedval;
% % % % %     yN20IPCC(j,:)=FDSv(j).distbyweightedval.*FDSv(j).N2OresponseIPCC./x;
% % % % %     yN20NLNRR(j,:)=FDSv(j).distbyweightedval.*FDSv(j).N2OresponseNLNRR./x;
% % % % % end
% % % % % figure
% % % % % h=bar(x,yNapp','stacked')
% % % % % 
% % % % % % now final bins
% % % % % DEL=40;
% % % % % END=300;
% % % % % FBC=[20:DEL:END]
% % % % % FBE=[1:DEL:END Inf]
% % % % % 
% % % % % 
% % % % % Nc = 140;  % used to be 139.  not sure why loop below crashes now.
% % % % % 
% % % % % for m=1:length(FBC);
% % % % %     ii=find(x>=FBE(m) & x <=FBE(m+1));
% % % % %     meanofx(m)=mean(x(ii));
% % % % %     yNapp_forplot(1:Nc,m)=sum(yNapp(:,ii),2);
% % % % %     yN20IPCC_forplot(1:Nc,m)=sum(yN20IPCC(:,ii),2);
% % % % %     yN20NLNRR_forplot(1:Nc,m)=sum(yN20NLNRR(:,ii),2);
% % % % % end
% % % % % 
% % % % % 
% % % % % figure
% % % % % h=bar(FBC,yNapp_forplot'/1e9,'stacked');
% % % % % xlabel(' kg/ha ')
% % % % % ylabel(' mt ')
% % % % % title([' Total applied N. '])
% % % % % xtl=get(gca,'xticklabel')
% % % % % xtl(end,end+1)='+';
% % % % % set(gca,'xticklabel',xtl);
% % % % % 
% % % % % figure
% % % % % h=bar(FBC,yN20IPCC_forplot'/1e9,'stacked');
% % % % % xlabel(' kg/ha ')
% % % % % ylabel(' mt ')
% % % % % title([' Total N_2O response (linear (IPCC) method). '])
% % % % % xtl=get(gca,'xticklabel')
% % % % % xtl(end,end+1)='+';
% % % % % set(gca,'xticklabel',xtl);
% % % % % 
% % % % % figure
% % % % % h=bar(FBC,yN20NLNRR_forplot'/1e9,'stacked');
% % % % % xlabel(' kg/ha ')
% % % % % ylabel(' mt ')
% % % % % title([' Total N_2O response (non-linear method). '])
% % % % % xtl=get(gca,'xticklabel')
% % % % % xtl(end,end+1)='+';
% % % % % set(gca,'xticklabel',xtl);
% % % % %     
% % % % % %%
% % % % % % now same thing, but with a sum statement to take away colors
% % % % % figure
% % % % % h=bar(FBC,sum(yNapp_forplot'/1e9,2),'stacked');
% % % % % xlabel(' kg/ha ')
% % % % % ylabel(' mt ')
% % % % % title([' Total applied N. ' extratitleinfo])
% % % % % xtl=get(gca,'xticklabel')
% % % % % xtl(end,end+1)='+';
% % % % % set(gca,'xticklabel',xtl);
% % % % % fattenplot
% % % % % grid on
% % % % % OutputFig('Force')
% % % % % 
% % % % % figure
% % % % % h=bar(FBC,sum(yN20IPCC_forplot'/1e9,2),'stacked');
% % % % % xlabel(' kg/ha ')
% % % % % ylabel(' mt ')
% % % % % title([' Total N_2O response (linear (IPCC) method). ' extratitleinfo])
% % % % % xtl=get(gca,'xticklabel')
% % % % % xtl(end,end+1)='+';
% % % % % set(gca,'xticklabel',xtl);
% % % % % fattenplot
% % % % % grid on
% % % % % OutputFig('Force')
% % % % % 
% % % % % figure
% % % % % h=bar(FBC,sum(yN20NLNRR_forplot'/1e9,2),'stacked');
% % % % % xlabel(' kg/ha ')
% % % % % ylabel(' mt ')
% % % % % title([' Total N_2O response (''NLNRR'' method). ' extratitleinfo])
% % % % % xtl=get(gca,'xticklabel')
% % % % % xtl(end,end+1)='+';
% % % % % set(gca,'xticklabel',xtl);
% % % % % fattenplot
% % % % % grid on
% % % % % OutputFig('Force')
% % % % % 
% % % % % %% now two scenario histogram
% % % % % figure
% % % % % w=.3;
% % % % % x=7.5
% % % % % h1=bar(FBC,sum(yN20IPCC_forplot'/1e9,2),w,'g','stacked');
% % % % % 
% % % % % hold on
% % % % % h2=bar(FBC+x,sum(yN20NLNRR_forplot'/1e9,2),w,'stacked');
% % % % % 
% % % % % xlabel(' kg/ha ')
% % % % % ylabel(' mt ')
% % % % % title([' Total N_2O response. ' extratitleinfo])
% % % % % legend([h1 h2],{'IPCC','NLNRR'})
% % % % % xtl=get(gca,'xticklabel')
% % % % % xtl(end,end+1)='+';
% % % % % set(gca,'xticklabel',xtl);
% % % % % fattenplot
% % % % % grid on
% % % % % 
% % % % % OutputFig('Force')
% % % % % 
% % % % % figure
% % % % % 
% % % % % FDSvCropname=FDSv;
% % % % % 
% % % % % %% now make a histogram from 
% % % % % 
% % % % % 
% % % % % 
% % % % % 
