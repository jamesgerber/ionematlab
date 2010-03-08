function rmap
%RMAP - reverse colormap
%
%  
c=colormap;
colormap(c(end:-1:1,:));