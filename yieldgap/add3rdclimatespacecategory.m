function [NewBinMatrix,NewClimateDefs,NewCDS]=...
    Add3rdClimateSpaceCategory(BinMatrix,ClimateDefs,CDS,CategoryMap,Categories);
% ADD3RDCLIMATESPACECATEGORY - Add a 3rd category to a climate space
%
%  SYNTAX
%  [BinMatrix,TempBins,WaterBins,ClimateDefs,CDS]=...
%    Add3rdClimateSpaceCategory(BinMatrix,ClimateDefs,CDS,SoilMap,Categories)%
%   INPUTS:
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

if ~isequal(length(CDS),length(ClimateDefs)) | ~isequal(size(BinMatrix),size(CategoryMap))
    error('input variables are unequal in size');
end

CategoryDataName=inputname(4);

LogicalMask=DataMaskLogical;

NewBinMatrix=LogicalMask*0-1;   %Initialize
ii=find(LandMaskLogical);

%C=CategoryMap(ii);
C=CategoryMap;
N=sqrt(length(CDS));


for mC=1:length(Categories)
    c=Categories(mC);


    
    for mB=1:N^2;
        jj=find(C==c & BinMatrix==mB);
      NewBinNumber=(mC-1)*(N^2) + mB;
      
      NewClimateDefs{NewBinNumber}=[ClimateDefs{mB} ' cSQI=' num2str(c)];
    
      tmpCDS=CDS(mB);
      tmpCDS.Category=c;
      NewCDS(NewBinNumber)=tmpCDS;

      
      NewBinMatrix(jj)=NewBinNumber;
    end
end





