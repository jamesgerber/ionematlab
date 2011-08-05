function appendfilesindirectory()
% Caution! Will render all but the top file useless.
global file;
N=dir;
for i=1:length(N)
    if (strcmp(N(i).name,'.')+strcmp(N(i).name,'..')+strcmp(N(i).name,'.DS_Store')+N(i).isdir==0)
        file=[file,fileread(N(i).name)];
    end
end
file
fprintf(fopen('output.csv','w'),'%c',file);