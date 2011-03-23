function MultiBoxPlotInClimateSpaceSmoothContours...
    (ContourMask,CDS,CultivatedArea,Heat,Prec,cropname,Rev,WetFlag,IsValidData)
% MultiBoxPlotInClimateSpace - generate a scatter plot, put boxes over it.
%
%   Syntax
%     PatchPlotOfAreaInClimateSpace...
%    (CDS,CultivatedArea,Heat,Prec,cropname,Rev,WetFlag,IsValidData)
%
Nsurface=300;

if nargin<8
    WetFlag='Moisture Index';
end


if nargin<9
    IsValidData=(CropMaskLogical & Heat < 1e15 & isfinite(Heat) & CultivatedArea>eps & isfinite(CultivatedArea));
end



% check to make sure that heat/prec are positvite
 IsValidData=IsValidData & (Heat > -8e8 & Prec > -8e8); 
 

W=CultivatedArea(IsValidData); %Weight is the area, but only for these points.
[jp,xbins,ybins,XBinEdges,YBinEdges]=GenerateJointDist(Heat(IsValidData),Prec(IsValidData),Nsurface,Nsurface+10,W);


 
C=contourc(double(ContourMask),[.5 .5]);
CS=parse_contourc_output(C);


CS


%% now need to find indices of points which live inside the selected area.

TotalArea=sum(sum(jp));

jp=jp/max(max(jp));

figure
surface(double(xbins),double(ybins),double(jp).');
shading flat
xlabel('GDD');
ylabel(WetFlag);
%zeroylim(0,6);
grid on
ylims=get(gca,'YLim');
title([' All cultivated areas. ' cropname ' ' WetFlag ' Rev' Rev]);
% fattenplot
finemap('autumn','','')

hold on











%
%[BinMatrix]=...
%    ClimateDataStructureToClimateBins(CDS,Heat,Prec,CultivatedArea,'heat','prec');

% create xcont and ycont, two vectors representing the x and y dimensions
% of the contour. Use xbins and ybins to scale them to the size of the
% data (CS.X and CS.Y hold fairly arbitrary values that correspond to
% indices of xbins and ybins).
    xcont=zeros(length(CS.X),1);
    ycont=zeros(length(CS.Y),1);
    for (i=1:length(CS.X))
        xcont(i)=xbins(round(CS.X(i)));
        ycont(i)=ybins(round(CS.Y(i)));
    end
    
%     xcont=CS.X;
%     ycont=CS.Y;
    
    line(xcont,ycont,'color','black');
    
save('saved','CS','xbins','ybins','jp','CDS');

for ibin=1:length(CDS)
    
    S=CDS(ibin);
    
% We're creating 4 sets of 2 2-element vectors, each set representing a
% single side of a box.
    

% Start by setting the side to the dimensions of one side of the box, ignoring contour.
    x1(1)=S.GDDmin;
    y1(1)=S.Precmin;
    x1(2)=S.GDDmin;
    y1(2)=S.Precmax;
    
% Find all intersections between the side and the contour.
    [xc,yc]=polyxpoly(x1,y1,xcont,ycont);
    if (length(xc)==1) % if there's one intersection:
        % check both vertices. Set the one that isn't within the contour to
        % the position of the intersection.
        if (inpolygon((x1(1)),(y1(1)),xcont,ycont)==(0))
            x1(1)=xc(1);
            y1(1)=yc(1);
        end
        if (inpolygon((x1(2)),(y1(2)),xcont,ycont)==(0))
            x1(2)=xc(1);
            y1(2)=yc(1);
        end
    else % there's not one intersection:
        % if both vertices of the side are outside of the contour, we don't
        % want to draw this side. Make it void.
        if (inpolygon(x1,y1,xcont,ycont)==[0 0])
            x1=[];
            y1=[];
        end
    end
    
    % Repeat for the other 3 sides.
    x2(1)=S.GDDmin;
    y2(1)=S.Precmax;
    x2(2)=S.GDDmax;
    y2(2)=S.Precmax;
    
    [xc,yc]=polyxpoly(x2,y2,xcont,ycont);
    if (length(xc)==1)
        if (inpolygon((x2(1)),(y2(1)),xcont,ycont)==(0))
            x2(1)=xc(1);
            y2(1)=yc(1);
        end
        if (inpolygon((x2(2)),(y2(2)),xcont,ycont)==(0))
            x2(2)=xc(1);
            y2(2)=yc(1);
        end
    else
        if (inpolygon(x2,y2,xcont,ycont)==[0 0])
            x2=[];
            y2=[];
        end
    end
    
    
    x3(1)=S.GDDmax;
    y3(1)=S.Precmax;
    x3(2)=S.GDDmax;
    y3(2)=S.Precmin; 
    
    [xc,yc]=polyxpoly(x3,y3,xcont,ycont);
    if (length(xc)==1)
        if (inpolygon((x3(1)),(y3(1)),xcont,ycont)==(0))
            x3(1)=xc(1);
            y3(1)=yc(1);
        end
        if (inpolygon((x3(2)),(y3(2)),xcont,ycont)==(0))
            x3(2)=xc(1);
            y3(2)=yc(1);
        end
    else
        if (inpolygon(x3,y3,xcont,ycont)==[0 0])
            x3=[];
            y3=[];
        end
    end
    
    
    x4(1)=S.GDDmax;
    y4(1)=S.Precmin;
    x4(2)=S.GDDmin;
    y4(2)=S.Precmin;
   
    [xc,yc]=polyxpoly(x4,y4,xcont,ycont);
    if (length(xc)==1)
        if (inpolygon((x4(1)),(y4(1)),xcont,ycont)==(0))
            x4(1)=xc(1);
            y4(1)=yc(1);
        end
        if (inpolygon((x4(2)),(y4(2)),xcont,ycont)==(0))
            x4(2)=xc(1);
            y4(2)=yc(1);
        end
    else
        if (inpolygon(x4,y4,xcont,ycont)==[0 0])
            x4=[];
            y4=[];
        end
    end
    
% draw the lines
    line(double(x1),double(y1),0*x1+1,'color','black');
    line(double(x2),double(y2),0*x2+1,'color','black');
    line(double(x3),double(y3),0*x3+1,'color','black');
    line(double(x4),double(y4),0*x4+1,'color','black');
    % TotalAreaVect(ibin)=TotalArea;
end

ylabel(WetFlag)
xlabel('GDD')
title(['distribution of ' cropname  ' area in climate space']);
h=colorbar

hy=get(h,'YLabel')
set(hy,'String',['normalized area per pixel (total=' num2str(TotalArea/1e6,4) 'Mha)'])
set(hy,'String',['cultivated area (normalized)'])
set(hy,'FontWeight','Bold')

grid off

N=sqrt(length(CDS));
nbyn=[num2str(N) 'x' num2str(N)]
OutputFig('Force')
%OutputFig('Force')