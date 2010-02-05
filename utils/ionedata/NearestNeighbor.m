function [NeighborCodesSage,NeighborNamesSage] = NearestNeighbor(SageCountryCode);
% NearestNeighbor - find nearest neighboring countries
%
%


SAGE2=shaperead('./SageAdmin/disscntry');


for j=1:235
    
    S=SAGE2(j);
    
    x=S.X;
    y=S.Y;
    bb=S.BoundingBox;
    
    for k=1:235
        if k~=j
            C=SAGE2(k);   %Candidate
            
            bbc=C.BoundingBox;
            
            
            %      is there some overlap between bounding boxes ?
            
            a=bb(1,1);
            b=bb(2,1);
            A=bbc(1,1);
            B=bbc(2,1);
            
            p=bb(1,2);
            q=bb(2,2);
            P=bbc(1,2);
            Q=bbc(2,2);
            
            if  (  ((a >= A & a <=B) |  (b >= A & b <=B)) | (a>A & b<B) | (a<A & b>B) ) & ...
                    ((p >= P& p <=Q) |  (q >= P & q <=Q)   | (p>P & q<Q) | (p<P ...
                    & q>Q)   )
                %  Overlap is possible.  Now look at the actual boundaries
                %  disp(['checking for overlap between ' S.CNTRY_NAME ' and ' C.CNTRY_NAME]);
                
                X=C.X;
                Y=C.Y;
                
                [xx,iax,ibx]=intersect(x,X);
                [yy,iay,iby]=intersect(y,Y);
                
                jj=intersect(iax,iay);
                kk=intersect(ibx,iby);
                

                
                if length(jj) > 1 & length(kk) > 1
                    % now see if first value of kk
                    OverlapVals=zeros(size(x));
                   for m=1:length(kk)
                       OverlapVals=OverlapVals |( X(kk(m))==x & Y(kk(m))==y);
                   end
                   N=length(find(OverlapVals));
                   if any(OverlapVals)
                    disp(['overlap between ' S.CNTRY_NAME ' and ' C.CNTRY_NAME ...
                        ' of ' int2str(N) ' points']);
                   end
                end
                
                
            end
        end
    end
    
end

