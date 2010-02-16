function [colormap,reversecolormap]=ReadTiffCmap(FileName);
% READTIFFCMAP

if nargin==0 & nargout==0
  help(mfilename);
  return
end

if nargin==0
  [filename, pathname] = uigetfile('*.tiff');
  FileName=fullfile(pathname,filename);
end


a=imread(FileName);

colormap=double(squeeze(a(1,1:256,[1 2 3])))/256;
reversecolormap=colormap(end:-1:1,:);


  

