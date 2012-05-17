function makewhiteoutsidegraph(OldFileName,NewFileName);
%  - add a transparent channel
%
%  Example
%
%   makewhiteoutsidegraph(OLDFILENAME,NEWFILENAME);
%
%  See also AddAlphaOutline

OldFileName=fixextension(OldFileName,'.png');

plotimage=imread(OldFileName);


if nargin==1
    NewFileName=strrep(OldFileName,'.png','_whiteout.png');
end

res=callpersonalpreferences('printingres')
try
    switch res
        case '-r150'
            a=imread([iddstring '/misc/mask/OutputMaskr150.png']);
        case '-r300'
            a=imread([iddstring '/misc/mask/OutputMaskr300.png']);
        case '-r600'
            a=imread([iddstring '/misc/mask/OutputMaskr600.png']);
        otherwise
            error(['don''t know this resolution.'])
    end
catch
    error(['need masks in ' iddstring '/misc/mask/OutputMaskr600.png']);
end



ii=(a(:,:,1)==255 & a(:,:,2) ==255 & a(:,:,3)==255);

tmp=plotimage(:,:,1);
tmp(ii)=255;
plotimage(:,:,1)=tmp;
tmp=plotimage(:,:,2);
tmp(ii)=255;
plotimage(:,:,2)=tmp;
tmp=plotimage(:,:,3);
tmp(ii)=255;
plotimage(:,:,3)=tmp;

imwrite(plotimage,NewFileName);