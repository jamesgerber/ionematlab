 switch cropname
        case 'maize'
            NSS.coloraxis=[0 12];
            MaxYield=12;
        case 7
            NSS.coloraxis=[0 8.5];
        case 4
            NSS.coloraxis=[0 10];
        case 13
            NSS.coloraxis=[0 4];
        case 12
            NSS.coloraxis=[1.5 1.8];
        case 20
            NSS.coloraxis=[0 8];
        case 25
            NSS.coloraxis=[0 20];
        otherwise
            NSS.coloraxis=[.99];
    end