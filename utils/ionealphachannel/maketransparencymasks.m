function maketransparencymasks(res)
% maketransparencymasks - make masks of figure areas to make transparent
%
%   This function makes some necessary masks to allow us to make
%   transparent backgrounds using maketransparentoceans.
%
%  This can be called automatically by maketransparentoceans, or you can
%  call it from the commandline without arguments
if nargin==0
   maketransparencymasks('r150');
   maketransparencymasks('r300');
   maketransparencymasks('r600');
   maketransparencymasks('r1200');
   return
end
ii=datablank;

NSS.cmap=0*ones(size(colormap));%[1 1 1; 1 1 1];


% lines of code to make sure there is a directory for the masks.


if exist([iddstring '/misc/mask']) ~=7
    warndlg(['creating directory '  iddstring '/misc/mask'])
    mkdir([iddstring '/misc/mask'])
end

switch res
    case 'r150';        
        NSS.Resolution='-r150';
        FileName=[iddstring '/misc/mask/OutputMask_colorbar_r150.png'];
        FileNameNCB=[iddstring '/misc/mask/OutputMask_nocolorbar_r150.png'];
        FileNameOceans=[iddstring '/misc/mask/OutputMask_oceans_r150.png'];
        FileNameAgriMask=[iddstring '/misc/mask/OutputMask_agrimask_r150.png'];

    case 'r300';        
        NSS.Resolution='-r300';
        FileName=[iddstring '/misc/mask/OutputMask_colorbar_r300.png'];
        FileNameNCB=[iddstring '/misc/mask/OutputMask_nocolorbar_r300.png'];
        FileNameOceans=[iddstring '/misc/mask/OutputMask_oceans_r300.png'];
        FileNameAgriMask=[iddstring '/misc/mask/OutputMask_agrimask_r300.png'];
    case 'r600';        
        NSS.Resolution='-r600';
        FileName=[iddstring '/misc/mask/OutputMask_colorbar_r600.png'];
        FileNameNCB=[iddstring '/misc/mask/OutputMask_nocolorbar_r600.png'];
        FileNameOceans=[iddstring '/misc/mask/OutputMask_oceans_r600.png'];
        FileNameAgriMask=[iddstring '/misc/mask/OutputMask_agrimask_r600.png'];
   case 'r1200';        
        NSS.Resolution='-r1200';
        FileName=[iddstring '/misc/mask/OutputMask_colorbar_r1200.png'];
        FileNameNCB=[iddstring '/misc/mask/OutputMask_nocolorbar_r1200.png'];
        FileNameOceans=[iddstring '/misc/mask/OutputMask_oceans_r1200.png'];
        FileNameAgriMask=[iddstring '/misc/mask/OutputMask_agrimask_r1200.png'];

    otherwise
        disp('warning ... using a new resolution ... making masks')
        NSS.Resolution=['-' res];
        res
        FileName=[iddstring '/misc/mask/OutputMask_colorbar_' res '.png'];
        FileNameNCB=[iddstring '/misc/mask/OutputMask_nocolorbar_' res '.png'];
        FileNameOceans=[iddstring '/misc/mask/OutputMask_oceans_' res '.png'];
        FileNameAgriMask=[iddstring '/misc/mask/OutputMask_agrimask_' res '.png'];

        

end

MaxNumFigs=callpersonalpreferences('maxnumfigsNSG');

if getnumionesurffigs > MaxNumFigs
    warndlg('too many figures currently open.')
    error('too many figures currently open.')
end
    
% Figure that is white everywhere
NSS.cmap=0*ones(size(colormap));


nsg(ii,NSS)
fud=get(gcf,'userdata')
set(fud.ColorbarHandle,'XTick',[]);
OutputFig('Force',FileName,NSS.Resolution);

set(fud.ColorbarHandle,'Visible','off')
OutputFig('Force',FileNameNCB,NSS.Resolution);

% now the only oceans colormap
NSS.cmap=ones(size(colormap));
fud=get(gcf,'userdata')
set(fud.ColorbarHandle,'Visible','off')
set(fud.ColorbarHandle,'XTick',[]);
close

nsg(1-ii,NSS,'lowercolor','black')
OutputFig('Force',FileNameOceans,NSS.Resolution);
close
% now the agri-mask colormap

ii=AgriMaskLogical;
jj=LandMaskLogical;
kk=(jj & ~ii);
k=double(kk);
k(k==1)=NaN;

nsg(k,NSS,'lowercolor','black','uppercolor','black')
fud=get(gcf,'userdata')

set(fud.ColorbarHandle,'Visible','off')
set(fud.ColorbarHandle,'XTick',[]);

OutputFig('Force',FileNameAgriMask,NSS.Resolution);
close