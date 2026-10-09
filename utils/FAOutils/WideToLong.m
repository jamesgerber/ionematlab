function S_long = WideToLong(S)

% this was written with Claude, prompt below:

% WIDE_TO_LONG  Reshape FAO-style wide structure to long format.
%
%   S_long = WIDE_TO_LONG(S) converts a structure S containing year columns
%   named Y1961, Y1962, ..., Y2023 into a long-format structure with fields
%   'Year' and 'Value', replicating all non-year fields for each year.
%
%   INPUT:
%     S      - Scalar structure in wide format with fields Area_Code,
%              Area_Code_M49, Area, Item_Code, Item, Element_Code, Element,
%              Source_Code, Source, Unit (each N x 1), plus year fields
%              Y1961 ... Y2023 (each N x 1 double).
%
%   OUTPUT:
%     S_long - Scalar structure in long format with the same non-year fields
%              plus:
%                S_long.Year  : [N*nYears x 1 double] - year as integer
%                S_long.Value : [N*nYears x 1 double] - data value

% I have a Matlab structure with these fields.  I want to add a field
% called 'Year' and a field called 'Value' and have the values that are in
% all of the files 'Y_xxxx' where x is a date go to the 'Value' field with
% xxxx going to the  'Year' field.  Can you write code to do this?   

% --- Identify year fields ---
all_fields = fieldnames(S);
%is_year = cellfun(@(f) ~isempty(regexp(f, '^Y\d{4}$', 'once')), all_fields);
is_year = cellfun(@(f) ~isempty(regexp(f, '^Y_?\d{4}$', 'once')), all_fields);
year_fields = all_fields(is_year);
meta_fields = all_fields(~is_year);

nRows = length(S.(meta_fields{1}));
nYears = length(year_fields);
N = nRows * nYears;

% --- Extract years as integers --- 
%jg modified the below to have two syntaxes. 
years1 = cellfun(@(f) str2double(f(2:end)), year_fields);  % strip 'Y'
years2 = cellfun(@(f) str2double(f(3:end)), year_fields);  % strip 'Y'


if isnan(years1)
    years=years2;
else
    years=years1;
end

% --- Pre-allocate Year and Value ---
S_long.Year  = repelem(years(:), nRows);   % nYears blocks of nRows
S_long.Value = zeros(N, 1);

% Fill Value column-by-column
for i = 1:nYears
    idx = (i-1)*nRows + (1:nRows);
    S_long.Value(idx) = S.(year_fields{i});
end

% --- Replicate metadata fields ---
for i = 1:length(meta_fields)
    f = meta_fields{i};
    val = S.(f);
    if isnumeric(val)
        S_long.(f) = repmat(val, nYears, 1);
    else
        S_long.(f) = repmat(val, nYears, 1);
    end
end

% --- Reorder fields: metadata first, then Year, Value ---
S_long = orderfields(S_long, [meta_fields; {'Year'; 'Value'}]);