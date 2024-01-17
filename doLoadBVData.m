% function to load BRain Vision format data
% by Olave Krigolson, Feb 2019
% has EEGLAB dependecies and also dependencies on bva-io
%
% to have a popup select a file call EEG = loadBVData();
% 
% to script the call use EEG = loadBVData('fileName.vhdr');

function EEG = doLoadBVData(varargin)

    if size(varargin,1) == 0

        [filename, pathname, filterindex] = uigetfile('*.*','Pick a Brain Vision format .vhdr file to load');
        cd(pathname);
        
    else
        
        pathname = varargin{1};
        filename = varargin{2};
        
    end

    [EEG, com] = pop_loadbv(pathname, filename);
    EEG = pop_chanedit(EEG,'lookup','Standard-10-20-Cap81.ced');
    EEG.pathname = pathname;
    EEG.filename = filename;
    
    % check for events with zero latency
    
    for i = size(EEG.event,2):-1:1
        
        if EEG.event(i).latency == 1
            EEG.event(i) = [];
        end
        
    end
    for i = 1:size(EEG.event,2)
        EEG.event(i).bvmknum = i;
        EEG.event(i).urevent = i;
        EEG.event(i).epoch = i;
    end
    EEG.urevent = EEG.event;
    
    
end