function gridtoimage(primarydata,colormap,alphadata,name)
% GRIDTOIMAGE - saves an image at file 'name', using primarydata and
% colormap to create the color and alphadata as alpha.
%This one line uses ind2rgb to cast grid primarydata as an rgb image.  It
%has to be rotated and flipped to match image formatting.  imwrite is then
%used to save it.  imwrite allows an alpha transparency layer, which is
%used to show alphadata, but there's some calculation and formatting
%involved to make it work.
   imwrite(ind2rgb(round(rot90(fliplr(primarydata))),colormap),...
       name,'Alpha',rot90(fliplr(alphadata))/125+.2*(rot90(fliplr(primarydata))>0));