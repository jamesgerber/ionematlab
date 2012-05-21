function Data=MaskIndicesTo5MinGrid(Data)
if min(size(Data))==1
    % This is a vector.  That's not good.  Either user messed up or
    % user is only sending us the values corresponding to the
    % DataMask
    DML=DataMaskLogical;
    switch(length(Data))
        case numel(DML)
            % user has passed in the entire globe as a vector.
            DML=DML*0;  %Use this matrix
            DML(DMI)=Data(DMI);
            Data=DML;
        case length(DataMaskIndices)
            %user has only sent in data corresponding to datamask
            DML=DML*0;  %now use DML to construct a matrix for DATA
            DML(DataMaskIndices)=Data; %Data still a vector, assign it into DML
            Data=DML;  %no Data is properly embedded in a matrix
        case length(LandMaskIndices)
            %user has only sent in data corresponding to landmask
            DML=DML*0;  %now use DML to construct a matrix for DATA
            DML(LandMaskIndices)=Data; %Data still a vector, assign it into DML
            Data=DML;  %no Data is properly embedded in a matrix
        case length(AgriMaskIndices)
            %user has only sent in data corresponding to agrimask
            DML=DML*0;  %now use DML to construct a matrix for DATA
            DML(AgriMaskIndices)=Data; %Data still a vector, assign it into DML
            Data=DML;  %no Data is properly embedded in a matrix
        case length(CropMaskIndices)
            %user has only sent in data corresponding to cropmask
            DML=DML*0;  %now use DML to construct a matrix for DATA
            DML(CropMaskIndices)=Data; %Data still a vector, assign it into DML
            Data=DML;  %no Data is properly embedded in a matrix
        otherwise
            
            error(['Don''t know what to do with a vector of this length'])
    end
end
