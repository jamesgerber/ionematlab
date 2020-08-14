function struct2csv(filename,a,dlm);
%struct2csv - make a .csv from a structure of vectors
% 
%   struct2csv(filename,a,dlm);
%
%   dlm optional ',' default
%
%   all fields of a must be numeric.

if nargin==2
    dlm=',';
end



fn=fieldnames(a)




% first write headerline

fid=fopen(filename,'w');

fprintf(fid,fn{1})
for j=2:numel(fn)
    fprintf(fid,'%s%s',dlm,fn{j});
end
fprintf(fid,'\n');
fclose(fid)



% now create matrix

M=getfield(a,fn{1});

for j=2:numel(fn)
    X=getfield(a,fn{j});
    M(:,j)=X;
end

%
dlmwrite(filename,M,'-append','delimiter',dlm)


