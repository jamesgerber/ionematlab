function S=CombineStructure(S1,S2,AFieldName)
% CombineStructure - create a structure with combined vector fields
%
% Syntax:
%  S=CombineStructure(S1,S2,AFieldName);
%
% EXAMPLE
%  S1=testdata(4320,2160,1);
%  S2=testdata(4320,2160,1);
%  S=CombineStructure(S1,S2,'RandomVector')
%

a1=fieldnames(S1);
a2=fieldnames(S2);

if ~isequal(a1,a2)
   error([' fieldnames not equal'])
   
end

temp=getfield(S2,AFieldName);

N=length(temp);


for j=1:length(a1)

   
   t1=getfield(S1,a1{j});
   t2=getfield(S2,a1{j});   
   if length(t2)==N
      t1=t1(:);
      t2=t2(:);
      t=[t1 ; t2];
      S1=setfield(S1,a1{j},t);
   end
end

S=S1;
