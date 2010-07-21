function ChangeProjection(varargin);
% ChangeProjection - Change projection of map.

if nargin==0
    help(mfilename);
    return
end

InputFlag=varargin{1};


key=maps('idlist');
descript=maps('namelist');
MapsToIncludeList=[1:72];
CallbackString=['projection|' descript(MapsToIncludeList(1),:)];
for j=2:length(MapsToIncludeList);
    CallbackString=[CallbackString '|' descript(MapsToIncludeList(j),:) ];
end

switch(InputFlag)
    case 'Initialize'
        uicontrol('style','popupmenu','String',CallbackString,'Callback', ...
            'ChangeProjection(''ChangeProjectionCallback'')','position',NextButtonCoords);
        
    case 'ChangeProjectionCallback'
        
        Val=get(gcbo,'Value');  %Val will be the number
        %corresponding to the string of the uicontrol.  REmember that we
        %need to subtract 1.
        if Val==1
            %            'user touched the control but didn''t specify a projection'
        else
            Val=Val-1;  %now Val indexes into key and descript
            
            
            setm(gca,'mapproj',key(Val,:))
        end
    otherwise
    error(['syntax error in ' mfilename])

end

