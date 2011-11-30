function maketransparentbackground(OldFileName,NewFileName);
% maketransparentbackground - add a transparent channel around a figure
%
%  Example
%
%   maketransparentbackground(OLDFILENAME,NEWFILENAME);
%

OldFileName=fixextension(OldFileName,'.png');

plotimage=imread(OldFileName);


if nargin==1
    NewFileName=strrep(OldFileName,'.png','_alpha.png');
else
    NewFileName=fixextension(NewFileName,'.png');
end

    

try
    switch(size(plotimage,1))
        case 633
            a=imread([iddstring '/misc/mask/OutputMaskr150.png']);
        case 1266
            a=imread([iddstring '/misc/mask/OutputMaskr300.png']);
        case 2534
            a=imread([iddstring '/misc/mask/OutputMaskr600.png']);
        otherwise
            error(['don''t know this resolution.'])
    end
catch
    error(['need masks in ' iddstring '/misc/mask/OutputMaskr600.png']);
end



ii_background=(a(:,:,1)==255 & a(:,:,2) ==255 & a(:,:,3)==255);
ii_foreground=~ii;

% anything else we should save?
Alpha=~ii_background;

imwrite(plotimage,NewFileName,'png','Alpha',uint8(Alpha*255));

