function maketransparentoceans(OldFileName,NewFileName,TextColor,AgFlag);
% maketransparentoceans - add a transparent channel around landmass
%
%  Example
%   Syntax
%        maketransparentoceans(OLDFILENAME,NEWFILENAME);
%
%        maketransparentoceans(OLDFILENAME,NEWFILENAME,TEXTCOLOR);
%
%        maketransparentoceans(OLDFILENAME,NEWFILENAME,TEXTCOLOR,AGFLAG);%
%
%        maketransparentoceans(OLDFILENAME,TEXTCOLOR);
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
%     maketransparentoceans('test_mtb','test_mto_alpha_white',[1 1 1])
%
%     maketransparentoceans('test_mtb','test_mto_alpha_umnmaroon',umnmaroon)
%
%     maketransparentoceans('test_mtb','test_mto_alpha_agrimask_umnmaroon',umnmaroon,1)
%
%    see also maketransparencymasks maketransparentbackground maketransparentoceans

if nargin<4
    AgFlag=0;
end


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
            aocean=imread([iddstring '/misc/mask/OutputMask_oceans_r150.png']);
            aagrimask=imread([iddstring '/misc/mask/OutputMask_agrimask_r150.png']);
            
        case 1266
            a=imread([iddstring '/misc/mask/OutputMask_colorbar_r300.png']);
            ancb=imread([iddstring '/misc/mask/OutputMask_nocolorbar_r300.png']);
            aocean=imread([iddstring '/misc/mask/OutputMask_oceans_r300.png']);
            aagrimask=imread([iddstring '/misc/mask/OutputMask_agrimask_r300.png']);
            
        case 2534
            a=imread([iddstring '/misc/mask/OutputMask_colorbar_r600.png']);
            ancb=imread([iddstring '/misc/mask/OutputMask_nocolorbar_r600.png']);
            aocean=imread([iddstring '/misc/mask/OutputMask_oceans_r600.png']);
            aagrimask=imread([iddstring '/misc/mask/OutputMask_agrimask_r600.png']);
 
        case 2534
            a=imread([iddstring '/misc/mask/OutputMask_colorbar_r600.png']);
            ancb=imread([iddstring '/misc/mask/OutputMask_nocolorbar_r600.png']);
            aocean=imread([iddstring '/misc/mask/OutputMask_oceans_r600.png']);
            aagrimask=imread([iddstring '/misc/mask/OutputMask_agrimask_r600.png']);

        case 5066
            a=imread([iddstring '/misc/mask/OutputMask_colorbar_r1200.png']);
            ancb=imread([iddstring '/misc/mask/OutputMask_nocolorbar_r1200.png']);
            aocean=imread([iddstring '/misc/mask/OutputMask_oceans_r1200.png']);
            aagrimask=imread([iddstring '/misc/mask/OutputMask_agrimask_r1200.png']);

            
        otherwise
            warndlg(['don''t know this resolution.   attempting to run maketransparencymasks'])
            x=personalpreferences('printingres');
            res=x(2:end)
            
            try
                maketransparencymasks(res)
                a=imread([iddstring '/misc/mask/OutputMask_colorbar_' res '.png']);
                ancb=imread([iddstring '/misc/mask/OutputMask_nocolorbar_' res '.png']);
                aocean=imread([iddstring '/misc/mask/OutputMask_oceans_' res '.png']);
                aagrimask=imread([iddstring '/misc/mask/OutputMask_agrimask_' res '.png']);

            catch
                warning(['maketransparencymasks didn''t work. possible reasons '...
                    'include too many figures currently open.  also, best' ...
                    'to set resolution via personalpreferences'])
                error(['maketransparencymasks didn''t work.'])
            end
            
            
            
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

ii_ocean=(aocean(:,:,1)==255 & aocean(:,:,2) ==255 & aocean(:,:,3)==255);

ii_ag=(aagrimask(:,:,1)==255 & aagrimask(:,:,2) ==255 & aagrimask(:,:,3)==255);

% what should we keep?

% to do:  pull two loops below together by making ii_ag = field of ones
%         remove somewhat embarassing FlipToZero

if AgFlag==0
    
    if KeepText==0;
        Alpha=(~ii_background | ~ii_colorbar )& ii_ocean ;
        FlipToZero=(Alpha==1 & ii_ag==0);
        Alpha(FlipToZero)=0;
        
        imwrite(plotimage,NewFileName,'png','Alpha',uint8(Alpha*255));
    else
        Alpha=(~ii_background | ~ii_colorbar )& ii_ocean ; ;
        Alpha(ii_text)=1;
        x=plotimage(:,:,1); x(ii_text)=TextColor(1)*255; plotimage(:,:,1)=x;
        x=plotimage(:,:,2); x(ii_text)=TextColor(2)*255; plotimage(:,:,2)=x;
        x=plotimage(:,:,3); x(ii_text)=TextColor(3)*255; plotimage(:,:,3)=x;
        imwrite(plotimage,NewFileName,'png','Alpha',uint8(Alpha*255));
    end
    
else
    
    if KeepText==0;
        Alpha=(~ii_background | ~ii_colorbar )& ii_ocean ;
        FlipToZero=(Alpha==1 & ii_ag==0);
        Alpha(FlipToZero)=0;
        imwrite(plotimage,NewFileName,'png','Alpha',uint8(Alpha*255));
    else
        Alpha=(~ii_background | ~ii_colorbar )& ii_ocean ;
        FlipToZero=(Alpha==1 & ii_ag==0);
        Alpha(FlipToZero)=0;
        
        Alpha(ii_text)=1;
        x=plotimage(:,:,1); x(ii_text)=TextColor(1)*255; plotimage(:,:,1)=x;
        x=plotimage(:,:,2); x(ii_text)=TextColor(2)*255; plotimage(:,:,2)=x;
        x=plotimage(:,:,3); x(ii_text)=TextColor(3)*255; plotimage(:,:,3)=x;
        imwrite(plotimage,NewFileName,'png','Alpha',uint8(Alpha*255));
    end
end

