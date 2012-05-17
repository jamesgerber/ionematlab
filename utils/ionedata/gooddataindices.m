function ii=gooddataindices(CS);
% gooddataindices - find indices with good yield and area data
%
% SYNTAX
%     ii=gooddataindices(CropStructure);
%
%
switch nargin
    case 1
        ii=(CS.Data(:,:,1) > 0 & CS.Data(:,:,1) < 9e9 & ...
            CS.Data(:,:,2) > 0 & CS.Data(:,:,2) < 9e9 & ...
            isfinite(CS.Data(:,:,1)) & isfinite(CS.Data(:,:,2)));
    otherwise
        error
end
