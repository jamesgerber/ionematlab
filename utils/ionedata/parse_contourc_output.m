function CS=parse_contourc_output(C)
% turn a contourc output vector into a structure of vector pairs
done=0;
c=1;

while ~done
    Npairs=C(2,1);
    S.X=C(1,2:Npairs);
    S.Y=C(2,2:Npairs);
    S.Level=C(1,1);
    CS(c)=S;
    
    if c>1000
        done=1;
    end
    C=C(1:2,Npairs+2 :end);
    c=c+1;
    if length(C)==0
        done=1;
    end
end
   