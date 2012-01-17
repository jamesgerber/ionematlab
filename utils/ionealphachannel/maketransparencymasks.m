function maketransparencymasks(res)
% maketransparencymasks - make masks of figure areas to make transparent

if nargin==0
   maketransparencymasks('r150');
   maketransparencymasks('r300');
   maketransparencymasks('r600');
   return
end
ii=datablank;

NSS.cmap=0*ones(size(colormap));%[1 1 1; 1 1 1];

switch res
    case 'r150';        
        NSS.Resolution='-r150';
        FileName=[iddstring '/misc/mask/OutputMask_colorbar_r150.png'];
        FileNameNCB=[iddstring '/misc/mask/OutputMask_nocolorbar_r150.png'];
        FileNameOceans=[iddstring '/misc/mask/OutputMask_oceans_r150.png'];

    case 'r300';        
        NSS.Resolution='-r300';
        FileName=[iddstring '/misc/mask/OutputMask_colorbar_r300.png'];
        FileNameNCB=[iddstring '/misc/mask/OutputMask_nocolorbar_r300.png'];
        FileNameOceans=[iddstring '/misc/mask/OutputMask_oceans_r300.png'];
    case 'r600';        
        NSS.Resolution='-r600';
        FileName=[iddstring '/misc/mask/OutputMask_colorbar_r600.png'];
        FileNameNCB=[iddstring '/misc/mask/OutputMask_nocolorbar_r600.png'];
        FileNameOceans=[iddstring '/misc/mask/OutputMask_oceans_r600.png'];


end

MaxNumFigs=callpersonalpreferences('maxnumfigsNSG');

if length(allchild(0)) > MaxNumFigs
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