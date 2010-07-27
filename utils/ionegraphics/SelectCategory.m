function selectCategory(InputFlag)

switch(InputFlag)
    case 'Initialize'
        uicontrol('String','Clear','Callback', ...
            'selectCategory(''clear'');','position',NextButtonCoords);  
        uicontrol('String','Select Climate','Callback', ...
            'selectCategory(''select'')','position',NextButtonCoords);     
    case 'select'
        zoom(gcbf,'off');
        UDS=get(gcbf,'UserData');
        R=[12,90,-180];
        h=meshm(double(UDS.Back.'),R);
        shading flat;
        colormap(UDS.BMap);
        mn=min2d(UDS.Back);
        mx=max2d(UDS.Back);
        caxis(UDS.DataAxisHandle,[mn*2-.5,mx*2-.5]);
        set(gcbf,'WindowButtonDownFcn',@SelectClickCallback);
    case 'clear'
        UDS=get(gcbf,'UserData');
        R=[12,90,-180];
        h=meshm(double(UDS.Data.'),R);
        shading flat;
        colormap(UDS.CMap);
        caxis([0 max2d(UDS.Data)*2+1]);
    return;
end
end

function SelectClickCallback(src,event)
UDS=get(gcbf,'UserData');
    cp=gcpmap(UDS.DataAxisHandle)
    [a b]=getRowCol(UDS.Lat,UDS.Long,cp(1,1),cp(1,2));
    z=UDS.Data(b,a);
    R=[12,90,-180];
    [q w e]=CMapAppend(UDS.BMap/2,UDS.CMap,min2d(UDS.Back)*2-.5,max2d(UDS.Back)*2-.5,0,max2d(UDS.Data)*2);
    h1=meshm(double(IonEOverlay(UDS.Data*w+e,UDS.Data==z,UDS.Back)).',R);
    shading flat;
    colormap(q);
    caxis(UDS.DataAxisHandle,[min2d(UDS.Back)*2-.5,max2d(UDS.Data)*2*w+e]);
end

function [a b]=getRowCol(LT,LN,lat,lon)
a=1;
while ((LT(a,1)<lat)&&(a<2160))
    a=a+1;
end
b=1;
while ((LN(b,1)<lon)&&(b<4320))
    b=b+1;
end
end