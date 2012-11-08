function makedark(Data,Title,FileName,coloraxis,colormap)
% makedark(Data,Title,FileName,coloraxis,colormap);

if nargin<2
    Title='Data';
    FileName='outputfig.tif';
end

if nargin<3
        FileName='outputfig.tif';
end

if nargin<4
    coloraxis=[];
end

if isempty(coloraxis)
    Data(Data~=0  & isfinite(Data))=10;
    coloraxis=[0 1];
end

if nargin<5
    colormap='jfgreen-brown';
end


Data=double(Data);

ii=find(Data >= 1e9);
if length(ii)>0
    disp([' Found elements >= 1E9.  replacing with 0. '])
    Data(ii)=0;
end

SystemGlobals
surf=AMTPlot(Data,Title,coloraxis);

%amtfinemap
print -dtiffn -r300 '~/.AMTSURFtmp.tif';
print -dtiffn -r300 'AMTSURFtmp.tif';
COLOR=imread(['~/.AMTSURFtmp.tif']);

COLOR=imresize(imcrop(COLOR,[340,400,1804,1100]),[960,1600]);
imwrite(COLOR,FileName);
%imwrite(COLOR,'tmp2.tif','Resolution',144);
close all;




function h=AMTPlot(Data,Title,colorvals);

Data=Data(:,end:-1:1);

hfig=figure;
pos=get(hfig,'Position');
pos=pos.*[1 1 1.5 .9];
set(hfig,'Position',pos);

R=[12,90,-180];
axesm robinson;
h=meshm(Data.',R);
shading flat
set(gcf,'Renderer','zbuffer');
zoom on;
set(hfig,'Color',[.5,.5,.5]);

text(0,-1.85,0,Title,'HorizontalAlignment','center');
showaxes('hide')
caxis(colorvals);
h=gcf;
