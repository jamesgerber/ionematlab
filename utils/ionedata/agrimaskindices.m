function ii=agrimaskindices(varargin);
% AGRIMASKINDICES -return indices of standard (5minute) agri mask
%
%  See Also agrimasklogical datamaskindices landmasklogical


ii=find(agrimasklogical);

if nargin==1
    if ~ischar(varargin{1})
        %haven't passed in a string.  probably a number.  index into ii
        
        ii=ii(varargin{1});
    end
end
