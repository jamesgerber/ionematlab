function I=hashmarks(im,mask,color,space,width,dir,filename)
% Both must be either normal 1-D arrays or images. Can't do one of each.
% Must be same size.
if size(im,3)==1
    nsg(im);
    outputfig('force','tmpim.png');
    centerfigure('tmpim.png');
    mtnicesurfgeneral(mask);
    outputfig('force','tmpmask.png');
    centerfigure('tmpmask.png');
    im=imread('tmpim.png');
    mask=imread('tmpmask.png');
    c1=0.0*maxval(im);
    c2=0.243*maxval(im);
    c3=0.153*maxval(im);
    delete('tmpim.png');
    delete('tmpmask.png');
else
    c1=mask(1,1,1);
    c2=mask(1,1,2);
    c3=mask(1,1,3);
end
close all;
if (nargin<3)
    color=[0.0,0.0,0.0];
end
if (nargin<4)
    space=size(im,2)/200;
end
if (nargin<5)
    width=space/10;
end
if (nargin<6)
    dir=.5;
end
tol=maxval(mask)/32;
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
I=im; 
if (nargin==6)
    imwrite(I,filename);
end