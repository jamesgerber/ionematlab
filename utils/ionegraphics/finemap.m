function varargout=finemap(cmap,lowercolor);
% FINEMAP - interpolate the colormap finely and put blue on the bottom
%
%  Syntax
%
%
%    finemap(colormap,lowercolor);
%
%    colormap may be a colormap, or a text string
%
%    lowercolor may be '' (empty) or 'aqua'
%
%    'DesertToGreen2'
%    'GreenToDesert2'
%    colormap may be one of the built-in matlab colormaps (see below)
%
%  
%    hsv        - Hue-saturation-value color map.
%    hot        - Black-red-yellow-white color map.
%    gray       - Linear gray-scale color map.
%    bone       - Gray-scale with tinge of blue color map.
%    copper     - Linear copper-tone color map.
%    pink       - Pastel shades of pink color map.
%    white      - All white color map.
%    flag       - Alternating red, white, blue, and black color map.
%    lines      - Color map with the line colors.
%    colorcube  - Enhanced color-cube color map.
%    vga        - Windows colormap for 16 colors.
%    jet        - Variant of HSV.
%    prism      - Prism color map.
%    cool       - Shades of cyan and magenta color map.
%    autumn     - Shades of red and yellow color map.
%    spring     - Shades of magenta and yellow color map.
%    winter     - Shades of blue and green color map.
%    summer     - Shades of green and yellow color map.

if nargin==0
    cmap='DesertToGreen2';
end

if nargin<2
    lowercolor='aqua';
end

if ~isnumeric(cmap)
    cmap=StringToMap(cmap);
end

switch lowercolor
    case ''
        lc=[];
    case 'aqua'
        lc=[    0.0352    0.4258    0.5195];
    case 'blue'
        lc=[127/255 1 212/255];
    otherwise
        error(['don''t know this lowercolor bound'])
end
map=cmap;

x=1:length(map);
xx=1:.1:x(end);

for j=1:3;
  mapp(:,j)=interp1(x,map(:,j),xx);
end

if ~isempty(lc)
    mapp(2:end+1,:)=mapp;
    mapp(1,:)=lc;
end


if nargout==0
    colormap(mapp)
else
    varargout{1}=mapp;
end

%%%%%%%%%%%%%%%
% StringToMap %
%%%%%%%%%%%%%%%
function cmap=StringToMap(str);

try
    cmap=colormap(str)
catch
    switch str
        case {'DesertToGreen2','deserttogreen2'}
            SystemGlobals
            cmap=ReadTiffCmap([IoneDataDir '/misc/DesertToGreen2.tiff']);
        case {'GreenToDesert2','greentodesert2'}
            SystemGlobals
            [dum,cmap]=ReadTiffCmap([IoneDataDir '/misc/DesertToGreen2.tiff']);
        otherwise
            error([' don''t know this colormap '])
    end
end
