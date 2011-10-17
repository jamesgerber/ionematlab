function GrayToScaledAlpha(OldFileName,NewFileName,ScaleFileName);
% GrayToScaledAlpha - render a figure proportionally transparent 
%
%  Example
%
%   GrayToScaledAlpha(OLDFILENAME,NEWFILENAME,SCALEFILENAME);
%

OldFileName=fixextension(OldFileName,'.png');
ScaleFileName=fixextension(ScaleFileName,'.png');

plotimage=imread(OldFileName);

scaleimage=imread(ScaleFileName);


if nargin==1
    NewFileName=strrep(OldFileName,'.png','_alpha.png');
end

a=plotimage;

ii=(a(:,:,1)>=254 & a(:,:,2) >=254 & a(:,:,3)>=254);


Alpha=(double(255-scaleimage(:,:,1))/255);;

imwrite(plotimage,NewFileName,'png','Alpha',double(Alpha));%,'Background',ones(size(Alpha)));