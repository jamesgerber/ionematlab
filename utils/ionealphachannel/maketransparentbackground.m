function maketransparentbackground(OldFileName,NewFileName,TextColor);
% maketransparentbackground - add a transparent channel around a figure
%
%  Example
%   Syntax
%        maketransparentbackground(OLDFILENAME,NEWFILENAME);
%
%        maketransparentbackground(OLDFILENAME,NEWFILENAME,TEXTCOLOR);
%
%        maketransparentbackground(OLDFILENAME,TEXTCOLOR);
%    TEXTCOLOR is a three element vector
%
%
%   Example
%
%     m=getdata('maize');
%     y=m.Data(:,:,2);
%     nsg(y,'filename','test_mtb.png','title','maize yield','caxis',.98)
%
%     maketransparentbackground('test_mtb','test_mtb_alpha',[.4 .4 .5])
%
%    see also

OldFileName=fixextension(OldFileName,'.png');

plotimage=imread(OldFileName);

KeepText=0;
if ~ischar(NewFileName)
    TextColor=NewFileName;
    NewFileName=strrep(OldFileName,'.png','_alpha.png');
    NewFileName=[makesafestring(NewFileName(1:end-4)) '.png']
    NewFileName=fixextension(NewFileName,'.png');
    KeepText=1;
end

if nargin==1
    NewFileName=strrep(OldFileName,'.png','_alpha.png');
    NewFileName=[makesafestring(NewFileName(1:end-3)) '.png']
else
    NewFileName=fixextension(NewFileName,'.png');
end



if nargin>=3
    KeepText=1;
end

    

try
    switch(size(plotimage,1))
        case 633
            a=imread([iddstring '/misc/mask/OutputMask_colorbar_r150.png']);
            ancb=imread([iddstring '/misc/mask/OutputMask_nocolorbar_r150.png']);
        case 1266
            a=imread([iddstring '/misc/mask/OutputMask_colorbar_r300.png']);
            ancb=imread([iddstring '/misc/mask/OutputMask_nocolorbar_r300.png']);
        case 2534
            a=imread([iddstring '/misc/mask/OutputMask_colorbar_r600.png']);
            ancb=imread([iddstring '/misc/mask/OutputMask_nocolorbar_r600.png']);
        otherwise
            error(['don''t know this resolution.   need to modify or run maketransparencymasks'])
    end
catch
    error(['prob need to run maketransparencymasks'])
end



ii_background=(ancb(:,:,1)==255 & ancb(:,:,2) ==255 & ancb(:,:,3)==255);
ii_foreground=~ii_background;

b=plotimage;
ii_colorbar= ~((a(:,:,1) ~=ancb(:,:,1)) | (a(:,:,2) ~=ancb(:,:,2)) | (a(:,:,3) ~=ancb(:,:,3)));
ii_text= ((a(:,:,1) ~=b(:,:,1)) | (a(:,:,2) ~=b(:,:,2)) | (a(:,:,3) ~=b(:,:,3)))  ...
    & ~ii_foreground & ii_colorbar;


% what should we keep?



if KeepText==0;
    Alpha=~ii_background | ~ii_colorbar;
    imwrite(plotimage,NewFileName,'png','Alpha',uint8(Alpha*255));
else
    Alpha=(~ii_background | ~ii_colorbar ) ;
    Alpha(ii_text)=1;
    x=plotimage(:,:,1); x(ii_text)=TextColor(1)*255; plotimage(:,:,1)=x;
    x=plotimage(:,:,2); x(ii_text)=TextColor(2)*255; plotimage(:,:,2)=x;
    x=plotimage(:,:,3); x(ii_text)=TextColor(3)*255; plotimage(:,:,3)=x;
    imwrite(plotimage,NewFileName,'png','Alpha',uint8(Alpha*255));
end    
    
