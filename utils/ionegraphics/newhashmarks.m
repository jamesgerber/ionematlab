function newhashmarks(mapfilename,maskfilename,newfilename,color,space,width,dir);
% newhashmarks - put hashmarks on a .png file
%
% SYNTAX:  newhashmarks(mapimagefilename,maskfilename)
%
%
%      where mapimagefilename  = name of a file with a map in .png format
%            maskimagefilename = name of a file with a mask in .png format
%
%            whereever the map image = red ( [1 0 0 ] in RGB values), the
%            mask image will be covered with hashmarks.  output will go to
%            "mapimagefilename_hash.png"
%
%     additional options
%
%        newhashmarks(mapfilename,maskfilename,newfilename,color,space,width,dir);
%
%                 newfilename - output name for file
%                 color       - color for hashmarks
%                 space       - spacing for hashmarks
%                 width       - width of hashmarks
%                 dir         - direction of hashmarks
%
%
%   Example
%
% ii=countrycodetooutline('USA');
% jj=ones(size(ii))+double(ii);
% %
% clear NSS
% NSS.categorical='on';
% NSS.categoryranges=[1 2];
% NSS.categoryvalues={' not USA',' USA ' };
% NSS.filename='testhashmarks.png';
% %    NSS.colormap={'b','lime'};
% NSS.separatecatlegend='yes';
% NSS.categoryspecialcolormap=[1 0 0];
% NSS.categoryspeciallegend={' ice cream sandwiches '};
% OS=nsg(jj,NSS)
% OS2=nsg(ii==1,'filename','testmask.png','cbarvisible','off','cmap',[0 0 0;0 0 0;0 0 0; 1 0 0]);
% newhashmarks(OS.ActualFileName,OS2.ActualFileName)%,newfilename,color,space,width,dir);

im=imread(fixextension(mapfilename,'.png'));
mask=imread(fixextension(maskfilename,'.png'));


if nargin<3
    mapfilename=fixextension(mapfilename,'.png');
    newfilename=strrep(mapfilename,'.png','_hash.png');
end

if (nargin<4)
    color=[0.0,0.0,0.0];
end
if (nargin<5)
    space=size(im,2)/200;
end
if (nargin<6)
    width=space/10;
end
if (nargin<7)
    dir=.5;
end
tol=maxval(mask)/32;

c1=255;
c2=0;
c3=0;

% alternate approach:  construct an image of hashmarks.

iimask=mask(:,:,1)==c1 & mask(:,:,2)==c2 & mask(:,:,3)==c3;

hashmarkimage=zeros(size(im));




for i=1:size(im,1)
    for j=1:size(im,2)
        if (closeto(mask(i,j,1),c1,tol)&&closeto(mask(i,j,2),c2,tol)&&closeto(mask(i,j,3),c3,tol))
            if closeto(0,mod(i*sin(dir*pi/2)+j*cos(dir*pi/2),space),width)
                im(i,j,1)=color(1);
                im(i,j,2)=color(2);
                im(i,j,3)=color(3);
            end
        end
    end
end

imwrite(im,newfilename);