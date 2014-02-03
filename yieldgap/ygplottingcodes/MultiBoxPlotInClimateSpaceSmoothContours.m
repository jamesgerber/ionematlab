function MultiBoxPlotInClimateSpaceSmoothContours...
    (ContourMask,CDS,CultivatedArea,Heat,Prec,cropname,Rev,WetFlag,xlimits,ylimits,xdatalim,ydatalim,IsValidData)
% MultiBoxPlotInClimateSpace - generate a scatter plot, put boxes over it.
%
%   Syntax
%     PatchPlotOfAreaInClimateSpace...
%    (CDS,CultivatedArea,Heat,Prec,cropname,Rev,WetFlag,IsValidData)
%


Nsurface=300;
xbins = Nsurface; ybins = Nsurface +10;
% xbins = xdatalim./10;
% ybins = ydatalim./10;

if nargin<8
    WetFlag='Moisture Index';
end


 minval1=min(min(Heat))
 minval2=min(min(Prec))
% check to make sure that heat/prec are positvite


if nargin>11
    if xdatalim > 1
        minval1 = xdatalim;
    else
        percentile(Heat,xdatalim)
        Heat(Heat>percentile(Heat,xdatalim))=minval1;
    end
    if ydatalim > 1
        minval2 = ydatalim;
    else
        percentile(Prec,ydatalim)
        Prec(Prec>percentile(Prec,ydatalim))=minval2;
    end
end


if nargin<13
    IsValidData=(CropMaskLogical & Heat < 1e15 & isfinite(Heat) & CultivatedArea>eps & isfinite(CultivatedArea));
end

 IsValidData=IsValidData & (Heat > -8e8 & Prec > -8e8); 


 
 

W=CultivatedArea(IsValidData); %Weight is the area, but only for these points.
[jp,xbins,ybins,XBinEdges,YBinEdges]=GenerateJointDist(Heat(IsValidData),Prec(IsValidData),xbins,ybins,W);

% need to create ContourMask


%ContourMask=jp>0;

 
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

if nargin>8
    xlim(xlimits);
end

if nargin>9
    ylim(ylimits);
end


%zeroylim(0,6);
grid on
title([' All cultivated areas. ' cropname ' ' WetFlag ' Rev' Rev]);
% fattenplot
%finemap('nmwhiteorangered_umn_leftskew2','','')
finemap('area2','','')
shading interp

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
    
    if (nargin>9)
        xcont=interp1(1:length(xcont),xcont,1:(length(xcont)-1)/100:length(xcont),'cubic');
        ycont=interp1(1:length(ycont),ycont,1:(length(ycont)-1)/100:length(ycont),'cubic');
    end
    line(xcont,ycont,zeros(length(ycont))+100,'color','black','linewidth',1);
    
save('saved','CS','xbins','ybins','jp','CDS');

for ibin=1:length(CDS)
    
    S=CDS(ibin);
    
% We're creating 4 sets of 2 2-element vectors, each set representing a
% single side of a box.
    
x1=[];
x2=[];
x3=[];
x4=[];
y1=[];
y2=[];
y3=[];
y4=[];


% Start by setting the side to the dimensions of one side of the box,
% ignoring contour.
    x1(1)=S.GDDmin;
    y1(1)=S.Precmin;
    x1(2)=S.GDDmin;
    y1(2)=S.Precmax;
    
