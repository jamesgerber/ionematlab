function MakeKMZFile(MKS)
%  MakeKMZFile Make a KMZ file
%
%  this takes as an argument MKS
%
%
% MKS.Data=Data;
% MKS.cmap='revsummer';
% MKS.coloraxis=[0 100];
% MKS.BaseTransparency=0.5;
% MKS.folderbase='./kmlfolder'
% MKS.kmzfilenamebase='test'
% MKS.lores=0;
% MKS.KS.header1='filetext'
% MKS.KS.description1='desc 1'
% MKS.KS.header2=''
% MKS.KS.description2=''
% MKS.KS.logoname='';
% MKS.KS.legendname='';
%
%
%
%
%  Example 
%
%  clear MKS
%  m=getdata('maize');
%  ii=gooddataindices(m);
%  myield=m.Data(:,:,2);
%  myield(~ii)=NaN;
%  MKS.Data=myield;
%  MKS.cmap='revsummer';
%  MKS.coloraxis=[0 12];
%  MKS.kmzfilenamebase='maizeyield';
%  MKS.KS.header1='maize yield yr 2000';
%  MKS.KS.description1='maize yield from Monfreda et al 2008'
%
%
% %%Example 1:
%
% % No legend%
%
%  MakeKMZFile(MKS);
%
%  % Now with legend
%   makelegend('tons/ha','./legend.png','revsummer',0,12);
%   MKS.KS.legendname='./legend.png'; 
%
%  MakeKMZFile(MKS);
%
%
%  See Also  makelegend makekml

% lores=0;
% cmap='revsummer';
% coloraxis=[0 100];
 BaseTransparency=0.5;
% kmzfilenamebase='test';
folderbase='./kmlfolder';
% KS.header1='filetext';
% KS.description1='desc 1';
% KS.header2='';
% KS.description2='';
% KS.logoname='';
% KS.legendname='';



expandstructure(MKS);

TempFileName=[folderbase '/overlay.png'];

%% directory
mkdir(folderbase)


%% Make the overlay
MakeGlobalOverlay(Data,cmap,coloraxis,TempFileName,BaseTransparency);

%% Make the .kml file

KS.folderbase=folderbase;

makekml(KS)

zip('tempkml','*',folderbase); 

movefile('tempkml.zip',[kmzfilenamebase '.kmz'] );

