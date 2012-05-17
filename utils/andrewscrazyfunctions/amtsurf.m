function amtsurf(Data,Title,FileName,colormap,cutoff,coloraxis)
% This function renders the given data (held in a 2D matrix containing the
% value of a certain variable, such as a crop's yield, across the world)
% into a world map and then saves that image. It is designed to handle crop
% information (yield, output, etc) but could also be used with certain
% other data, such as wind speed. It would not currently work with
% partially or entirely negative data.

% Data: 2D matrix of data to plot. All sizes are acceptable, but will be 
% scaled to 4320x2160. The upper-left corner of this matrix corresponds to
% the NW corner of the output map, the lower-right corner of the matrix
% corresponds to the SE corner of the map, the upper-right corner of the
% matrix corresponds to the SW corner of the map, and the lower-left
% corner of the matrix corresponds to the NE corner of the map.
% Title: title to print below plot. If this isn't provided by the user, the
% title will be left blank.
% FileName: output image destination given as a string. If this isn't
% provided, the image will be saved in the current directory as
% 'outputfig.tif'.
% colormap: colormap to be used. If this isn't provided, a light green to
% dark green colormap will be used.
% cutoff: fraction of colorbar maximum below which values will be treated
% as 0 and left white in the output map. For example, if .2 is provided,
% all cells containing values below 20% of the colorbar's maximum value
% will be treated as 0. If this isn't provided, .1 will be used.
% coloraxis: [a b] vector specifying the colorbar's minimum and maximum
% values. All values below a that are above the cutoff will be colored with
% the colormap's lowest color, and all above b will be colored with it's
% highest color. If this isn't provided, a will be set to 0 and b will be
% set to the value of the 98th percentile of the input data.

if nargin<1
error('Data required')
end
    
if size(Data)~=[4320 2160]
Data=imresize(Data, [4320 2160]);
end
    
if nargin<2
Title='';
end

if nargin<3
FileName='outputfig.tif';
end

if nargin<4
load '~andrew/greenlightdark';
colormap=greenlightdark(1:round(length(greenlightdark)*.8),:);
end

if nargin<5
cutoff=.00000001;
end

if nargin<6
coloraxis=[];
end

ii=find(Data~=0  & Data<1e9);
tmp01=Data(ii);

tmp01=sort(tmp01);

average=tmp01(round(length(tmp01)*.98));

lower=average*cutoff;

if isempty(coloraxis)
display('Empty coloraxis');
coloraxis=[0 average];
end

% Data that is invalid or less than the cutoff is removed.
Data(Data<lower)=0;
Data=double(Data);
ii=find(Data >= 1e9);
if length(ii)>0
disp([' Found elements >= 1E9.  replacing with 0. '])
Data(ii)=0;
end

systemglobals
% surf is set to a surface plot of the data
surf=AMTPlot(Data,Title,coloraxis);

% finemap imposes the colorbar properly.
finemap(colormap,'white')

% GRAY becomes a matrix representation of andrew/darkrobin.tif, a world map
% which acts as a 'mask' outline of the world.  A temporary image,
% essentially an unformatted printout of the input matrix after being
% stretched and clipped per the input arguments, is saved in
% andrew/AMTSURFtmp.tif, then immediately read into matrix COLOR. COLOR is
% then cross-referenced with GRAY to fill in possible data errors. Then the
% coastlines are drawn over with black lines.
GRAY=imread('~andrew/public/darkrobin.tif');
username=getenv('USER');
print('-dtiffn', '-r300', ['~' username '/AMTSURFtmp.tif']);
COLOR=imread(['~' username '/AMTSURFtmp.tif']);
delete(['~' username '/AMTSURFtmp.tif']);

c1=COLOR(:,:,1);
c2=COLOR(:,:,2);
c3=COLOR(:,:,3);
g1=GRAY(:,:,1);
g2=GRAY(:,:,2);
g3=GRAY(:,:,3);

%% first part
ii=find(((c1==153)&(c2==204)&(c3==255)) ...
        |((c1==255)&(c2==255)&(c3==255)));
c1(ii)=g1(ii);
c2(ii)=g2(ii);
c3(ii)=g3(ii);

%% second part
iicx=[2:1540];
iicy=[2:2399];

iioffset=logical(  (g1(iicx,iicy)==153 & g2(iicx,iicy)==204 & g3(iicx,iicy)==255 ) & ...
				 ...
				 ~(   (g1(iicx-1,iicy)==153 & g2(iicx-1,iicy)==204 & g3(iicx-1,iicy)==255 ) & ...
				   (g1(iicx+1,iicy)==153 & g2(iicx+1,iicy)==204 & g3(iicx+1,iicy)==255 ) & ...
				   (g1(iicx,iicy-1)==153 & g2(iicx,iicy-1)==204 & g3(iicx,iicy-1)==255 ) & ...
				   (g1(iicx,iicy+1)==153 & g2(iicx,iicy+1)==204 & g3(iicx,iicy+1)==255 )));

iitmp=logical(zeros(1800,2400));
iitmp(2:1540,2:2399)=iioffset;

c1(iitmp)=0;
c2(iitmp)=0;
c3(iitmp)=0;

%% third part
iioffset=logical(  (g1(iicx,iicy)==205 & g2(iicx,iicy)==254 & g3(iicx,iicy)==254 ) & ...
				 ~((g1(iicx-1,iicy)==205 & g2(iicx-1,iicy)==254 & g3(iicx-1,iicy)==254 ) & ...
				   (g1(iicx+1,iicy)==205 & g2(iicx+1,iicy)==254 & g3(iicx+1,iicy)==254 ) & ...
				   (g1(iicx,iicy-1)==205 & g2(iicx,iicy-1)==254 & g3(iicx,iicy-1)==254 ) & ...
				   (g1(iicx,iicy+1)==205 & g2(iicx,iicy+1)==254 & g3(iicx,iicy+1)==254 )));

iitmp=logical(zeros(1800,2400));
iitmp(2:1540,2:2399)=iioffset;

c1(iitmp)=0;
c2(iitmp)=0;
c3(iitmp)=0;

COLOR(:,:,1)=c1;
COLOR(:,:,2)=c2;
COLOR(:,:,3)=c3;


% The matrix resulting from the above manipulations is now simply cropped
% and resized, then saved as the provided filename.
COLOR=imresize(imcrop(COLOR,[340,400,1804,1100]),[960,1600]);
if (~isempty(strfind(FileName,'.jpg')))
    imwrite(COLOR,FileName,'Quality',100);
else
    imwrite(COLOR,FileName);
end
close all;




function h=AMTPlot(Data,Title,colorvals);
% AMTPlot uses the Mapping Toolbox to create a surface plot of the given
% data on a Robinson projection of the world. It adds a colorbar to the
% plot.
Data=Data(:,end:-1:1);

hfig=figure;
pos=get(hfig,'Position');
pos=pos.*[1 1 1.5 .9];
set(hfig,'Position',pos);

R=[12,90,-180];
axesm robinson;
h=meshm(Data.',R);
		shading flat;
		gridm('on');
		box off;
		cb=colorbar('location','south');
		set(cb,'position',[.27,.217,.495,.027]);
		
		set(gcf,'Renderer','zbuffer');
		zoom on;
		set(hfig,'Color',[.5,.5,.5]);
		
		text(0,-1.85,0,Title,'HorizontalAlignment','center');
		showaxes('hide')
		caxis(colorvals);
        addstates(.1);
		h=gcf;
