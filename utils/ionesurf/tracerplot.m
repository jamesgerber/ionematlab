function tracerplot(data,bg,cmap,ctrace,squeeze,breadth,depth)
if nargin<2
    bg=data(:,:,1);
end
if nargin<3
    cmap=jet;
end
bg=easyinterp2(flipud(bg'),540,1080,'linear');
for i=1:size(data,3)
    bdata(:,:,i)=easyinterp2(flipud(data(:,:,i)'),540,1080,'linear');
end
colormap(cmap);
h=axes; contourf(h,bg,length(cmap)); shading flat; %set(h,'Visible','off');
%SystemGlobals;
%load(ADMINBOUNDARY_VECTORMAP)
%plot(h, long/4,lat/4,'k');
while ishandle(h)
        waitforbuttonpress;
        cp=get(h,'CurrentPoint');
        x=round(cp(1,2));
        y=round(cp(1,1));
        axes(h);
        if nargin<4
            tracer(h,x,y,bdata);
        end
        if nargin==4
            tracer(h,x,y,bdata,ctrace);
        end
        if nargin==5
            tracer(h,x,y,bdata,ctrace,squeeze);
        end
        if nargin==6
            tracer(h,x,y,bdata,ctrace,squeeze,breadth);
        end
        if nargin==7
            tracer(h,x,y,bdata,ctrace,squeeze,breadth,depth);
        end
end