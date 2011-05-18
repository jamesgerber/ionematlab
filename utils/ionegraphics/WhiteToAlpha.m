function WhiteToAlpha(OldFileName,NewFileName);
% WhiteToAlpha - replace white with full transparency, non-white with 1/2
%
%  Example
%
%   WhiteToAlpha(OLDFILENAME,NEWFILENAME);
%

OldFileName=fixextension(OldFileName,'.png');

plotimage=imread(OldFileName);


if nargin==1
    NewFileName=strrep(OldFileName,'.png','_alpha.png');
end

a=plotimage;

ii=(a(:,:,1)>=254 & a(:,:,2) >=254 & a(:,:,3)>=254);


Alpha=~ii+0.5*ii;

imwrite(plotimage,NewFileName,'png','Alpha',double(Alpha));%,'Background',ones(size(Alpha)));