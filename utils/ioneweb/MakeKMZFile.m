function MakeKMZFile(MKS)
%
%  Make a KMZ file
%
%  this takes as an argument MKS
%
%
%MKS.Data=Data;
%MKS.cmap='revsummer';
%MKS.coloraxis=[0 100];
%MKS.BaseTransparency=0.5;
%MKS.folderbase='./kmlfolder'
%MKS.kmzfilenamebase='test'
%MKS.KS.header1='filetext'
%MKS.KS.description1='desc 1'
%MKS.KS.header2=''
%MKS.KS.description2=''
%MKS.KS.logoname='';
%MKS.KS.legendname='';

cmap='revsummer';
coloraxis=[0 100];
BaseTransparency=0.5;
kmzfilenamebase='test';
folderbase='./kmlfolder'
KS.header1='filetext'
KS.description1='desc 1'
KS.header2=''
KS.description2=''
KS.logoname='';
KS.legendname='';



expandstructure(MKS);

TempFileName=[folderbase '/overlay.png'];

%% directory
mkdir(folderbase)


%% Make the overlay
MakeGlobalOverlay(Data,cmap,coloraxis,TempFileName,BaseTransparency);

%% Make the .kml file

KS.folderbase=folderbase;

makekml(KS)

zip('tempkml',folderbase); 

movefile('tempkml.zip',[kmzfilenamebase '.kmz'] );

