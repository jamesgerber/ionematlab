function out=DataBlank(Val,Res)
% DATABLANK - initialize a matrix 
%
% Syntax
%
%    out=DataBlank(VAL,RES)    RES can be '30min' or '5min' (default)
%
%  EXAMPLE
%
%    HoldingMatrix=DataBlank(-9);  will create a 5min sized matrix
%    of -9
if nargin<1
    Val=0;
end
if nargin<2
    Res='5min';
end

switch Res
    case '30min'
        tmp=ones(720,360);
    case '10min'
        tmp=ones(2160,1080);
    case '5min'
        tmp=ones(4320,2160);
    case '1min'
        warning('warning:  this is going to be really huge');
        tmp=ones(21600,10800)
    otherwise
        error
end

out=tmp*Val;