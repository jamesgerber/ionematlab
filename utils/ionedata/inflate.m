function matrix=inflate(vector,background,mask);
%inflate - turn a vector into a matrix


if nargin==3
    if length(vector) ~= length(find(mask))
        error('mask, vector incompatible');
    end
end

if nargin<2
    background=0;
end

matrix=datablank(background);

switch length(vector);
    case 2069588
        matrix(agrimasklogical)=vector;
    otherwise
        error('don''t know how to inflate this vector')
end

        