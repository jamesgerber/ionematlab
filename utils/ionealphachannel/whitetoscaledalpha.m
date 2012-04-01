function whitetoscaledalpha(OldFileName,NewFileName,ScaleFileName);
% WhiteToAlpha - replace white with full transparency, non-white with 1/2
%
%  Example
%
%   whitetoscaledalpha(OldFileName,NewFileName,ScaleFileName);
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