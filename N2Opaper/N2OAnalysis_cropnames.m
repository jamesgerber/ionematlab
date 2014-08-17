function [croplist,cropnumlist]=N2OAnalysis_cropnames
% standard list of cropnames for N2O analysis
%
%  SYNTAX:
%      [croplist,cropnumlist]=N2OAnalysis_cropnames
croplist=cropnames;

croplist=croplist([1:132 134:end]);
croplist{end+1}='rice_inundated';
croplist{end+1}='rice_noninundated';

cropnumlist=1:length(croplist);
