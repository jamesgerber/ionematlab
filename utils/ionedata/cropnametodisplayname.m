function displayname=cropnametodisplayname(cropname)
% CROPNAMETODISPLAYNAME


switch lower(cropname)
    case 'greenbeans'
        displayname='Green Bean';
    case 'greenpeas'
        displayname='Green Pea';
    case 'bean'
        displayname='Bean (black)'
    case 'oats'
        displayname= 'oat'
    otherwise
        displayname=cropname;
end
