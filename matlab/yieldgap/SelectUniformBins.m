function BinEdges=SelectUniformBins(DataVector,NumBins);
% SELECTUNIFORMBINS - Choose bins to hold equal numbers of elements
%
%  SYNTAX
%     
%     BinEdges=SelectUniformBins(DataVector,NumBins);
%
%
%  EXAMPLE
%      SelectUniformBins(AnnualPrecip(LandMaskIndices),10);
%     
%    See Also:  GenerateJointDist MakeClimateSpace
if size(DataVector(:),2)>1
error('This appears to be a matrix not a vector.  See syntax.')
end
v=sort(DataVector);

% find indices 

ii=round(linspace(1,length(v),NumBins+1));;
ii(1)=1;
BinEdges=v(ii);