% Find all intersections between the side and the contour.
    [xc,yc]=polyxpoly(x1,y1,xcont,ycont);
    if (inpolygon((x1(1)),(y1(1)),xcont,ycont)==(0))
        x1=(x1(2));
        y1=(y1(2));
        if (inpolygon((x1(1)),(y1(1)),xcont,ycont)==(0))
            x1=[];
            y1=[];
        end
    end
    x1=sort([x1 rot90(xc)]);
    y1=sort([y1 rot90(yc)]);
    xtest=interp1(1:length(x1),x1,1.5:1:(length(x1)-.5));
    ytest=interp1(1:length(y1),y1,1.5:1:(length(y1)-.5));
    test=inpolygon(xtest,ytest,xcont,ycont);
    for i=1:length(test)
        if test(i)==0
            x1((i+2):(length(x1)+1))=x1((i+1):length(x1));
            x1(i+1)=NaN;
            y1((i+2):(length(y1)+1))=y1((i+1):length(y1));
            y1(i+1)=NaN;
        end
    end
    
    % Repeat for the other 3 sides.
    x2(1)=S.GDDmin;
    y2(1)=S.Precmax;
    x2(2)=S.GDDmax;
    y2(2)=S.Precmax;
    
    [xc,yc]=polyxpoly(x2,y2,xcont,ycont);
    if (inpolygon((x2(1)),(y2(1)),xcont,ycont)==(0))
        x2=(x2(2));
        y2=(y2(2));
        if (inpolygon((x2(1)),(y2(1)),xcont,ycont)==(0))
            x2=[];
            y2=[];
        end
    end
    try
    x2=sort([x2 rot90(xc)]);
    y2=sort([y2 rot90(yc)]);
    catch
        x2
        y2
        xc
        yc
    end
    xtest=interp1(1:length(x2),x2,1.5:1:(length(x2)-.5));
    ytest=interp1(1:length(y2),y2,1.5:1:(length(y2)-.5));
    test=inpolygon(xtest,ytest,xcont,ycont);
    for i=1:length(test)
        if test(i)==0
            x2((i+2):(length(x2)+1))=x2((i+1):length(x2));
            x2(i+1)=NaN;
            y2((i+2):(length(y2)+1))=y2((i+1):length(y2));
            y2(i+1)=NaN;
        end
    end
    
    
    x3(1)=S.GDDmax;
    y3(1)=S.Precmax;
    x3(2)=S.GDDmax;
    y3(2)=S.Precmin; 
    
    [xc,yc]=polyxpoly(x3,y3,xcont,ycont);
    if (inpolygon((x3(1)),(y3(1)),xcont,ycont)==(0))
        x3=(x3(2));
        y3=(y3(2));
        if (inpolygon((x3(1)),(y3(1)),xcont,ycont)==(0))
            x3=[];
            y3=[];
        end
    end
    x3=sort([x3 rot90(xc)]);
    y3=sort([y3 rot90(yc)]);
    xtest=interp1(1:length(x3),x3,1.5:1:(length(x3)-.5));
    ytest=interp1(1:length(y3),y3,1.5:1:(length(y3)-.5));
    test=inpolygon(xtest,ytest,xcont,ycont);
    for i=1:length(test)
        if test(i)==0
            x3((i+2):(length(x3)+1))=x3((i+1):length(x3));
            x3(i+1)=NaN;
            y3((i+2):(length(y3)+1))=y3((i+1):length(y3));
            y3(i+1)=NaN;
        end
    end
    
    
    x4(1)=S.GDDmax;
    y4(1)=S.Precmin;
    x4(2)=S.GDDmin;
    y4(2)=S.Precmin;
   
    [xc,yc]=polyxpoly(x4,y4,xcont,ycont);
    if (inpolygon((x4(1)),(y4(1)),xcont,ycont)==(0))
        x4=(x4(2));
        y4=(y4(2));
        if (inpolygon((x4(1)),(y4(1)),xcont,ycont)==(0))
            x4=[];
            y4=[];
        end
    end
    try
    x4=sort([x4 rot90(xc)]);
    y4=sort([y4 rot90(yc)]);
    catch
        x4
        y4
        xc
        yc
    end
    xtest=interp1(1:length(x4),x4,1.5:1:(length(x4)-.5));
    ytest=interp1(1:length(y4),y4,1.5:1:(length(y4)-.5));
    test=inpolygon(xtest,ytest,xcont,ycont);
    for i=1:length(test)
        if test(i)==0
            x4((i+2):(length(x4)+1))=x4((i+1):length(x4));
            x4(i+1)=NaN;
            y4((i+2):(length(y4)+1))=y4((i+1):length(y4));
            y4(i+1)=NaN;
        end
    end
    
% draw the lines
    line(double(x1),double(y1),0*x1+1,'color','black');
    line(double(x2),double(y2),0*x2+1,'color','black');
    line(double(x3),double(y3),0*x3+1,'color','black');
    line(double(x4),double(y4),0*x4+1,'color','black');
    % TotalAreaVect(ibin)=TotalArea;
end

ylabel('annual mean precipitation (mm/yr)')
xlabel('GDD')
title(['distribution of ' cropname  ' area in climate space']);
h=colorbar

hy=get(h,'YLabel')
set(hy,'String',['normalized area per pixel (total=' num2str(TotalArea/1e6,4) 'Mha)'])
set(hy,'String',['cultivated area (normalized)'])
% set(hy,'FontWeight','Bold')

grid off

N=sqrt(length(CDS));
nbyn=[num2str(N) 'x' num2str(N)]
%OutputFig('Force')