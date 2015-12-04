function cl=makeitfit17crops
% makeitfit10crops - get the names of the 10 crops of interest to MakeItFit
%
% SYNTAX
% c=makeitfit10crops - set c to a cell array of the makeitfit10crops crops

cl=sixteencrops;
cl(end+1)={'cotton'};
cl=unique(cl);