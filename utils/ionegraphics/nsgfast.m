function OS=nsgfast(varargin);
% NICESURFGENERALfast / nsgfast
%
%  calls nicesurfGeneral after reducing data
%
%  See also nicesurfGeneral

if nargin==0
    help('nicesurfGeneral')
    return
end
Data=varargin{1};

%RedData=Data(1:6:end,1:6:end);

if length(varargin)==1;
    OS=nicesurfGeneral(Data,'caxis',[.99],'fastplot','halfdegree');
else
    OS=nicesurfGeneral(Data,varargin{2:end},'fastplot','halfdegree');
end

