% optimisticTMIproduction.m
% 
% This script will calculate optimistic potential production from closing
% yield gaps. This script uses TMI RevE climate.

% % % Change these things to create YieldGapFunction95mod.m
% % % 
% % % Near the beginning:
% % % MinNumberPointsPerBin=1;
% % % MinNumberHectares=1;
% % % MinNumberCountries=0;  % this doesn't actually do anything
% % % MinNumberYieldValues=1;
% % % potentialyield = zeros(4320,2160)
% % % 
% % % In Section to derive "90th %" yield (line 246)
% % % change n=90 to n=95;
% % % 
% % % Fill out the potential yield matrix (line 281)
% % % change Yield90 to Yield95
% % % potentialyield(IndicesToKeep) = Yield95

for CropNo = [7]
   for N=[10];
    Rev='F';
    YieldGapFunction
   end
end

for CropNo = [5 7]
    N=10;
    Rev='F';
    YieldGapFunction
end


for CropNo=[5 7 8 10]
N=10;
Rev='F';

    YieldGapFunction    
    
    Production(find(isnan(Production)))=0;
%    Production(find(potentialyield == 0))=0;
    currentprodsum = sum(sum(Production));


        potentialprod(find(isnan(potentialprod)))=0;
    potentialprodsum=sum(sum(potentialprod));
    
    perdifference = potentialprodsum ./ currentprodsum;
   
    disp([cropname ': current production = ' num2str(currentprodsum) ...
        ', 95 percentile production = ' num2str(potentialprodsum) ...
        ', percent difference = ' num2str(perdifference.*100) '%'])
    
end