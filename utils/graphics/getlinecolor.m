function linecolor=getlinecolor(j,cmap,Nsteps);
% GETLINECOLOR - return a unique line color
%
%  SYNTAX  
%        getlinecolor(INDEX) returns a 3 element RGB color vector pulled
%        from 'sixteencolors' colormap
%        getlinecolor(INDEX,cmap) returns a 3 element RGB color vector
%        pulled from colormap cmap
%        getlinecolor(INDEX,cmap,Nsteps) returns a 3 element RGB color vector
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
    Nsteps=16;
end

if nargin==2
    Nsteps=16;
end
%if ischar(cmap)
%    cmap=ReadTiffCmap([iddstring '/misc/colormaps/' cmap '.tiff']);
%end

cmapnew=finemap(cmap,'','');

ii=linspace(1,length(cmapnew),Nsteps);
ii=round(ii);

cred=cmapnew(ii,:);


%cred=unique(cmap(2:end-1,:),'rows');

N=size(cred,1);

if j>N
    j=mod(j,N);
end

linecolor=cred(j,:);