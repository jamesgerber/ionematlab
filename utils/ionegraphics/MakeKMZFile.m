function MakeKMZFile(MKS)

MKS.Data=Data;
MKS.cmap='revsummer';
MKS.coloraxis=[0 100];
MKS.BaseTransparency=0.5;
MKS.


expandstructure(MKS);

TempFileName='~/.Google


%% Make the overlay
MakeGlobalOverlay(Data,cmap,coloraxis,TempFileName,BaseTransparency);