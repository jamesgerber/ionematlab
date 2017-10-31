%Revision 2
% hopefully the final.  Will use many types of climate data.


% Revision 3
% IDS files have gotten too large.  making an IDSgateway which saves the
% IDS for each year independently.


%readseibertirrigationfiles('gmia_v5_aei_ha.asc');
%readseibertirrigationfiles('unit_code.asc');
%commented out- already ran these
jumpoutofcodesdir

load ../jsg133_irrigated_area_time_series/data/gmia_v5_aei_ha.mat
gmia=Data;
clear Data

load ../jsg133_irrigated_area_time_series/data/unit_code
unitcode=Data;


clear S


% from SOM of Mueller et al
% We calculate the maximum proportion of crop growing area irrigated in each
% grid cell in order to establish the spatial extent of irrigation technology
% and infrastructure for each crop (this variable is listed as IRR in the
% equations below and mapped for major cereals in Fig. 3b). We utilize the
% MIRCA2000 dataset12 for this calculation, which contains monthly rainfed
% and irrigated areas for our crops of interest. We restrict our search for
% maximum irrigated proportion to months for which the reported crop growing
% area is at least 75% of the maximum in order to exclude anomalous growing
% conditions (e.g. a small area of a particular crop may be cultivated beyond
% of the normal growing season and be 100% irrigated, but this would not reflect
% the extent of irrigation capacity within the main growing season when only 50%
% of the area is irrigated).

% from Deepak:
%" In the case of the Ray and Iizumi data sets, their harvested area per grid
% cell were split into irrigated and rainfed fractions using MIRCA2000?s relative
% shares for a given crop in each 0.5° grid cell. Grid cells, for which MIRCA2000
%     specifies no harvested area for the crop of interest, were assumed to be
%     without irrigation if they contained crops in the original Ray or Iizumi
%     data sets. "
%


% Method I'm going to use:
%
% Use Mueller et al definition of irrigated fraction
%
% Scale irrigated fraction by AEI19XX/AEI2000
%
% Apply irrigated fraction to v8.01 time series of crop data.
%dataver='v1210smoothed';
%yrvect=[1975:5:2005 2008];
dataver='v1210annual';
yrvect=1970:2010;

