function s=bytestostr(b)
% BYTETOSTR - returns a string representation of a given number of bytes
if (b<1000)
    s=[num2str(b) ' bytes'];
 else if (b<1000000)
         s=[num2str(b/1000) ' KB'];
     else if (b<1000000000)
             b=b/1000000;
             b=round(b/.01)*.01;
            s=[num2str(b) ' MB'];
        else if (b<1000000000000)
                s=[num2str(b/1000000000) ' GB'];
            else if (b<1000000000000000)
                s=[num2str(b/1000000000000) ' TB'];
                end
            end
        end
    end
end