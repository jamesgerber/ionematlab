function MakeGlobalOverlay(Data,colormap,coloraxis,FullFileName,BaseTransparency,Nlong,Nlat);
% MakeGlobalOverlay - Make a .png with an alpha channel background 
%
%  Syntax
%  
%      MakeGlobalOverlay(Data,colormap,coloraxis,FileSaveName,BaseOpacity,Nlong,Nlat);
%
%  Note:  any values with NaN will be made completely transparent
% 
%  Example
%
% SystemGlobals
%   S=OpenNetCDF([iddstring '/Crops2000/crops/maize_5min.nc'])
% 
%   Area=S.Data(:,:,1);
%   Yield=S.Data(:,:,2);
%   Yield(Yield>1e10)=NaN;
%  Data=Yield;
%  cmap=finemap(colormap);
%  coloraxis=[0 12]
%  MakeGlobalOverlay(Data,cmap,[0 12],'fig2.png',0.5)


if nargin==0
  help(mfilename)
  return
end


if nargin==7
    % user wishes to change long/lat resolution
    [long,lat]=InferLongLat(Data);
    [newlong,newlat]=InferLongLat(ones(Nlong,Nlat));
    NewData=interp2(lat,long,Data,newlat',newlong);
    Data=NewData; 
end



ii=find(Data > 1e9 | Data < -1e9);
if length(ii) > 1
    disp(['Found some values of abs(Data) > 1e9, replacing with NaN']);
    Data(ii)=NaN;
end

if nargin<2
  colormap='jet';
end
if nargin<3 | isempty(coloraxis)
  ii=find(isfinite(Data));
  tmp01=Data(ii);
  coloraxis=[min(tmp01) max(tmp01)]
end
if nargin<4
  [filename,pathname]=uiputfile('*.png','Save file name');
  FullFileName=fullfile(pathname,filename);
end
if nargin<5
  BaseTransparency=0.5;
end

FullFileName=fixextension(FullFileName,'.png');

if length(coloraxis)==1
      OSS=NiceSurfGeneral(Data,'coloraxis',[coloraxis],'plotflag','off')
    %OSS will contain field coloraxis, and no plot will be made.
coloraxis=OSS.coloraxis;
end


iiNaN=find(isnan(Data)|(Data<=0));
iiNaN=find(isnan(Data));

Alpha=ones(size(Data))*BaseTransparency;

Alpha(iiNaN)=0;

imagearray=zeros([size(Data) 3]);

cmap=finemap(colormap,'','');

cmax=coloraxis(2);
cmin=coloraxis(1);
minstep= (cmax-cmin)*.001;

Data(Data>cmax)=(cmax-minstep);
Data(cmin>Data)=(cmin+minstep);


scaled=(Data-coloraxis(1))/(diff(coloraxis));
scaled(scaled>1)=1;
scaled(scaled<0)=0;

%loop to scale to colormap
for j=1:3
  imagearray(:,:,j)=scalecolors(scaled,cmap(:,j));
end

% loop to scale NaNs to white [doesn't really matter: will make
% them 100% transparent later.  nice to do only for intermediate visualization.]
for j=1:3
  tmp=imagearray(:,:,j);
  tmp(iiNaN)=255;
  imagearray(:,:,j)=tmp;
end
  
% loop to rotate imagearray
for j=1:3;
  newimagearray(:,:,j)=  imagearray(:,:,j).';
  Alpha=Alpha.';
end
imagearray=newimagearray;

imagearray=uint8(imresize(imagearray,1));  %andrew had this at .1  not sure why
% image(imagearray)
 imwrite(imagearray,FullFileName,'png','Alpha',uint8(EasyInterp2(Alpha*255,1)));