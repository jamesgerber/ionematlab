function DPD=DataProductsDir;
    % return directory linking to DataProducts/


    [ret, name] = system('hostname');

switch name(1:11)
        case 'C02F930BMD6'
            DPD='/Users/jsgerber/DataProducts/';
        case 'MacBook1003'
             DPD='/Volumes/Monarch/DataProducts/';
        otherwise
            error
    end
