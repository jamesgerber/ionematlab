function varargout=sparsurf(Long,Lat,Data,Units,TitleStr);
% sparsurf - Make sparse plot.
%
% SYNTAX
%     sparsurf(Long,Lat,Data);
%   
%
%     sparsurf(Data);  will assume global coverage of data and construct
%     Long, Lat
if nargin==0
  help(mfilename);
  return
end
    

InputVariableName=inputname(nargin);  %Variable name from calling workspace.

if nargin==1
  % only one argument in.  Either user is simply passing in a big array and
  % expecting thinsurf to infer the Lat and Long, or that one argument is a
  % structure that has the data in it.

  %  note that whichever option is true, the variable is called Long.
  %  Rename to make the code more readable.
  Data=Long;
  clear Long
  if isstruct(Data)
      % it's a structure.  Call a utility to unpack ...
      [Long,Lat,Data,Units,DefaultTitleStr,NoDataStructure]=extractdatafromstructure(Data);
      % now check to make sure that we got a title.  If we didn't use the
      % input variable name.
      if nargin < 5
          % User did not supply a title.  We need to find in.  Best is
          % whatever came from extractdatafromstructure, but make sure it
          % isn't empty first
          if ~isempty(DefaultTitleStr) 
              TitleStr=DefaultTitleStr;
          else
              TitleStr=InputVariableName
          end
      else
          % Comment to make code readable:
          % We are here bec user did supply TitleStr.  Nothing to do.
      end
      
  else
      % it's a matrix.  Call a utility to figure out Long, Lat
      
      [Long,Lat]=inferlonglat(Data);
      TitleStr=InputVariableName;
      Units='';
  end
end



% now if there is any ocean, set it to zero.

Mask=OceanMask(Long,Lat,Data);
ii=find(Mask==0);
Data(ii)=0;


hfig=figure;
set(gcf,'renderer','zbuffer')
hsurf=surface(Long,Lat, sparse(double(Data.')));
shading flat
ht=title(TitleStr);
set(ht,'Interpreter','none');
hcb=colorbar;
hy=get(hcb,'YLabel');
set(hy,'String',Units);
worldsummary('Initialize');
zoomtomax('Initialize');
makereduceddatasets('Initialize');

if exist('NoDataStructure');
    set(hfig,'UserData',NoDataStructure);
end


set(gcf,'Renderer','zbuffer')
zoom on
if nargout==1
    varargout{1}=h;
end