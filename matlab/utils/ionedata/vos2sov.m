function SOV=vos2sov(S)
% VOS2SOV - Vector of Structures to Structure of Vectors
%
% SYNTAX
% vos2sov(S) - S is a vector of structures.  Returns a structure of vectors
% with the same length as the length of S, where each vector represents one
% of the common attributes of S's structures.


a=fieldnames(S)

for j=1:length(a);
    
    x=getfield(S(1),a{j});
    
    if numel(x) > 1
        TypeFlag(j)=0;
    else
        if ischar(x)==1
            TypeFlag(j)=1;
        else
            TypeFlag(j)=2;
        end
    end
end

% TypeFlag=0: ignore
% TypeFlag=1: character
% TypeFlag=2: number

 
SOV=[];
for m=1:length(a)

    ThisField=a{m};
    
    if TypeFlag(m)>0
        for j=1:length(S)
            if TypeFlag==1
                ThisVect{j}=getfield(S(j),ThisField);
            else
                ThisVect(j)=getfield(S(j),ThisField);
            end
        end
    SOV=setfield(SOV,ThisField,ThisVect);
    end
    end


    
    