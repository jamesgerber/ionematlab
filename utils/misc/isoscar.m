function isoscar = isoscar()
%ISOSCAR Determines if the running computer is Oscar
%   Checks the computers IP address and if it executes a successful grep of
%   the hardware adress it returns true
if(~strcmp(computer, 'MACI64'))
    isoscar = False;
else
    [~,ip] = system('ifconfig -a | grep "ether 00:3e:e1:c6:33:c2"');

    if(ip ~= 0)
        isoscar = true;
    else
        isoscar = false;
    end
end
end

