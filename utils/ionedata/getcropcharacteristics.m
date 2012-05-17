function [OS]=getcropcharacteristics(cropname);
% cropcharacteristics - get crop characteristics from cropinfo.csv file
%
%  CC=cropcharacteristics('wheat')
%
%  CC=cropcharacteristics;

if nargin==0 & nargout==0;help(mfilename);return;end

% get crop data
persistent C
if isempty(C)
    C=readgenericcsv([iddstring '/misc/cropdata.csv']);
end


if nargin==0
    OS=C;
    return
end

idx=strmatch(char(cropname),C.CROPNAME,'exact');

if numel(idx)~=1
    error([' don''t have a unique crop match'])
end


a=fieldnames(C);

OS=[];
for j=1:length(a);
    longfield=getfield(C,a{j});
    OS=setfield(OS,a{j}, longfield(idx));
end


% CROPNAME: {175x1 cell}
% GROUP: {175x1 cell}
% Legume: {175x1 cell}
% C3C4: {175x1 cell}
% Ann_Per: {175x1 cell}
% Form: {175x1 cell}
% Harvest_Index: [175x1 double]
% Dry_Fraction: [175x1 double]
% Aboveground_Fraction: [175x1 double]
% N_Perc_Dry_Harv: {175x1 cell}
% P_Perc_Dry_Harv: {175x1 cell}
% K_Perc_Dry_Harv: {175x1 cell}
% Nfix_low: {175x1 cell}
% Nfix_med: {175x1 cell}
% Nfix_high: {175x1 cell}
% GDDBase: {175x1 cell}
% FAOName: {175x1 cell}
% MonfredaName: {175x1 cell}
% DisplayName: {175x1 cell}
% FAOItemNumber: {175x1 cell}
% ConstructedCrop: [175x1 double]