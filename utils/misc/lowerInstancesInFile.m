function used=lowerInstancesInFile(filename,strings,used)
ourfile = fileread(filename);
for i=1:length(strings)
    ourfile=strrep(ourfile,strings{i},lower(strings{i}));
    if ~isempty(strfind(ourfile,strings{i}))
        used{i}='';
end
disp(filename)
fprintf(fopen(filename,'w'),'%s',ourfile)