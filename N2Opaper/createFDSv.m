% % av=cav.*fmav;
% % 
% % % first try for crops
% % 
% % croplist=unique(metacropnum);
% % 
% % 
% % counter=1;
% % tic
% % for j=1:length(croplist)
% %     cropno=croplist(j);
% %     
% %     ii=find(metacropnum==cropno);
% %     
% %     
% %     nv=metanv(ii);
% %     av=metaav(ii);
% %     edges=[0:1:501];
% %     FDS.Napp=(edges(2:end) + edges(1:end-1) )/2;
% %     M=awhist(nv,av,edges);
% %     FDS.cropname=num2str(cropno);
% %     FDS.totalN=sum(M.distbyweightedval);
% %     FDS.N2OresponseIPCC=Nfunction(FDS.Napp,'IPCC',callcropname);
% %     FDS.N2OresponseNLNRR=Nfunction(FDS.Napp,'meanNLNRRresponse',callcropname);
% %     FDS.edges=edges;
% %     FDS.distbyweightedval=M.distbyweightedval;
% %     FDS.distbyweight=M.distbyweight;
% %     
% %     FDSv(counter)=FDS;
% %     counter=counter+1;
% % end
% % toc
% % save FDSvCountries FDSv

%% now countries

%a=load('/ionedata/AdminBoundary2010/Raster_NetCDF/2_States_5min/ncmat/glctry.mat')
%length(unique(a.DS.Data))
%
%
%countrylist=unique(metacropnum);


load('/ionedata/AdminBoundary2010/SageNumberCountryMap','NameList')
[croplist,cropnumlist]=N2OAnalysis_cropnames;
clear FDSv

counter=1;
tic
for countryno=1:237
   % countryno=44
    NameList{countryno}
    
    idxrice=strmatch('rice_irrigated',croplist);
    ii_irr=find(countryno==metacountrynum & metacropnum==idxrice);
    ii_rf=find(countryno==metacountrynum & metacropnum~=idxrice);
    
    % irrigated rice
    ii=ii_irr;
    nv=metanv(ii);
    av=metaav(ii);
    edges=[0:1:501];
    FDS.Napp=(edges(2:end) + edges(1:end-1) )/2;
    M=awhist(nv,av,edges);
    FDS.countryname=NameList{countryno};
    FDSa.totalN=sum(M.distbyweightedval);
    FDSa.N2OresponseIPCC=Nfunction(FDS.Napp,'IPCC','rice');
    FDSa.N2OresponseNLNRR=Nfunction(FDS.Napp,'meanNLNRRresponse','rice');
    FDSa.edges=edges;
    FDSa.distbyweightedval=M.distbyweightedval;
    FDSa.distbyweight=M.distbyweight;
    
    % non-irrigated rice
    ii=ii_rf;
    nv=metanv(ii);
    av=metaav(ii);
    edges=[0:1:501];
    FDSb.Napp=(edges(2:end) + edges(1:end-1) )/2;
    M=awhist(nv,av,edges);
    FDSb.countryname=NameList{countryno};
    FDSb.totalN=sum(M.distbyweightedval);
    FDSb.N2OresponseIPCC=Nfunction(FDS.Napp,'IPCC','maize');
    FDSb.N2OresponseNLNRR=Nfunction(FDS.Napp,'meanNLNRRresponse','maize');
    FDSb.edges=edges;
    FDSb.distbyweightedval=M.distbyweightedval;
    FDSb.distbyweight=M.distbyweight;
   
    
    wa=FDSa.distbyweightedval;
    wb=FDSb.distbyweightedval;
    
    
    FDS.totalN=FDSa.totalN+FDSb.totalN;
    x=FDS.Napp;
    
    %    totalN2OIPCC=FDSa.
    
    
    N2OIPCC= FDSa.N2OresponseIPCC.*FDSa.distbyweightedval + FDSb.N2OresponseIPCC.*FDSb.distbyweightedval;
    N2ONLNRR= FDSa.N2OresponseNLNRR.*FDSa.distbyweightedval + FDSb.N2OresponseNLNRR.*FDSb.distbyweightedval;
    totalN_by_bin=FDSa.distbyweightedval+FDSb.distbyweightedval;
    % by response here i mean EF * Napplied
    
    FDS.N2OresponseIPCCEZ=  (  (0.003.*wa+0.01.*wb)./(wa+wb)  ).*x;
    FDS.N2OresponseIPCC=( (FDSa.N2OresponseIPCC./x.*wa+FDSb.N2OresponseIPCC./x.*wb)./(wa+wb) ) .*x;
    
    FDS.N2OresponseIPCC(isnan(FDS.N2OresponseIPCC))=0;
    
    FDS.N2OresponseNLNRR=((FDSa.N2OresponseNLNRR./x.*wa+FDSb.N2OresponseNLNRR./x.*wb)./(wa+wb)) .*x;
    
    FDS.N2OresponseNLNRR(isnan(FDS.N2OresponseNLNRR))=0;
    
    
    %FDS.N2OresponseNLNRR=(FDSa.N2OresponseNLNRR.*wa+FDSb.N2OresponseNLNRR.*wb)./(totalN_by_bin);
    
    
    FDS.distbyweightedval=(FDSa.distbyweightedval+FDSb.distbyweightedval);
    FDS.distbyweight=(FDSa.distbyweight.*wa+FDSb.distbyweight.*wb)./(wa+wb);
    
    
    FDS.distbyweight(isnan(FDS.distbyweight))=0;
    
    
    FDSva(counter)=FDSa;
    FDSvb(counter)=FDSb;
    FDSv(counter)=FDS;
    counter=counter+1;
