function [NeighborCodesSage,NeighborNamesSage,DistanceProxy] = NearestNeighbor(SageCountryCode);
% NearestNeighbor - find nearest neighboring countries
%
%
%  Example
%
%    [NeighborCodesSage,NeighborNamesSage,AvgDistance] ...
%    =NearestNeighbor('ARG')
%
%    [NeighborCodesSage,NeighborNamesSage,AvgDistance] ...
%    =NearestNeighbor('AFG')
%
%    [NeighborCodesSage,NeighborNamesSage,AvgDistance] ...
%    =NearestNeighbor('URY')
%
%  See Also StandardCountryNames

%% prepwork

persistent  SAGE2 S3

if isempty(SAGE2)
    
    SystemGlobals;
    load([IoneDataDir 'AdminBoundary2005/Vector_ArcGISShapefile/gladmin_agg.mat'])
    SAGE2=S;
    for j=1:length(SAGE2);
        S3{j}=SAGE2(j).S3;
    end
    
end

ListOfNeighbors=[];
S3Neighbors=[];
AvgDistance=[];

j=strmatch(SageCountryCode,S3);

if isempty(j)
    error(['Didn''t find a match for' SageCountryCode]);
end


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
                    
                    ListOfNeighbors{end+1}=C.CNTRY_NAME;
                    S3Neighbors{end+1}=C.S3;
                    AvgDistance(end+1)= ( (a+b - A-B)^2 + (p+q -P-Q)^2)
                    
                    
                end
            end
            
            
        end
    end
end
NeighborCodesSage=S3Neighbors;
NeighborNamesSage=ListOfNeighbors;
DistanceProxy=AvgDistance;
%end

