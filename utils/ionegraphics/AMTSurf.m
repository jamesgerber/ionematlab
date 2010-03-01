function AMTSurf(Data,Title,FileName,coloraxis,colormap);
%  AMTSurf(Data,Title,colorvals)

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
    ii=find(Data~=0  & isfinite(Data));
    tmp01=Data(ii);

    tmp01=sort(tmp01);

    average=tmp01(round(length(tmp01)*.98));
    coloraxis=[0 average];
end

if nargin<5
    colormap='DesertToGreen2';
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
finemap(colormap,'white')

GRAY=imread([IoneDataDir 'misc/darkrobin.tif']);
saveas(surf,['~/.AMTSURFtmp.tif']);
COLOR=imread(['~/.AMTSURFtmp.tif']);

legacy=0;
if legacy==1
    for x=1:900
        for y=1:1200
            if ((COLOR(x,y,1)==153)&&(COLOR(x,y,2)==204)&&(COLOR(x,y,3)==255)||(COLOR(x,y,1)==255)&&(COLOR(x,y,2)==255)&&(COLOR(x,y,3)==255))
                COLOR(x,y,1)=GRAY(x,y,1);
                COLOR(x,y,2)=GRAY(x,y,2);
                COLOR(x,y,3)=GRAY(x,y,3);
            end
            if ((x>1)&&(x<900)&&(y>1)&&(y<1200))
                if (((GRAY(x,y,1)==153)&&(GRAY(x,y,2)==204)&&(GRAY(x,y,3)==255))&&~(((GRAY(x-1,y,1)==153)&&(GRAY(x-1,y,2)==204)&&(GRAY(x-1,y,3)==255))&&((GRAY(x+1,y,1)==153)&&(GRAY(x+1,y,2)==204)&&(GRAY(x+1,y,3)==255))&&((GRAY(x,y-1,1)==153)&&(GRAY(x,y-1,2)==204)&&(GRAY(x,y-1,3)==255))&&((GRAY(x,y+1,1)==153)&&(GRAY(x,y+1,2)==204)&&(GRAY(x,y+1,3)==255))))
                    COLOR(x,y,1)=0;
                    COLOR(x,y,2)=0;
                    COLOR(x,y,3)=0;
                end
            end
            if ((x>1)&&(x<900)&&(y>1)&&(y<1200))
                if (((GRAY(x,y,1)==205)&&(GRAY(x,y,2)==254)&&(GRAY(x,y,3)==254))&&~(((GRAY(x-1,y,1)==205)&&(GRAY(x-1,y,2)==254)&&(GRAY(x-1,y,3)==254))&&((GRAY(x+1,y,1)==205)&&(GRAY(x+1,y,2)==254)&&(GRAY(x+1,y,3)==254))&&((GRAY(x,y-1,1)==205)&&(GRAY(x,y-1,2)==254)&&(GRAY(x,y-1,3)==254))&&((GRAY(x,y+1,1)==205)&&(GRAY(x,y+1,2)==254)&&(GRAY(x,y+1,3)==254))))
                    COLOR(x,y,1)=0;
                    COLOR(x,y,2)=0;
                    COLOR(x,y,3)=0;
                end
            end
        end
        
    end
    LEGACYCOLOR=COLOR;
else
    %new-fangled way
    
    c1=COLOR(:,:,1);
    c2=COLOR(:,:,2);
    c3=COLOR(:,:,3);
    g1=GRAY(:,:,1);
    g2=GRAY(:,:,2);
    g3=GRAY(:,:,3);
    
    %% first part
    ii=find(((c1==153)&(c2==204)&(c3==255)) ...
        |((c1==255)&(c2==255)&(c3==255)));
    c1(ii)=g1(ii);
    c2(ii)=g2(ii);
    c3(ii)=g3(ii);
    
    
    %% second part
    iicx=[2:899];
    iicy=[2:1199];
    
    iioffset=logical(  (g1(iicx,iicy)==153 & g2(iicx,iicy)==204 & g3(iicx,iicy)==255 ) & ...
        ...
        ~(   (g1(iicx-1,iicy)==153 & g2(iicx-1,iicy)==204 & g3(iicx-1,iicy)==255 ) & ...
        (g1(iicx+1,iicy)==153 & g2(iicx+1,iicy)==204 & g3(iicx+1,iicy)==255 ) & ...
        (g1(iicx,iicy-1)==153 & g2(iicx,iicy-1)==204 & g3(iicx,iicy-1)==255 ) & ...
        (g1(iicx,iicy+1)==153 & g2(iicx,iicy+1)==204 & g3(iicx,iicy+1)==255 )));
    
    iitmp=logical(zeros(900,1200));
    iitmp(2:899,2:1199)=iioffset;
    
    c1(iitmp)=0;
    c2(iitmp)=0;
    c3(iitmp)=0;
    
    %% third part
    iioffset=logical(  (g1(iicx,iicy)==205 & g2(iicx,iicy)==254 & g3(iicx,iicy)==254 ) & ...
        ~((g1(iicx-1,iicy)==205 & g2(iicx-1,iicy)==254 & g3(iicx-1,iicy)==254 ) & ...
        (g1(iicx+1,iicy)==205 & g2(iicx+1,iicy)==254 & g3(iicx+1,iicy)==254 ) & ...
        (g1(iicx,iicy-1)==205 & g2(iicx,iicy-1)==254 & g3(iicx,iicy-1)==254 ) & ...
        (g1(iicx,iicy+1)==205 & g2(iicx,iicy+1)==254 & g3(iicx,iicy+1)==254 )));
    
    iitmp=logical(zeros(900,1200));
    iitmp(2:899,2:1199)=iioffset;
    
    c1(iitmp)=0;
    c2(iitmp)=0;
    c3(iitmp)=0;
    
    COLOR(:,:,1)=c1;
    COLOR(:,:,2)=c2;
    COLOR(:,:,3)=c3;
    
end

COLOR=imresize(imcrop(COLOR,[170,200,902,550]),[480,800]);
imwrite(COLOR,[FileName '.tif']);
%imwrite(COLOR,'tmp2.tif','Resolution',144);
%close all;




function h=AMTPlot(Data,Title,colorvals);

Data=Data(:,end:-1:1);

hfig=figure;
pos=get(hfig,'Position');
pos=pos.*[1 1 1.5 .9];
set(hfig,'Position',pos);

R=[12,90,-180];
axesm robinson;
h=meshm(Data.',R);
shading flat;
gridm('on');
box off;
cb=colorbar('location','south');
set(cb,'position',[.27,.217,.495,.027]);

set(gcf,'Renderer','zbuffer');
zoom on;
set(hfig,'Color',[.5,.5,.5]);

text(0,-1.85,0,Title,'HorizontalAlignment','center');
showaxes('hide')
caxis(colorvals);