function VOS=sov2vos(DS)
% SOV2VOS -  Structure of Vectors to Vector of Structures
%
% SYNTAX
% SOV2VOS(DS) - DS is a single structure made up of several vectors.  This
% function returns a vector of structures S, where the length of S equals
% the length of the fields of DS.
%
% See also vos2sov

a=fieldnames(DS)

for j=1:length(a);
    
    x=getfield(DS,a{j});
    
    switch(class(x))
        case 'double'
            TypeFlag(j)=1;
        case 'char'
            TypeFlag(j)=2;
        case 'cell'
            TypeFlag(j)=3;
    end
end

for m=1:length(x);
    S=[];
    for j=1:length(a);
        
        switch TypeFlag(j)
            case 1
                y=getfield(DS,a{j});
                S=setfield(S,a{j},y(m));
            case {2,3}
                y=getfield(DS,a{j});
                S=setfield(S,a{j},y{m});
        end
    end
    
    Svect(m)=S;
end
    
VOS=Svect;
        
% 
%  
% SOV=[];
% for m=1:length(a)
% 
%     ThisField=a{m};
%     
%     if TypeFlag(m)>0
%         for j=1:length(S)
%             if TypeFlag==1
%                 ThisVect{j}=getfield(S(j),ThisField);
%             else
%                 ThisVect(j)=getfield(S(j),ThisField);
%             end
%         end
%     SOV=setfield(SOV,ThisField,ThisVect);
%     end
%     end


    
    