function [BinMatrix,ClimateDefs]=MakeClimateSpace(Temp,Water,TempBins,WaterBins,CultivatedArea);
% MAKECLIMATESPACEEQUALCULTIVATEDAREA - make a climate space
%
%  SYNTAX
%     [BinMatrix,TempBins,WaterBins,ClimateDefs]=MakeClimateSpace(Temp,Water
%     ,TempBins,WaterBins); 
%
%   INPUTS:
%     Temp and Water are globe-spanning datasets.   
%     TempBins is a length M+1 array of edge-bin values for Temp
%     WaterBins is a length N+1 array of edge-bin values for Water 
%
%     The algorithm will categorize the values of Temp in (M)
%     bins, where the jth bin corresponds to values of Temp that
%     are greater than Temp(j) and less than or equal to Temp(j+1),
%     and similarly for Water.
%
%     Thus, there are (M)*(N) Climate spaces created.
%
%     If TempBins or WaterBins is a single number, that will be
%     interpreted as the desired number of bins, and those bins
%     will be determined using Matlab's hist command.
%
%   OUTPUTS:
%       BinMatrix is a matrix of the size of Temp and Water
%       containing the climate bins associated with the data in
%       Temp and Water
%       TempBins and WaterBins are the actual bins used.
%       ClimateDefs is a human-readable string containing climate
%       definitions.
%
%     See Also  SelectUniformBins GenerateJointDist
%     
if nargin==0;help(mfilename);return;end


if ~isequal(size(Temp),size(Water))
  error('Climate axis data matrices are unequal in size');
end


TempDataName=inputname(1);
WaterDataName=inputname(2);


% Turn Temp and Water matrices into vectors.  Only keep indices
% corresponding to land mask.    Call resultant vectors T and W.

LogicalMask=DataMaskLogical;
BinMatrix=LogicalMask*0;   %Initialize


%%ii=find(LogicalMask);

N=length(WaterBins);

ii=find(LandMaskLogical);

T=Temp(ii);
W=Water(ii);
ClimateBinVector=(1:length(T))*0;


%% Determin bins

if length(TempBins)==1
  [N,TempBins]=hist(T,TempBins);
  TempBins(end+1)=TempBins(end)+ (TempBins(end)-TempBins(end-1));
end

if length(WaterBins)==1
  [N,WaterBins]=hist(W,WaterBins);
  WaterBins(end+1)=WaterBins(end)+ (WaterBins(end)-WaterBins(end-1));
end

NT=length(TempBins)-1;
NW=length(WaterBins)-1;

for mW=1:NW
    
    
    %%% now partition all of the GDD bins so as to equalize area.
     % Water variable limits
    Wmin=WaterBins(mW);
    Wmax=WaterBins(mW+1);
    ii=find(W >= Wmin & W <Wmax);
  
    GDDVals=T(ii);
    AreaVals=CultivatedArea(ii);
    
    [GDDBinEdges]=GetBins(GDDVals,AreaVals,N,0,'GDD');
    
    
    for mT=1:NT
      
    ClimateBinNumber=(mW-1)*NT+mT;
    
    
    
    
   
    
    %Temperature variable limits
    Tmin=TempBins(mT);
    Tmax=TempBins(mT+1);
    
    % who fits?
    jj=find( T >= Tmin & T <Tmax & W >= Wmin & W <Wmax);
    
    ClimateBinVector(jj)=ClimateBinNumber;
    ClimateDefs{ClimateBinNumber}=...
	['Bin No ' int2str(ClimateBinNumber) '.   ' ...
	 num2str(Tmin) '< ' TempDataName ' <= ' num2str(Tmax) ',   ' ...   
	 num2str(Wmin) '< ' WaterDataName ' <= ' num2str(Wmax) ];	 
  end
end

ii=1:prod(size(BinMatrix));
BinMatrix(LandMaskIndices)=ClimateBinVector;




[GDDBinEdges]=GetBins(x,A,N,p,'GDD');
[PrecBinEdges]=GetBins(y,A,N,p,'Prec');

function [xbins]=GetBins(x,y,N,p,str);
[xsort,ii]=sort(x);

ysort=y(ii);

ysum=cumsum(ysort);
AreaNorm=ysum/max(ysum);

i5=min(find(AreaNorm>=p));
i95=max(find(AreaNorm<=(1-p)));
% remember i5, i95 are conceptually bottom and top 5th percentile.  May in
% fact by 0th or 10th ...

x5=xsort(i5);
x95=xsort(i95);

if p==0
    %if p==0, go out to ends.
    N=N+2;
end
% now want to get bins between p and 1-p
TargetAreas=[linspace(p,1-p,(N-1))];

for j=1:(N-1);
    IndexVector(j)=min(find(AreaNorm>=TargetAreas(j)));
    xbins(j)=xsort(IndexVector(j));
end

if p>0
    % tack on 1, length(y) to xbins
    xbins=[min(x) xbins max(x)];
end

MakePlot=0;
if MakePlot
    figure
    plot(xsort,AreaNorm);
    hold on
    ylabel(['Normalized Cumulative Area with ' str])
    xlabel(str);
    for j=1:length(xbins);
        plot([1 1]*xbins(j),[0 1],'r');
    end
end
    