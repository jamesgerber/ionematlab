function mo=monthString(Mo)
% MONTHSTRING - return 3-character month abbreviation of month number
%
% SYNTAX
% mo=monthString(num) - num is a number between 1 and 12; month is set to
% the associated 3-letter month name abbreviation
mo=datestr(datenum(1,Mo,1,1,1,1),'mmm');
