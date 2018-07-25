function outputfilename=newhashmarks(mapfilename,maskfilename,newfilename,color,space,width,dir);
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
%  Recommended resolution at least: 600
%  OK to pass in empty arrays to get defaults
%
%   Example:
%
% ii=countrycodetooutline('USA');
% jj=ones(size(ii))+double(ii);
%
% OS=nsg(landmasklogical,'filename','testhashmarks.png','resolution','-r600')
% OS2=nsg(ii==1,'filename','testmask.png','cbarvisible','off','cmap',[0 0 0;0 0 0;0 0 0; 1 0 0],'resolution','-r600');
% newhashmarks(OS.ActualFileName,OS2.ActualFileName,'testfigwithhashmarks1.png')%,newfilename,color,space,width,dir);
% newhashmarks('testfigwithhashmarks1.png',OS2.ActualFileName,'testfigwithhashmarks2.png',[],[],[],-.5)%,newfilename,color,space,width,dir);



im=imread(fixextension(mapfilename,'.png'));
mask=imread(fixextension(maskfilename,'.png'));


if nargin<3
    mapfilename=fixextension(mapfilename,'.png');
    newfilename=strrep(mapfilename,'.png','_hash.png');
else
    newfilename=fixextension(newfilename,'.png');
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

% these might all be blank if user passed in defaults

if isempty(color)
        color=[0.0,0.0,0.0];
end

if isempty(space)
    space=size(im,2)/200;
end

if isempty(width)
    width=space/10;
end

if isempty(dir)
    dir=0.5;
end


tol=maxval(mask)/32;

c1=255;   % this is red
c2=0;
c3=0;

legacy=0;

if legacy==1
    tic
    for i=1:size(im,1)
        for j=1:size(im,2)
            % Checks if mask band values are close to 255,0,0 tolerance
            % allows values to differ
            %if(closeto(mask(i,j),[c1,c2,c3],tol))
             if (closeto(mask(i,j,1),c1,tol) && closeto(mask(i,j,2),c2,tol) && closeto(mask(i,j,3),c3,tol))
                %if closeto(0,mod(i*sin(dir*pi/2)+j*cos(dir*pi/2),space),width)
                if closeto(0,mod(j,space),width)
                    im(i,j,1)=color(1);
                    im(i,j,2)=color(2);
                    im(i,j,3)=color(3);
                end
            end
        end
    end
    toc
else

    tic
    iimask=mask(:,:,1)==c1 & mask(:,:,2)==c2 & mask(:,:,3)==c3;
    
        
    tempi = 1:size(im,2);
    tempj = (1:size(im,1))';
    tempi = repmat(tempi,size(im,1),1);
    tempj = repmat(tempj,1,size(im,2));
    
   
   hashmark = closeto(0, mod(tempi*sin(dir*pi/2)+tempj*cos(dir*pi/2), space),width);
   %hashmark = closeto(mod(tempi, space) + mod(tempj, space), 0, width);
   
   
   redMask = closeto(mask(:,:,1),c1,tol) & closeto(mask(:,:,2),c2,tol) & closeto(mask(:,:,3),c3,tol);
   hashmark = redMask & hashmark;
   
   
   iichangetohashmark=hashmark;

   for mm=1:3
       tempimlayer=im(:,:,mm);
       tempimlayer(iichangetohashmark)=color(mm);
       im(:,:,mm)=tempimlayer;
   end
   
   toc

    
end






imwrite(im,newfilename);

if nargout==1
    outputfilename=newfilename;
end