end
toc

FDSvCountries=FDSv;





%% now continents

[croplist,cropnumlist]=N2OAnalysis_cropnames;

load customregionmap

clear FDSv

counter=1;
tic
for countryno=1:length(NameList)
   % countryno=44
    NameList{countryno}
    
    idxrice=strmatch('rice_irrigated',croplist);
    ii_irr=find(countryno==metacontinentnum & metacropnum==idxrice);
    ii_rf=find(countryno==metacontinentnum & metacropnum~=idxrice);
    
    % irrigated rice
    ii=ii_irr;
    nv=metanv(ii);
    av=metaav(ii);
    edges=[0:1:501];
    FDS.Napp=(edges(2:end) + edges(1:end-1) )/2;
    M=awhist(nv,av,edges);
    FDS.countryname=NameList{countryno};
    FDS.continentname=NameList{countryno};

    FDSa.totalN=sum(M.distbyweightedval);
    FDSa.N2OresponseIPCC=Nfunction(FDS.Napp,'IPCC','rice');
    FDSa.N2OresponseNLNRR=Nfunction(FDS.Napp,'meanNLNRRresponse','rice');
    FDSa.edges=edges;
    FDSa.distbyweightedval=M.distbyweightedval;
    FDSa.distbyweight=M.distbyweight;
    
    % non-irrigated rice
    ii=ii_rf;
    nv=metanv(ii);
    av=metaav(ii);
    edges=[0:1:501];
    FDSb.Napp=(edges(2:end) + edges(1:end-1) )/2;
    M=awhist(nv,av,edges);
    FDSb.countryname=NameList{countryno};
    FDSb.totalN=sum(M.distbyweightedval);
    FDSb.N2OresponseIPCC=Nfunction(FDS.Napp,'IPCC','maize');
    FDSb.N2OresponseNLNRR=Nfunction(FDS.Napp,'meanNLNRRresponse','maize');
    FDSb.edges=edges;
    FDSb.distbyweightedval=M.distbyweightedval;
    FDSb.distbyweight=M.distbyweight;
   
    
    wa=FDSa.distbyweightedval;
    wb=FDSb.distbyweightedval;
    
    
    FDS.totalN=FDSa.totalN+FDSb.totalN;
    x=FDS.Napp;
    
    %    totalN2OIPCC=FDSa.
    
    
    N2OIPCC= FDSa.N2OresponseIPCC.*FDSa.distbyweightedval + FDSb.N2OresponseIPCC.*FDSb.distbyweightedval;
    N2ONLNRR= FDSa.N2OresponseNLNRR.*FDSa.distbyweightedval + FDSb.N2OresponseNLNRR.*FDSb.distbyweightedval;
    totalN_by_bin=FDSa.distbyweightedval+FDSb.distbyweightedval;
    % by response here i mean EF * Napplied
    
    FDS.N2OresponseIPCCEZ=  (  (0.003.*wa+0.01.*wb)./(wa+wb)  ).*x;
    FDS.N2OresponseIPCC=( (FDSa.N2OresponseIPCC./x.*wa+FDSb.N2OresponseIPCC./x.*wb)./(wa+wb) ) .*x;
    
    FDS.N2OresponseIPCC(isnan(FDS.N2OresponseIPCC))=0;
    
    FDS.N2OresponseNLNRR=((FDSa.N2OresponseNLNRR./x.*wa+FDSb.N2OresponseNLNRR./x.*wb)./(wa+wb)) .*x;
    
    FDS.N2OresponseNLNRR(isnan(FDS.N2OresponseNLNRR))=0;
    
    
    %FDS.N2OresponseNLNRR=(FDSa.N2OresponseNLNRR.*wa+FDSb.N2OresponseNLNRR.*wb)./(totalN_by_bin);
    
    
    FDS.distbyweightedval=(FDSa.distbyweightedval+FDSb.distbyweightedval);
%FDS.distbyweight=(FDSa.distbyweight.*wa+FDSb.distbyweight.*wb)./(wa+wb);
    
    FDS.distbyweight=FDS.distbyweightedval./FDS.Napp;
    
    
    FDS.distbyweight(isnan(FDS.distbyweight))=0;
    
    
    FDSva(counter)=FDSa;
    FDSvb(counter)=FDSb;
    FDSv(counter)=FDS;
    counter=counter+1;
end
toc


FDSvContinents=FDSv;
































