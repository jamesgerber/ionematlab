function [CDSnew]=RefineClimateSpaceRevI(Heat,Prec, ...
    Area,CDS,xbins,ybins,ContourMask,cropname);
%RefineClimateSpaceRevH
%
%   called from MakeClimateSpaceLibraryFunctionRevI
%
%  [CDS]=RefineClimateSpaceRevH(Heat,Prec,Area,CDS);
%
%
%

CDSnew=CDS;

%LogicalGoodArea=AreaFilter(Area,Area);
DataQualityGood=(isfinite(Area) & Area>eps & isfinite(Heat) & isfinite(Prec) );
%DataQualityGood =DataQualityGood & LogicalGoodArea;

PrecVect=Prec(DataQualityGood);
HeatVect=Heat(DataQualityGood);
AreaVect=Area(DataQualityGood);


N=sqrt(length(CDS));

for k=1:N
    tmparea=0;
    for j=1:N; %N+2; %  climate bin away from an edge (if N>2)
        
        m=N*(j-1)+k;
    
           ii=find(PrecVect>=CDS(m).Precmin & PrecVect < CDS(m).Precmax & ...
           HeatVect >=CDS(m).GDDmin & HeatVect < CDS(m).GDDmax);
        
       areamatrix(j,k)=sum(AreaVect(ii));
       tmparea=tmparea+sum(AreaVect(ii));
    end
    
    tmparea
end
areamatrix
PatchPlotOfAreaInClimateSpace...
    (CDS,Area,Heat,Prec,[cropname ' pre-refine climate bins'],'I');
cmin=min(min(areamatrix));
cmax=max(max(areamatrix));
caxis([cmin cmax])
OutputFig('Force')


IndicesOfOuterBins=unique([1:N (1:N)*N (N+1):N:(N^2-N+1) (N^2-N):N^2])

IndicesOfCenterBins=setdiff(1:N^2,IndicesOfOuterBins);

TargetArea=mean(areamatrix(IndicesOfCenterBins));


for ibin=(1):N: (N^2-N+1);
    ChangeFieldName='Precmin';
    NewCD=PullInBoundary(CDSnew(ibin),AreaVect,ChangeFieldName,TargetArea,HeatVect,PrecVect);
    CDSnew(ibin)=NewCD;
end


for ibin=(N*(N-1)+1):N^2;
    ChangeFieldName='GDDmax';
    NewCD=PullInBoundary(CDSnew(ibin),AreaVect,ChangeFieldName,TargetArea,HeatVect,PrecVect);
    CDSnew(ibin)=NewCD;
end

for ibin=1:N;
    ChangeFieldName='GDDmin';
    NewCD=PullInBoundary(CDSnew(ibin),AreaVect,ChangeFieldName,TargetArea,HeatVect,PrecVect);
    CDSnew(ibin)=NewCD;
end



for ibin=(N):N: N^2;
    ChangeFieldName='Precmax';
    NewCD=PullInBoundary(CDSnew(ibin),AreaVect,ChangeFieldName,TargetArea,HeatVect,PrecVect);
    CDSnew(ibin)=NewCD;
end

disp(['climate space refined'])



CDSold=CDS;
CDS=CDSnew;

for k=1:N
    tmparea=0;
    for j=1:N; %N+2; %  climate bin away from an edge (if N>2)
        
        m=N*(j-1)+k;

           ii=find(PrecVect>=CDS(m).Precmin & PrecVect < CDS(m).Precmax & ...
           HeatVect >=CDS(m).GDDmin & HeatVect < CDS(m).GDDmax);
        
       areamatrix(j,k)=sum(AreaVect(ii));
       tmparea=tmparea+sum(AreaVect(ii));
    end
    
    tmparea
end
areamatrix

if any(areamatrix < TargetArea/2);
    keyboard
end


PatchPlotOfAreaInClimateSpace...
    (CDS,Area,Heat,Prec,[cropname ' post-refine climate bins'],'I')
caxis([cmin cmax])
OutputFig('Force')


function NewCD=PullInBoundary(CD,Area,ChangeFieldName,TargetArea,Heat,Prec);
% note ... Area,Heat,Prec are all vectors in here
initguess=getfield(CD,ChangeFieldName);
initguess=double(initguess);
switch ChangeFieldName
    case {'Precmin','Precmax'}
        minguess=getfield(CD,'Precmin');
        maxguess=getfield(CD,'Precmax');
    case {'GDDmin','GDDmax'};
        minguess=getfield(CD,'GDDmin');
        maxguess=getfield(CD,'GDDmax');
end
minguess=double(minguess);
maxguess=double(maxguess);
clear enclosedareafast
legacy=1
if legacy==1
    tic
    newfieldval=fminbnd(@(FieldVal) ...
        enclosedarea(FieldVal,ChangeFieldName,CD,TargetArea,Heat,Prec,Area),minguess,maxguess);
    toc
else
    tic
    newfieldval=fzero(@(FieldVal) ...
        enclosedareafast(FieldVal,ChangeFieldName,CD,TargetArea,Heat,Prec,Area),initguess);
    
    toc
end

NewCD=setfield(CD,ChangeFieldName,newfieldval)

if NewCD.GDDmin > NewCD.GDDmax
    keyboard
end



function eaerr=enclosedarea(FieldVal,ChangeFieldName,CD,TargetArea,Heat,Prec,Area)
% calculate enclosed area
FieldVal;
CD=setfield(CD,ChangeFieldName,FieldVal);

ii=(Prec>=CD.Precmin & Prec < CD.Precmax & ...
    Heat >=CD.GDDmin & Heat < CD.GDDmax);


TrialArea=sum(Area(ii));
eaerr=(TrialArea-TargetArea)^2;




function eaerr=enclosedareafast(FieldVal,ChangeFieldName,CD,TargetArea,Heat,Prec,Area)


persistent Precmin Precmax GDDmin GDDmax
if isempty(Precmin)
    Precmin=CD.Precmin;
    Precmax=CD.Precmax;
    GDDmin=CD.GDDmin;
    GDDmax=CD.GDDmax;
end

switch ChangeFieldName
    case 'Precmin'
        Precmin=FieldVal;
    case 'Precmax'
        Precmax=FieldVal;
    case 'GDDmin'
        GDDmin=FieldVal;
    case 'GDDmax'
        GDDmax=FieldVal;
end

        

% calculate enclosed area
FieldVal;

ii=(Prec>=Precmin & Prec < Precmax & ...
    Heat >=GDDmin & Heat < GDDmax);


TrialArea=sum(Area(ii));
eaerr=TrialArea-TargetArea;
if ~isfinite(eaerr)
    keyboard
end


