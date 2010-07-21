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
        caxis(UDS.DataAxisHandle,'auto');
        set(gcbf,'WindowButtonDownFcn',@SelectClickCallback);
    case 'clear'
        zoom(gcbf,'off');
        UDS=get(gcbf,'UserData');
        R=[12,90,-180];
        h1=meshm(double(UDS.Data.'),R);
        shading flat;
        colormap(UDS.CMap);
        caxis(UDS.DataAxisHandle,[0 100]);
end
end

function SelectClickCallback(src,event) 
UDS=get(gcbf,'UserData');
    cp=gcpmap(UDS.DataAxisHandle)
    [a b]=getRowCol(UDS.Lat,UDS.Long,cp(1,1),cp(1,2));
    z=UDS.Data(b,a);
    R=[12,90,-180];
    h1=meshm(double(UDS.Data.'),R);
    shading flat;
    colormap(UDS.CMap);
    caxis(UDS.DataAxisHandle,[z-(z/1000),z+((100-z)/1000)]);
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