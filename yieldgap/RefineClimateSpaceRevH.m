function [CDSnew]=RefineClimateSpaceRevH(Heat,Prec, ...
    Area,CDS,xbins,ybins,ContourMask);
%RefineClimateSpaceRevH
%
%   called from MakeClimateSpaceLibraryFunctionRevH
%
%  [CDS]=RefineClimateSpaceRevH(Heat,Prec,Area,CDS);
%
%
%

CDSnew=CDS;
DataQualityGood=(isfinite(Area) & Area>eps & isfinite(Heat) & isfinite(Prec) );

N=sqrt(length(CDS));

for k=1:N
    tmparea=0;
    for j=1:N; %N+2; %  climate bin away from an edge (if N>2)
        
        m=N*(j-1)+k;
        ii=find(Prec>=CDS(m).Precmin & Prec < CDS(m).Precmax & ...
            Heat >=CDS(m).GDDmin & Heat < CDS(m).GDDmax & DataQualityGood);
        
        areavect(j,k)=sum(Area(ii));
        tmparea=tmparea+sum(Area(ii));
    end
    tmparea
end


IndicesOfOuterBins=unique([1:N (1:N)*N (N+1):N:(N^2-N+1) (N^2-N):N^2])

IndicesOfCenterBins=setdiff(1:N^2,IndicesOfOuterBins);

TargetArea=mean(areavect(IndicesOfCenterBins));


for ibin=1:N;
    ChangeFieldName='GDDmin';
    NewCD=PullInBoundary(CDS(ibin),Area,ChangeFieldName,TargetArea,Heat,Prec,DataQualityGood);
    CDSnew(ibin)=NewCD;
end


for ibin=(N*(N-1)+1):N^2;
    ChangeFieldName='GDDmax';
    NewCD=PullInBoundary(CDSnew(ibin),Area,ChangeFieldName,TargetArea,Heat,Prec,DataQualityGood);
    CDSnew(ibin)=NewCD;
end

for ibin=(N):N: N^2;
    ChangeFieldName='Precmin';
    NewCD=PullInBoundary(CDSnew(ibin),Area,ChangeFieldName,TargetArea,Heat,Prec,DataQualityGood);
    CDSnew(ibin)=NewCD;
end
for ibin=(1):N: (N^2-N+1);
    ChangeFieldName='Precmax';
    NewCD=PullInBoundary(CDSnew(ibin),Area,ChangeFieldName,TargetArea,Heat,Prec,DataQualityGood);
    CDSnew(ibin)=NewCD;
end

disp(['climate space refined'])






CDSold=CDS;
CDS=CDSnew;
for k=1:N
    tmparea=0;
    for j=1:N; %N+2; %  climate bin away from an edge (if N>2)
        
        m=N*(j-1)+k;
        ii=find(Prec>=CDS(m).Precmin & Prec < CDS(m).Precmax & ...
            Heat >=CDS(m).GDDmin & Heat < CDS(m).GDDmax & DataQualityGood);
        
        areavect(j,k)=sum(Area(ii));
        tmparea=tmparea+sum(Area(ii));
    end
    tmparea
end
areavect





function NewCD=PullInBoundary(CD,Area,ChangeFieldName,TargetArea,Heat,Prec,DataQualityGood);

initguess=getfield(CD,ChangeFieldName);
initguess=double(initguess);
clear enclosedarea
newfieldval=fzero(@(FieldVal) ...
    enclosedarea(FieldVal,ChangeFieldName,CD,TargetArea,Heat,Prec,Area,DataQualityGood),initguess);
NewCD=setfield(CD,ChangeFieldName,newfieldval)


function eaerr=enclosedarea(FieldVal,ChangeFieldName,CD,TargetArea,Heat,Prec,Area,DataQualityGood)


% persistent Precmin Precmax GDDmin GDDmax
% if isempty(Precmin)
%     Precmin=CD.Precmin;
%     Precmax=CD.Precmax;
%     GDDmin=CD.GDDmin;
%     GDDmax=CD.GDDmax;
% end


% calculate enclosed area
FieldVal;
CD=setfield(CD,ChangeFieldName,FieldVal);

  ii=find(Prec>=CD.Precmin & Prec < CD.Precmax & ...
            Heat >=CD.GDDmin & Heat < CD.GDDmax & DataQualityGood);
     

        TrialArea=sum(Area(ii));
        eaerr=TrialArea-TargetArea;
        
        


% % % function [ContourMask,CutoffValue]=FindContour(jp,jpmax,p)
% % % 
% % %   %find contour that has 0.95% of area
% % % 
% % % jpmax_norm=jpmax/max(max(jpmax));
% % % 
% % % %level=fminbnd(@(level) testlevel(level,jp,jpmax,p),0,1);
% % % level=fzero(@(level) testlevel(level,jp,jpmax_norm,p),.1);
% % % 
% % % ContourMask=(jpmax_norm>level);
% % % CutoffValue=level*max(max(jpmax));  %need to renormalize
% % % 
% % % 
% % % function tlerror=testlevel(level,jp,jpmax,p)
% % % % returns an error measure of how far off level is from giving
% % % % contour that encloses p percent of jp
% % % ii=(jpmax>level);
% % % 
% % % pguess=sum(jp(ii))/sum(sum(jp));
% % % 
% % % tlerror=(pguess-p);