function excel(filename)
% excel - open filename in excel
%
% allows me to open a .txt file that way
% (if csv, then !open filename.csv better)


unix(['open -a /Applications/''Microsoft Excel.app''/ ' filename]);