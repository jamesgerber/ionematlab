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
%     nsg(y,'filename','test_mtb.png','title','maize yield','caxis',.98,...
%     'cmap','summer','units','tons/ha')
%
%     maketransparentbackground('test_mtb','test_mtb_alpha',[.4 .4 .5])
%
%     maketransparentbackground('test_mtb','test_mtb_alpha',umnmaroon)
%
%    see also maketransparencymasks

OldFileName=fixextension(OldFileName,'.png');

plotimage=imread(OldFileName);

if nargin==1
    NewFileName=strrep(OldFileName,'.png','_alpha.png');
end




ver=version;
VerNo=ver(1)
vs=['ver' VerNo '_'];  % ' vs '


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

a=plotimage;

res=['size' num2str(size(a,1)) '_' num2str(size(a,2))];


FileName=[iddstring '/misc/mask/OutputMask_colorbar_' res '.png'];
FileNameNCB=[iddstring '/misc/mask/OutputMask_nocolorbar_' res '.png'];
FileNameOceans=[iddstring '/misc/mask/OutputMask_oceans_' res '.png'];
FileNameAgriMask=[iddstring '/misc/mask/OutputMask_agrimask_' res '.png'];
FileNamePT=[iddstring '/misc/mask/OutputMask_PT_' res '.png'];

a=imread(FileName);
ancb=imread(FileNameNCB);
apt=imread(FileNamePT);
%aocean=imread(FileNameOceans);
%aagrimask=imread(FileNameAgriMask);


a=apt;   % i think this is all we need to do ... to include panoply triangles




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

