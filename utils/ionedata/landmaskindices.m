function ii=landmaskindices(indices);
% LANDMASKINDICES -return indices of standard (5minute) landmask
if nargin==0
    ii=find(landmasklogical);
else
    ii=find(landmasklogical);
    ii=ii(indices);
end
