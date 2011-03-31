function OS=NSGfast(varargin);
% NICESURFGENERALfast / NSGfast
%
%  calls NiceSurfGeneral after reducing data
%
%  See also NiceSurfGeneral

if nargin==0
    help('NiceSurfGeneral')
    return
end
Data=varargin{1};

RedData=Data(1:6:end,1:6:end);

if length(varargin)==1;
    OS=NiceSurfGeneral(RedData,'caxis',[.99]);

else
    OS=NiceSurfGeneral(RedData,varargin{2:end});

end

