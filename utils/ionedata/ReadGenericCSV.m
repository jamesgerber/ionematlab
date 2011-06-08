function DS=ReadGenericCSV(FileName,HeaderLines,Delimiter);
% ReadGenericCSV - Read in a CSV file - whatever is in the columns
%
%  Syntax
%
%     DS=ReadGenericCSV(FileName);   this will assume a single
%     header line
%
%     DS=ReadGenericCSV(FileName,HeaderLines);
%
%   ReadGenericCSV will read in a CSV file, and make a structure,
%   where each field of the structure corresponds to one of the columns.
%
%   The number of columns will be determined by the number of
%   commas after the header (as determined by HeaderLines)   This
%   way, if there are extra commas in the header, the data field
%   names may be messed up, but the data will be extracted.
%

% first get headers, then figure out what the individual columns look like

if nargin==0
    help(mfilename)
    return
end

if nargin==1
    HeaderLines=1;
end
if nargin<3
    Delimiter=',';
end

fid=fopen(FileName);

for m=1:(HeaderLines-1)
    fgetl(fid);
end

headerline=fgetl(fid);

headerline=FixUpHeaderline(headerline);

VC=GetStrings(headerline,Delimiter);  %function below.
FieldNameStructure.Vector=VC;

% Now go through the structures and concatenate everything to get
% field names

if length(FieldNameStructure)>1
    warning(['do not have ability to turn multiple headerlines into' ...
        ' unique field names']);
    FieldNameStructure=FieldNameStructure(1);
end


% Now consider first line
xline=fgetl(fid);

VC=GetStrings(xline,Delimiter);

dvals=str2double(VC);

formatstring='';
for j=1:length(dvals);
    %this if/else below is due to the fact that I originally wrote out a
    %format string based on the first line of data.  However, I came across
    %some files that mixed numbers and strings within a column.
    %Consequently, I read in everything as a string and handle for
    %string/number further below.
    %I'm leaving this syntax here in case I want to try to go back (of
    %course, would need conditional statements ... lots of code, but might
    %run faster.)
    
    if isnan(dvals(j))
        %it's a string
        formatstring=[formatstring '%s'];
    else
        %it's a number
        formatstring=[formatstring '%s'];
    end
    
end
%now can read the whole thing using textscan

fclose(fid);
fid=fopen(FileName);
C=textscan(fid,formatstring,'Delimiter',Delimiter,'HeaderLines',HeaderLines);
fclose(fid);


%% OK.  Now have everything.  Assemble into DS (Output Structure).
DS=[];
for j=1:length(C)
    
    ThisName=MakeSafeString(FieldNameStructure.Vector{j});
    Contents=C{j};
    
    %let's see if we can turn these values into doubles
    NumValue=str2double(Contents{1});
    if ~isnan(NumValue)
        % first element is a number.  Now try to get all of them:
        NumVector=str2double(Contents);
        if any(isnan(NumVector))
            NumericFlag=0;
        else
            NumericFlag=1;
        end
    else
        NumericFlag=0;
    end
    
    if NumericFlag==1
        DS=setfield(DS,ThisName,NumVector);
    else
        DS=setfield(DS,ThisName,Contents);
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        FixUpHeaderline     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function headerline=FixUpHeaderline(headerline);
headerline=strrep(headerline,'(','');

headerline=strrep(headerline,')','');

if isequal(headerline(1),'_')
    headerline=FixUpHeaderline(headerline(2:end));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        GetStrings          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function VC=GetStrings(xline,Delimiter)

ii=find(xline==Delimiter);

%stick a one on the beginning, and an N on the end.
% cumbersome, but then we can loop into the part where we make a structure
ii(2:length(ii)+1)=ii;
ii(1)=0;
ii(end+1)=length(xline)+1;

for j=1:length(ii)-1;
    VC{j}=xline(ii(j)+1 : ii(j+1)-1);
end
