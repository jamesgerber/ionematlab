function Data=maskindicesto5mingrid(Data)
if min(size(Data))==1
    % This is a vector.  That's not good.  Either user messed up or
    % user is only sending us the values corresponding to the
    % DataMask
    DML=datamasklogical;
    switch(length(Data))
        case numel(DML)
            % user has passed in the entire globe as a vector.
            DML=DML*0;  %Use this matrix
            DML(DMI)=Data(DMI);
            Data=DML;
        case length(datamaskindices)
            %user has only sent in data corresponding to datamask
            DML=DML*0;  %now use DML to construct a matrix for DATA
            DML(datamaskindices)=Data; %Data still a vector, assign it into DML
            Data=DML;  %no Data is properly embedded in a matrix
        case length(landmaskindices)
            %user has only sent in data corresponding to landmask
            DML=DML*0;  %now use DML to construct a matrix for DATA
            DML(landmaskindices)=Data; %Data still a vector, assign it into DML
            Data=DML;  %no Data is properly embedded in a matrix
        case length(agrimaskindices)
            %user has only sent in data corresponding to agrimask
            DML=DML*0;  %now use DML to construct a matrix for DATA
            DML(agrimaskindices)=Data; %Data still a vector, assign it into DML
            Data=DML;  %no Data is properly embedded in a matrix
        case length(cropmaskindices)
            %user has only sent in data corresponding to cropmask
            DML=DML*0;  %now use DML to construct a matrix for DATA
            DML(cropmaskindices)=Data; %Data still a vector, assign it into DML
            Data=DML;  %no Data is properly embedded in a matrix
        otherwise
            
            error(['Don''t know what to do with a vector of this length'])
    end
end
