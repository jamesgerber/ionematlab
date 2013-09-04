function linecolor=getlinecolor(j,cmap);
% GETLINECOLOR - return a unique line color
%
%  SYNTAX  
%        getlinecolor(INDEX) returns a 3 element RGB color vector pulled
%        from 'sixteencolors' colormap
%        getlinecolor(INDEX,cmap) returns a 3 element RGB color vector
%        pulled from colormap cmap
%
%  EXAMPLE
%
%   figure
%   t=0:.05:1;
%   for j=1:20
%      plot(t,sin( t*j),'color',getlinecolor(j));
%      hold on
%   end

if nargin==1
    cmap='sixteencolors';
end

cmap=ReadTiffCmap([iddstring '/misc/colormaps/' cmap '.tiff']);

cred=unique(cmap(2:end-1,:),'rows');

N=size(cred,1);

if j>N
    j=mod(j,N);
end

linecolor=cred(j,:);