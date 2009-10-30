function [PosVarZeros, NegVarZeros, BestVarZeros] = FindBestZeroCrossings(time, variable, FigureFlag)
% FINDBESTZEROCROSSINGS find "best" zero crossings of a series
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FindBestZeroCrossings.m will take a vector and find the best positive zero crossings, the best negative zero crossings
%       and the best zero crossings that will find the minimum value of the positive-negative pairs.
%
% Syntax:
%      [PosVarZeros, NegVarZeros, BestVarZeros] = FindBestZeroCrossings(time, variable, FigureFlag)
%      inputs:  time, variable, and a FigureFlag (=0 or 1) [(0=no figures, 1=figures)]
%      outputs:  a nx2 matrix of the positive values locations (datapoints) closest to zero
%                a mx2 matrix of the negative values locations (datapoints) closest to zero
%                [ column2 - column1 = # of positive(negative) datapoints between 2 zero's ... can easily search for peaks between column1 & column 2]
%                a zx1 vector of the values locations (datapoints) closest to zero.
%
% diana bull                                                                                                                         10-24-06
%                                                                                                                 released on server 11-14-06
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if isempty(FigureFlag); FigureFlag=0; end

%%First figure out how variable begins and ends.
MinVal=[];
BeginDirection=sign(variable(2));
EndDirection=sign(variable(end));

if BeginDirection==0
    j=3;
    while BeginDirection==0
        BeginDirection=sign(variable(j));
        j=j+1;
    end
end

if EndDirection==0
    j=length(variable)-1;
    while EndDirection==0
        EndDirection=sign(variable(j));
        j=j-1;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  Working with Positive Values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PosVar=find(variable>=0);
diffPosVar=[diff(PosVar(1:2));diff(PosVar)];
PosVarZerosA=find(diffPosVar~=1);
badPosVarA=find([diff(PosVarZerosA)]==1);  %%check to see if two peaks have been identified without any positive values between them...
PosVar(PosVarZerosA(badPosVarA))=[];

%%recalculate diffPosVar and A-zeros so that everything is on the correct number scale.
diffPosVar=[diff(PosVar(1:2));diff(PosVar)];
PosVarZerosA=find(diffPosVar~=1);

badDiffPosVar=find([diffPosVar(PosVarZerosA)]<=3); %%check to see if there is a "minimal" peak (i.e. with less than 3 points) separatinge Positive sections.
PosVarZerosA(badDiffPosVar)=[];
if FigureFlag==1
    figure;plot(time,variable,'k');grid on;hold on
    plot(time(PosVar(PosVarZerosA)),variable(PosVar(PosVarZerosA)),'*r')
end


%%perform 2 checks...beginning and end of files...
%if PosVarZerosB(1)==1
if BeginDirection==-1;
    if PosVar(PosVarZerosA(1))==1
        %%this says that the first identifier is NOT for a positive peak
        %%thus get rid of it.
        PosVarZerosA(1)=[];
    end
elseif BeginDirection==1
    if PosVar(PosVarZerosA(1))> 3
        PosVarZerosA=[1;PosVarZerosA];
    end
end

PosVarZerosB=(PosVarZerosA(2:end)-1);

if EndDirection==1
    %%this says file ending in positive heave
    %%thus will have no B match to final A....
    PosVarZerosA(end)=[];
end
if EndDirection==-1
    PosVarZerosB=[PosVarZerosB; length(PosVar)];
end

if FigureFlag==1
    plot(time(PosVar(PosVarZerosA)),variable(PosVar(PosVarZerosA)),'*g')
    plot(time(PosVar(PosVarZerosB)),variable(PosVar(PosVarZerosB)),'*b')
end

PosVarZeros=[ PosVar(PosVarZerosA) , PosVar(PosVarZerosB) ];
if max( variable([PosVarZeros(1,1):PosVarZeros(1,2)]) )==variable(PosVarZeros(1,1))
    %%there is NO peak between the first identified "zero" crossings, thus there is no peak...
    %%therefore the first peak is really a negative peak, so remove the first two points.
    PosVarZeros(1,:)=[];
    PosVarZerosA(1)=[];
    PosVarZerosB(1)=[];
elseif PosVarZeros(1,2)-PosVarZeros(1,1)<=floor( mean(PosVarZeros(:,2)-PosVarZeros(:,1))-3*std(PosVarZeros(:,2)-PosVarZeros(:,1)) )
    %%this REALLY is NOT a peak...so dont count it as such....
    PosVarZeros(1,:)=[];
    PosVarZerosA(1)=[];
    PosVarZerosB(1)=[];
end

if FigureFlag==1
    plot(time(PosVar(PosVarZerosA)),variable(PosVar(PosVarZerosA)),'*m')
    plot(time(PosVar(PosVarZerosB)),variable(PosVar(PosVarZerosB)),'*y')
end

%PosVarZerosA=PosVar(PosVarZerosA);
SortedPosVarZeros=sort([PosVarZerosB ; (PosVarZerosA)]);
%figure;plot(time,variable,'k');grid on;hold on
%plot(time((SortedPosVarZeros)),variable((SortedPosVarZeros)),'*r')



SortedPosVarZeros=sort([(PosVar(PosVarZerosB)) ; (PosVar(PosVarZerosA))]);
% figure;plot(time,variable,'k');grid on;hold on
% plot(time((SortedPosVarZeros)),variable((SortedPosVarZeros)),'*r')




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  Working with Negative Values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NegVar=find(variable<=0);
if ~isempty(NegVar)
    diffNegVar=[diff(NegVar(1:2));diff(NegVar)];
    NegVarZerosA=find(diffNegVar~=1);

    badNegVarA=find([diff(NegVarZerosA)]==1);  %%check to see if two peaks have been identified without any negative values between them...
    NegVar(NegVarZerosA(badNegVarA))=[];
    %%recalculate diffNegVar and A-zeros so that everything is on the correct number scale.
    diffNegVar=[diff(NegVar(1:2));diff(NegVar)];
    NegVarZerosA=find(diffNegVar~=1);

    badDiffNegVar=find([diffNegVar(NegVarZerosA)]<=3); %%check to see if there is a "minimal" peak (i.e. with less than 3 points) separating negative sections.
    %%however, only throw this peak away *IF* it will not correspond to a set of positive peaks.
    %%must move from last peak to first peak so that the Vector NegVarZerosA will not be disturbed.
    a=1./badDiffNegVar;
    [b d]=sort(a);
    badDiffNegVar=badDiffNegVar(d);
    if ~isempty(badDiffNegVar)
        for j=1:length(badDiffNegVar)
            PositivePeakCorrespondence=find( (PosVarZeros(:,2)+1) ==  NegVar(NegVarZerosA(badDiffNegVar(j))) );
            if isempty(PositivePeakCorrespondence) %%if PositivePeakCorrespondence is empty, then the "minimal" trough is NOT associated with a positive peak.
                NegVarZerosA(badDiffNegVar(j))=[];
            end
        end
    end

    if FigureFlag==1
        figure;plot(time,variable,'k');grid on;hold on
        plot(time(NegVar(NegVarZerosA)),variable(NegVar(NegVarZerosA)),'*r')
    end

    if BeginDirection==-1
        if NegVar(NegVarZerosA(1))>3
            NegVarZerosA=[1;NegVarZerosA];
        end
    elseif BeginDirection==1
        if NegVar(NegVarZerosA(1))==1
            %%this says that the first identifier is for a positive peak
            %%thus get rid of the first neg guy if ==1.
            NegVarZerosA(1)=[];
        end
    end


    NegVarZerosB=(NegVarZerosA(2:end)-1);

    if EndDirection==1
        %%this says file ending in positive heave
        %%thus need the end of the file to match final A....
        NegVarZerosB=[NegVarZerosB; (length(NegVar))];
    elseif EndDirection==-1
        %%this says file ending in negative heave
        %%thus will have no B match to final A....
        NegVarZerosA(end)=[];
    end

    if FigureFlag==1
        plot(time(NegVar(NegVarZerosA)),variable(NegVar(NegVarZerosA)),'*g')
        plot(time(NegVar(NegVarZerosB)),variable(NegVar(NegVarZerosB)),'*b')
    end

    NegVarZeros=[ NegVar(NegVarZerosA) , NegVar(NegVarZerosB) ];
    if max(abs( variable([NegVarZeros(1,1):NegVarZeros(1,2)]) ))==abs(variable(NegVarZeros(1,1)))
        %%there is NO peak between the first identified "zero" crossings, thus there is no peak...
        %%therefore the first peak is really a negative peak, so remove the first two points.
        NegVarZeros(1,:)=[];
        NegVarZerosA(1)=[];
        NegVarZerosB(1)=[];
    elseif NegVarZeros(1,2)-NegVarZeros(1,1)<=floor( mean(NegVarZeros(:,2)-NegVarZeros(:,1))-3*std(NegVarZeros(:,2)-NegVarZeros(:,1)) )
        %%this REALLY is NOT a peak...so dont count it as such....
        NegVarZeros(1,:)=[];
        NegVarZerosA(1)=[];
        NegVarZerosB(1)=[];
    end

    if FigureFlag==1
        plot(time(NegVar(NegVarZerosA)),variable(NegVar(NegVarZerosA)),'*m')
        plot(time(NegVar(NegVarZerosB)),variable(NegVar(NegVarZerosB)),'*y')
    end

    %NegVarZerosA=NegVar(NegVarZerosA);
    SortedNegVarZeros=sort([NegVarZerosB ; (NegVarZerosA)]);
    % figure;plot(time,variable,'k');grid on;hold on
    % plot(time(NegVar(SortedNegVarZeros)),variable(NegVar(SortedNegVarZeros)),'*r')

    % %%perform 2 checks...beginning and end of files...
    % if variable((NegVarZerosB(1))+2)>0
    %     %%this says that the first identifier is NOT for a Negitive peak
    %     %%thus get rid of it.
    %     NegVarZerosB(1)=[];
    % end
    %
    % if (NegVar(end))==length(variable)
    %     %%this says file ending in Negitive heave
    %     %%thus will have no B match to final A....
    %     NegVarZerosA(end)=[];
    % end
    % SortedNegVarZeros=sort([NegVarZerosB ; (NegVarZerosA)]);
    %  figure;plot(time,variable,'k');grid on;hold on
    % plot(time((SortedNegVarZeros)),variable((SortedNegVarZeros)),'*r')

    SortedNegVarZeros=sort([NegVar(NegVarZerosB) ; NegVar(NegVarZerosA)]);
end %end ~isempty(NegVar)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  Putting Positive and Negative Zeros together to find values closest to zero.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(NegVar)
    [SortedVarZeros indicies]=sort([SortedPosVarZeros ; SortedNegVarZeros]);


    %if BeginDirection==1
    for j=2:2:length(SortedVarZeros)-1
        [val minIndex]=min(abs([variable(SortedVarZeros(j)) variable(SortedVarZeros(j+1))]));
        MinVal(j)=(minIndex-1)+j;
    end

    ii=find(MinVal==0);
    MinVal(ii)=[];
    MinVal=MinVal(:);

    MinVal=[1;MinVal;length(SortedVarZeros)];

    BestVarZeros=SortedVarZeros(MinVal);

    if FigureFlag==1
        figure;plot(time,variable,'k');grid on;hold on
        plot(time((BestVarZeros)),variable((BestVarZeros)),'*r')
    end
else
    BestVarZeros=PosVarZeros;
    NegVarZeros=[];
end






