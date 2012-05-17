function makereduceddatasets(varargin);
% makereduceddatasets - Zoom graph to maximum value.
%
%  Syntax:
%
%      makereduceddatasets('Initialize')
%         will create a uicontrol
%         which, if pressed, will take the long/lat limits of the
%         current figure, and create reduced datasets in the base
%         workspace with 5minute resolution.
%
%     These datasets will have the suffix "Red" appended to the filenames.
%
%     Datasets LatRed and LongRed will be created.
%
%
if nargin==0
    help(mfilename)
    return
end



InputFlag=varargin{1};

switch(InputFlag)
    
    
    
    case 'Initialize'
        uicontrol('String','Reduce','Callback', ...
            'makereduceddatasets(''Reduce'')','position',nextbuttoncoords);
        
    case 'Reduce'
        
        
        % this code will use the variable MRDS in the base workspace.
        % If that exists, then exit with an error
        
        exval=evalin('base','exist(''MRDS'')');
        
        if exval==1
            error('can not proceed.  MRDS exists in base workspace');
        end
        
        
        hax=get(gcbf,'CurrentAxes');
        Xlim=get(hax,'XLim');
        Ylim=get(hax,'YLim');
        
        
        %% Determine lat, long
        tmp=linspace(-1,1,2*4320+1);
        Long=180*tmp(2:2:end).';
        
        tmp=linspace(-1,1,2*2160+1);
        Lat=-90*tmp(2:2:end).';
        
        
        %%% assign to the base workspace the min and max values of lat
        %and long
        
        MRDS.MinLong=Xlim(1);
        MRDS.MaxLong=Xlim(2);
        MRDS.MinLat=Ylim(1);
        MRDS.MaxLat=Ylim(2);
        d=1/12;MRDS.Long=[(-180+d/2):d:(180-d/2)];
        d=1/12;MRDS.Lat=[(90-d/2):-d:(-90+d/2)];
        assignin('base','MRDS',MRDS);
        
        
        
        evalin('base','mrds_action');
        % now clean up:
        evalin('base','clear MRDS')
            
        
    otherwise
        error('syntax error in makereduceddatasets.m')
end



