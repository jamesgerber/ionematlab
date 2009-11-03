function [BinMatrix,TempBins,WaterBins,ClimateDefs,CDS]=MakeClimateSpace(Temp,Water,TempBins,WaterBins);
% MAKECLIMATESPACE - make a climate space
%
%  SYNTAX
%     [BinMatrix,TempBins,WaterBins,ClimateDefs,CDS]=MakeClimateSpace(Temp,Water
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
%       CDS is a climate definition structure
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


if iscell(WaterBins)
    NW=length(WaterBins);
else
    NW=length(WaterBins)-1;
end

if iscell(TempBins)
    NT=length(TempBins);
else
    NT=length(TempBins)-1;
end


for mW=1:NW
    for mT=1:NT
        ClimateBinNumber=(mW-1)*NT+mT;
               
        if iscell(WaterBins)
            WaterBinsThisTempBin=WaterBins{mT};
            Wmin=WaterBinsThisTempBin(mW);
            Wmax=WaterBinsThisTempBin(mW+1);
        else
            % Water variable limits
            Wmin=WaterBins(mW);
            Wmax=WaterBins(mW+1);
        end
         
        %Temperature variable limits        
        if iscell(TempBins)
            TempBinsThisWaterBin=TempBins{mW};
            Tmin=TempBinsThisWaterBin(mT);
            Tmax=TempBinsThisWaterBin(mT+1);
        else
            Tmin=TempBins(mT);
            Tmax=TempBins(mT+1);
        end
               
        % who fits?
        jj=find( T >= Tmin & T <Tmax & W >= Wmin & W <Wmax);
        
        ClimateBinVector(jj)=ClimateBinNumber;
        ClimateDefs{ClimateBinNumber}=...
            ['Bin No ' int2str(ClimateBinNumber) '.   ' ...
            num2str(Tmin) '< ' TempDataName ' <= ' num2str(Tmax) ',   ' ...
            num2str(Wmin) '< ' WaterDataName ' <= ' num2str(Wmax) ];
        CDS(ClimateBinNumber).GDDmin=Wmin;
        CDS(ClimateBinNumber).GDDmax=Wmax;
        CDS(ClimateBinNumber).Precmin=Tmin;
        CDS(ClimateBinNumber).Precmax=Tmax;
    end
end

ii=1:prod(size(BinMatrix));
BinMatrix(LandMaskIndices)=ClimateBinVector;