%dataver='v801smoothed';
%yrvect=[1975:5:2005];
%dataver='v1210smoothed';
%yrvect=[1975:5:2005 2008];
% maize
croplist={'wheat','maize','rice','soybean','wheat','rice','soybean','maize'};
croplist={'wheat','maize','rice','soybean','wheat','rice','soybean','maize'};
%
for jcrop=[2:4];
    if jcrop>4
        dataver='v1210smoothed';
        yrvect=[1975:5:2005 2008];
    end
    clear CRU WC WFDEI
    cropname=croplist{jcrop}
    
    %  if jcrop>=5
    %      yrvect=[1965:5:2005];
    %  end
    areavector  =[];
    yieldvector =[];
    yearvector  =[];
    
    awGDP =[];
    awGDPfixed=[];
    awGDPannual=[]
    awawc20     =[];   %awc20,,,,
    awORC30=[]; %ORC30
    awCEC30=[];%CEC30
    awAWCtS30=[];%AWCtS30
    awAWCh230=[];%AWCH2_30
    
    awirrfrac   =[];
    
    medianadminunit=[];
    politunit=[];
    pc1=[];
    pc2=[];
    pc3=[];
    pc4=[];
    pc5=[];
    awpc1=[];
    awpc2=[];
    awpc3=[];
    awpc4=[];
    awpc5=[];
    awslopebelow10=[];
    awslopeabove30=[];
    %%% climate data
    % WorldClim
    
    WC.awGDDT0=[];
    WC.awGDDTb=[];
    WC.awMAP=[];
    WC.awSRAD=[];
    WC.awVAPR=[];
    WC.awPCI=[];
    WC.awBIO6=[];
    
    awWC=WC;% need to rename ... the 'awCRU' version holds the areaweighted data to go into the tables.  the 'CRU' version holds the raster data.
    clear WC
    
    % CRU Annual
    CRU.y.awGDDT0=[];
    CRU.y.awGDDTb=[];
    CRU.y.awMAP=[];
    CRU.y.awPCI=[];
    CRU.y.awP2PET=[];
    
    
    % CRU Climatology
    
    CRU.c.awGDDT0=[];
    CRU.c.awGDDTb=[];
    CRU.c.awMAP=[];
    CRU.c.awPCI=[];
    CRU.c.awCVP=[];
    CRU.c.awP2PET=[];
    
    awCRU=CRU; % need to rename ... the 'awCRU' version holds the areaweighted data to go into the tables.  the 'CRU' version holds the raster data.
    clear CRU
    
    % Watch Annual
    
    % Watch yearly
    
    WFDEI.y.awKDD29=[];
    WFDEI.y.awKDD30=[];
    WFDEI.y.awKDD31=[];
    WFDEI.y.awKDD32=[];
    WFDEI.y.awKDD33=[];
    WFDEI.y.awKDD34=[];
    WFDEI.y.awKDD35=[];
    WFDEI.y.awGDDT0=[];
    WFDEI.y.awGDDTb=[];
    WFDEI.y.awBIO6=[];
    WFDEI.y.awMAP=[];
    WFDEI.y.awPCI=[];
    WFDEI.y.awSWRAD=[];
    % note for when I have my next brain cramp:  CVP not defined for a single
    % year.
    
    awWFDEI=WFDEI;  % need to rename ... the 'awCRU' version holds the areaweighted data to go into the tables.  the 'CRU' version holds the raster data.
    clear WFDEI
    
    % moving next two lines below: now yearly
    % [KDD29,KDD30,KDD31,KDD32,KDD33,KDD34,KDD35]=loadKDDs;
    [GDDT0,Precip,GDPfixed,awc20,iacv,iidatamask,GDDTb,GSL]=getindependentdata(cropname);
    
    WC=getWorldClimdata(cropname);
    
    
    
    x=load('data/processedslopelayers.mat');
    slopebelow10=x.fractionbelowtenpercentslope;
    slopeabove30=x.fractionabovethirtypercentslope;
    noslopedata=x.alwaysnodata;
    
    [awc20,AWCH2_30,ORC30,CEC30,AWCtS30]=getstaticdata;
    %[GDDT0,Precip,GDPfixed,awc20,iacv,iidatamask,GDDTb,GSL]=getindependentdata(cropname);
    
    
    clear IDS % input data structure   IDS=
    
    for jyr=1:length(yrvect);
        
        if length(yrvect)>10
            clear IDS
            warndlg([' clearing IDS within year loop. ']);
        end
        year=yrvect(jyr)
        thisyear=year;  % too damned lazy to mak var names consistent.  lazy!
        
        [WFDEIyearlydata]=getWFDEIdata(year,cropname);
        CRU=getCRUdata(year,cropname);
        
        %  [GDDT0,GDDTb,Precip,PCI,GSLT0,GSLTb,BIO6]=getyearlyclimatologies(max(year,1980),cropname);
        [NewFractionIRR,GDP]=getirrigationfraction(year,cropname);
        
        %    gslength=GSLT0;
        
        
        [politicalunitlist,adminmap]=getpoliticalunits(cropname,dataver);
        
        [a,yield,iicropmask]=pullcropdata(cropname,year,dataver);
        
        load(['/ionedata/gdp_1960-2014/ncmat/gdp_' num2str(year) '.mat']);
        GDPannual=Svector(3).Data;
        
        load(['~/sandbox/jsg134_FAO_NationalFertData/NationalFertRateMapsRevA/NationalFertRate' num2str(thisyear) '.mat']);
        FertRateAnnual=fertratemap;
        
        
        
        
        IDS(jyr).area=a(agrimasklogical);
        IDS(jyr).yield=yield(agrimasklogical);
        IDS(jyr).year=yrvect(jyr);
        % worldclim climatology
        IDS(jyr).WC_GDDT0=WC.GDDT0(agrimasklogical);
        IDS(jyr).WC_GDDTb=WC.GDDTb(agrimasklogical);
        IDS(jyr).WC_MAP=WC.MAP(agrimasklogical);
        IDS(jyr).WC_SRAD=WC.SRAD(agrimasklogical);
        IDS(jyr).WC_VAPR=WC.VAPR(agrimasklogical);
        IDS(jyr).WC_PCI=WC.PCI(agrimasklogical);
        IDS(jyr).WC_BIO6=WC.BIO6(agrimasklogical);
        
        % CRU climatology
        IDS(jyr).CRU_c_GDDT0=CRU.c.GDDT0(agrimasklogical);
        IDS(jyr).CRU_c_GDDTb=CRU.c.GDDTb(agrimasklogical);
        IDS(jyr).CRU_c_MAP=CRU.c.MAP(agrimasklogical);
        IDS(jyr).CRU_c_PCI=CRU.c.PCI(agrimasklogical);
        IDS(jyr).CRU_c_CVP=CRU.c.CVP(agrimasklogical);
        IDS(jyr).CRU_c_P2PET=CRU.c.P2PET(agrimasklogical);
        % CRU annual
        IDS(jyr).CRU_y_GDDT0=CRU.a.GDDT0(agrimasklogical);
        IDS(jyr).CRU_y_GDDTb=CRU.a.GDDTb(agrimasklogical);
        IDS(jyr).CRU_y_MAP=CRU.a.MAP(agrimasklogical);
        IDS(jyr).CRU_y_PCI=CRU.a.PCI(agrimasklogical);
        IDS(jyr).CRU_y_P2PET=CRU.a.P2PET(agrimasklogical);
        
        % WFDEI annual;
        W=WFDEIyearlydata;
        IDS(jyr).WFDEI_y_KDD29=W.KDD29(agrimasklogical);
        IDS(jyr).WFDEI_y_KDD30=W.KDD30(agrimasklogical);
        IDS(jyr).WFDEI_y_KDD31=W.KDD31(agrimasklogical);
        IDS(jyr).WFDEI_y_KDD32=W.KDD32(agrimasklogical);
        IDS(jyr).WFDEI_y_KDD33=W.KDD33(agrimasklogical);
        IDS(jyr).WFDEI_y_KDD34=W.KDD34(agrimasklogical);
        IDS(jyr).WFDEI_y_KDD35=W.KDD35(agrimasklogical);
        IDS(jyr).WFDEI_y_BIO6=W.BIO6(agrimasklogical);
        IDS(jyr).WFDEI_y_GDDTb=W.GDDTb(agrimasklogical);
        IDS(jyr).WFDEI_y_GDDT0=W.GDD0(agrimasklogical);
        IDS(jyr).WFDEI_y_MAP=W.MAP(agrimasklogical);
        IDS(jyr).WFDEI_y_PCI=W.PCI(agrimasklogical);
        IDS(jyr).WFDEI_y_SWRAD=W.sw_rad(agrimasklogical);
        
        
        IDS(jyr).awc20=awc20(agrimasklogical);
        %       IDS(jyr).PCI=PCI(agrimasklogical);
        IDS(jyr).irrfrac=NewFractionIRR(agrimasklogical);
        IDS(jyr).politicalunitmap=adminmap(agrimasklogical);
        IDS(jyr).politicalunitlist=politicalunitlist;
        
        IDS(jyr).GDPfixed=GDPfixed(agrimasklogical);
        IDS(jyr).GDPannual=GDPannual(agrimasklogical);
        %        IDS(jyr).anomolylist=anomolylist;
        
        IDS(jyr).medianpolitical=adminmap(agrimasklogical);
        
        IDS(jyr).slopebelow10=slopebelow10(agrimasklogical);
        IDS(jyr).slopeabove30=slopeabove30(agrimasklogical);
        
        
        IDS(jyr).ORC30=ORC30(agrimasklogical);
        IDS(jyr).CEC30=CEC30(agrimasklogical);
        IDS(jyr).AWCtS30=AWCtS30(agrimasklogical);
        IDS(jyr).AWCH2_30=AWCH2_30(agrimasklogical);
        
        %         [pc1,pc2,pc3,pc4,pc5]=callpca(IDS(jyr));
        %         IDS(jyr).pc1=pc1;
        %         IDS(jyr).pc2=pc2;
        %         IDS(jyr).pc3=pc3;
        %         IDS(jyr).pc4=pc4;
        %         IDS(jyr).pc5=pc5;
        %
        %         pc1_map=inflate(pc1);
        %         pc2_map=inflate(pc2);
        %         pc3_map=inflate(pc3);
        %         pc4_map=inflate(pc4);
        %         pc5_map=inflate(pc5);
        
        
        iiDataQualityGood=(isfinite(WC.GDDTb) & isfinite(CRU.c.MAP) & ...
            isfinite(WC.PCI) & ...
            isfinite(a.*yield) & isfinite(ORC30) & isfinite(AWCtS30));
        
        IDS(jyr).iiDataQualityGood=iiDataQualityGood(agrimasklogical);
        
        j=0;
        
        jj=adminmap>0 & iiDataQualityGood;
        
        
        for jlist=1:length(politicalunitlist)
            %      jlist
            ii=find(adminmap==politicalunitlist(jlist) & iiDataQualityGood);
            
            if length(ii)>0;
                j=j+1;
                fmavect=fma(ii);
                tmpareavector(j)=sum(a(ii).*fmavect);
                tmpyieldvector(j)=mean(yield(ii));
                tmpyearvector(j)=thisyear;
                
                
                tmpannualFertRate(j)=sum(FertRateAnnual(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);;
                tmpawslopebelow10(j)=sum(slopebelow10(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);;
                tmpawslopeabove30(j)=sum(slopeabove30(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);;
                tmpmedianadminunit(j)=median(adminmap(ii));
                %            tmpawGDP(j)=sum(GDP(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawGDPannual(j)=sum(GDPannual(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawGDPfixed(j)=sum(GDPfixed(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                %           tmpawawc20(j)=sum(awc20(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawORC30(j)=sum(ORC30(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawCEC30(j)=sum(CEC30(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawAWCtS30(j)=sum(AWCtS30(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawAWCh230(j)=sum(AWCH2_30(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawirrfrac(j)=sum(NewFractionIRR(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                % tmpharvInt(j)=sum(harvestintensity(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                % tmppolitunit(j)=j;  WTF was this???
                tmppolitunit(j)=politicalunitlist(jlist);
                
                
                % Worldclim data
                tmpawgddT0_wc(j)=sum(WC.GDDT0(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawgddTb_wc(j)=sum(WC.GDDTb(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawMAP_wc(j)=sum(WC.MAP(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawSRAD_wc(j)=sum(WC.SRAD(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawVAPR_wc(j)=sum(WC.VAPR(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawPCI_wc(j)=sum(WC.PCI(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawBIO6_wc(j)=sum(WC.BIO6(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                
                % CRU - clim
                tmpawgddT0_c_cru(j)=sum(CRU.c.GDDT0(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawgddTb_c_cru(j)=sum(CRU.c.GDDTb(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawMAP_c_cru(j)=sum(CRU.c.MAP(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawPCI_c_cru(j)=sum(CRU.c.PCI(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawCVP_c_cru(j)=sum(CRU.c.CVP(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawP2PET_c_cru(j)=sum(CRU.c.P2PET(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                
                % CRU- ann
                tmpawgddT0_a_cru(j)=sum(CRU.a.GDDT0(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawgddTb_a_cru(j)=sum(CRU.a.GDDTb(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawMAP_a_cru(j)=sum(CRU.a.MAP(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawPCI_a_cru(j)=sum(CRU.a.PCI(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawP2PET_a_cru(j)=sum(CRU.a.P2PET(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                
                
                % WFDEI - ann
                tmpawgddT0_w(j)=sum(W.GDD0(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawgddTb_w(j)=sum(W.GDDTb(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawMAP_w(j)=sum(W.MAP(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawPCI_w(j)=sum(W.PCI(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawSWRAD_w(j)=sum(W.sw_rad(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawBIO6_w(j)=sum(W.BIO6(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawKDD29_w(j)=sum(W.KDD29(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawKDD30_w(j)=sum(W.KDD30(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawKDD31_w(j)=sum(W.KDD31(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawKDD32_w(j)=sum(W.KDD32(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawKDD33_w(j)=sum(W.KDD33(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawKDD34_w(j)=sum(W.KDD34(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                tmpawKDD35_w(j)=sum(W.KDD35(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                
                %              %   tmpawdaysgtTcrit(j)=sum(daysgtTcrit(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);
                %                 tmpawKDD29(j)=sum(KDD29(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);;
                %                 tmpawKDD30(j)=sum(KDD30(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);;
                %                 tmpawKDD31(j)=sum(KDD31(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);;
                %                 tmpawKDD32(j)=sum(KDD32(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);;
                %                 tmpawKDD33(j)=sum(KDD33(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);;
                %                 tmpawKDD34(j)=sum(KDD34(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);;
                %                 tmpawKDD35(j)=sum(KDD35(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);;
                %                 tmpawBIO6(j)=sum(BIO6(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);;
                
                %                 tmpawpc1(j)=sum(pc1_map(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);;
                %                 tmpawpc2(j)=sum(pc2_map(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);;
                %                 tmpawpc3(j)=sum(pc3_map(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);;
                %                 tmpawpc4(j)=sum(pc4_map(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);;
                %                 tmpawpc5(j)=sum(pc5_map(ii).*fmavect.*a(ii))./sum(a(ii).*fmavect);;
                
                
                unitwasgood(j)=1;
            else
                %                unitwasgood(j)=0;
            end
        end
        
        areavector =[ areavector tmpareavector(1:j)];
        yieldvector  =[ yieldvector tmpyieldvector(1:j) ];
        yearvector    =[yearvector tmpyearvector(1:j)];
        awGDPannual   =[awGDPannual tmpawGDPannual(1:j)];
        awGDPfixed   =[awGDPfixed tmpawGDPfixed(1:j)];
        awORC30   =[awORC30 tmpawORC30(1:j)];
        awCEC30   =[awCEC30 tmpawCEC30(1:j)];
        awAWCtS30   =[awAWCtS30 tmpawAWCtS30(1:j)];
        awAWCh230   =[awAWCh230 tmpawAWCh230(1:j)];
        awirrfrac   =[awirrfrac tmpawirrfrac(1:j)];
        politunit   =[politunit tmppolitunit(1:j)];
        awslopebelow10=[awslopebelow10 tmpawslopebelow10(1:j)];
        awslopeabove30=[awslopeabove30 tmpawslopeabove30(1:j)];
        medianadminunit=[medianadminunit tmpmedianadminunit(1:j)];
        
        
        
        % Worldclim data
        
        awWC.awGDDT0=[awWC.awGDDT0 tmpawgddT0_wc(1:j)];
        awWC.awGDDTb=[awWC.awGDDTb tmpawgddTb_wc(1:j)];
        awWC.awMAP=[awWC.awMAP tmpawMAP_wc(1:j)];
        awWC.awSRAD=[awWC.awSRAD tmpawSRAD_wc(1:j)];
        awWC.awVAPR=[awWC.awVAPR tmpawVAPR_wc(1:j)];
        awWC.awPCI=[awWC.awPCI tmpawPCI_wc(1:j)];
        awWC.awBIO6=[awWC.awBIO6 tmpawPCI_wc(1:j)];
        % CRU - annual / clim
        
        awCRU.c.awGDDTb=[awCRU.c.awGDDTb  tmpawgddTb_c_cru(1:j)];
        awCRU.c.awGDDT0=[awCRU.c.awGDDT0  tmpawgddT0_c_cru(1:j)];
        awCRU.c.awMAP=[awCRU.c.awMAP  tmpawMAP_c_cru(1:j)];
        awCRU.c.awPCI=[awCRU.c.awPCI  tmpawPCI_c_cru(1:j)];
        awCRU.c.awCVP=[awCRU.c.awCVP  tmpawCVP_c_cru(1:j)];
        awCRU.c.awP2PET=[awCRU.c.awP2PET  tmpawP2PET_c_cru(1:j)];
        
        awCRU.y.awGDDT0=[awCRU.y.awGDDT0  tmpawgddT0_a_cru(1:j)];
        awCRU.y.awGDDTb=[awCRU.y.awGDDTb  tmpawgddTb_a_cru(1:j)];
        awCRU.y.awMAP=[awCRU.y.awMAP  tmpawMAP_a_cru(1:j)];
        awCRU.y.awPCI=[awCRU.y.awPCI  tmpawPCI_a_cru(1:j)];
        awCRU.y.awP2PET=[awCRU.y.awP2PET  tmpawP2PET_a_cru(1:j)];
        
        % WFDEI - ann
        
        awWFDEI.y.awKDD29=[awWFDEI.y.awKDD29 tmpawKDD29_w(1:j)];
        awWFDEI.y.awKDD30=[awWFDEI.y.awKDD30 tmpawKDD30_w(1:j)];
        awWFDEI.y.awKDD31=[awWFDEI.y.awKDD31 tmpawKDD31_w(1:j)];
        awWFDEI.y.awKDD32=[awWFDEI.y.awKDD32 tmpawKDD32_w(1:j)];
        awWFDEI.y.awKDD33=[awWFDEI.y.awKDD33 tmpawKDD33_w(1:j)];
        awWFDEI.y.awKDD34=[awWFDEI.y.awKDD34 tmpawKDD34_w(1:j)];
        awWFDEI.y.awKDD35=[awWFDEI.y.awKDD35 tmpawKDD35_w(1:j)];
        awWFDEI.y.awGDDT0=[awWFDEI.y.awGDDT0 tmpawgddT0_w(1:j)];
        awWFDEI.y.awGDDTb=[awWFDEI.y.awGDDTb tmpawgddTb_w(1:j)];
        awWFDEI.y.awMAP=[awWFDEI.y.awMAP tmpawMAP_w(1:j)];
        awWFDEI.y.awPCI=[awWFDEI.y.awPCI tmpawPCI_w(1:j)];
        awWFDEI.y.awSWRAD=[awWFDEI.y.awSWRAD tmpawSWRAD_w(1:j)];
        awWFDEI.y.awBIO6=[awWFDEI.y.awBIO6 tmpawBIO6_w(1:j)];
        
        %    awdaysgtTcrit=[awdaysgtTcrit tmpawdaysgtTcrit(1:j)]
        IDS(jyr).unitwasgood=unitwasgood;
        toc
        
        % now saving to IDSgateway
        IDSsave=IDS(jyr);
        
        
        % now figure out sizes of political units and irrigation
        % characteristics
        %        case 'rf'
        
        irrmap=logical(IDS(jyr).politicalunitmap*0);
        pusizemap=single(IDS(jyr).politicalunitmap*0);
        
                toc

        disp('starting new loop.')
        tic
        pumap=single(IDS(jyr).politicalunitmap);
        iiyear=find(yearvector==thisyear);
        for m=1:length(politunit(iiyear))
            pu=politunit(iiyear(m));
            iikeep=pumap==pu;
            pusizemap(iikeep)=sqrt(sum(fma(iikeep))/100) ; % typical length scale in km
            irrmap(iikeep)=awirrfrac(iiyear(m))>0.1;
        end
        toc
        %ii_irr=S.awirrfrac<=0.1;
        IDSsave.irrmap=irrmap;
        IDSsave.pusizemap=pusizemap;
        
        [IDSannual,IDSconstant]=allocateIDStoannual(IDSsave);
        
        IDSGatewayNameBase=['IDStructures/' cropname dataver 'IDStructuresRev1_'];
        
        startyear=yrvect(1);
        if jyr==1
            year1filename=[IDSGatewayNameBase num2str(thisyear)];
            save([IDSGatewayNameBase num2str(thisyear)],'IDSannual','IDSconstant','startyear','year1filename');
        else
            save([IDSGatewayNameBase num2str(thisyear)],'IDSannual','startyear','year1filename');
            
        end
        
    end
    
    
    S.areavector =areavector;
    S.yieldvector =yieldvector;
    S.yearvector  =yearvector;
    
    
    S.GDDT0_wc=awWC.awGDDT0;
    S.GDDTb_wc=awWC.awGDDTb;
    S.MAP_wc=awWC.awMAP;
    S.SRAD_wc=awWC.awSRAD;
    S.VAPR_wc=awWC.awVAPR;
    S.PCI_wc=awWC.awPCI;
    S.BIO6_wc=awWC.awBIO6;
    
    S.GDDTO_cruc= awCRU.c.awGDDTb;
    S.GDDTb_cruc=awCRU.c.awGDDT0;
    S.MAP_cruc=awCRU.c.awMAP;
    S.PCI_cruc=awCRU.c.awPCI;
    S.CVP_cruc=awCRU.c.awCVP;
    S.P2PET_cruc=awCRU.c.awP2PET;
    
    S.GDDTO_cruy=awCRU.y.awGDDT0;
    S.GDDTb_cruy=awCRU.y.awGDDTb;
    S.MAP_cruy=awCRU.y.awMAP;
    S.PCI_cruy=awCRU.y.awPCI;
    S.P2PET_cruy=awCRU.y.awP2PET;
    
    
    S.KDD29=awWFDEI.y.awKDD29;
    S.KDD30=awWFDEI.y.awKDD30;
    S.KDD31=         awWFDEI.y.awKDD31;
    S.KDD32=         awWFDEI.y.awKDD32;
    S.KDD33=         awWFDEI.y.awKDD33;
    S.KDD34=         awWFDEI.y.awKDD34;
    S.KDD35=         awWFDEI.y.awKDD35;
    S.GDDT0_wfd=awWFDEI.y.awGDDT0;
    S.GDDTb_wfd=awWFDEI.y.awGDDTb;
    S.MAP_wfd=awWFDEI.y.awMAP;
    S.PCI_wfd=awWFDEI.y.awPCI;
    S.SWRAD_wfd=awWFDEI.y.awSWRAD;
    S.BIO6_wfd=awWFDEI.y.awBIO6;
    
    
    S.awGDPfixed=awGDPfixed;
    S.awGDPannual=awGDPannual;
    S.awORC30   =awORC30;
    S.awCEC30 =awCEC30;
    S.awAWCtS30 =awAWCtS30;
    S.awAWCh230 =awAWCh230;
    S.awirrfrac  =awirrfrac;
    S.irr  =awirrfrac>0.1;
    S.politunit=politunit;
    S.awslopebelow10=awslopebelow10;
    S.awslopeabove30=awslopeabove30;
    %    S.harvInt=harvInt;
    
    %   S.awGSL=awgsl;
    %   S.awBIO6=awBIO6;
    %    S.NumDaysAboveTcrit=awdaysgtTcrit;
    S.medianadminunit=medianadminunit;
    %   S.annualFertRate=annualFertRate;
    %     S.awpc1=awpc1;
    %     S.awpc2=awpc2;
    %     S.awpc3=awpc3;
    %     S.awpc4=awpc4;
    %     S.awpc5=awpc5;
    
    if jcrop>4
        save(['./QRDataTables/' cropname dataver 'DataTablesRev20multiyr'],'S','unitwasgood','adminmap','politicalunitlist','IDS','IDSGatewayNameBase','-v7.3')
    else
        save(['./QRDataTables/' cropname dataver 'DataTablesRev21'],'S','unitwasgood','adminmap','politicalunitlist','IDS','IDSGatewayNameBase','-v7.3')
    end
end
% Rev notes:  rev 11 and 12 ... included the slope data
% Rev 13 included ISRIC soils data
% Rev 14 - data from 1965, so faking some of the climate data.

