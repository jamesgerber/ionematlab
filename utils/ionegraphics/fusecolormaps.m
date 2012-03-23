function cmap=fusecolormaps(cmap1,cmap2,glue);
% fusecolormaps - fuse two colormaps 
%
%  Syntax
%        fusecolormaps(map1,map2)
%
%   Example
%       cmap1='greens_deep';
%       cmap2='reds_deep';
%       cmap=fusecolormaps(cmap1,cmap2);

if nargin<3
    glue=[1 1 1];
end

c1=finemap(cmap1,'','');
c2=finemap(cmap2,'','');
cmap=[c1(end:-1:1,:); glue; glue;glue;glue;glue; glue;glue;glue;glue; ...
    glue;glue;glue;glue; glue;glue;glue;glue; glue;glue;glue;glue; glue;glue;glue; c2];
