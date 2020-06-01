% function to load BRain Vision format data
% by Olave Krigolson, Feb 2019
% has EEGLAB dependecies and also dependencies on pop_readbdf from the
% EEGLAB Biosig toolbox
%
% to have a popup select a file call EEG = loadBVData();
% 
% to script the call use EEG = loadBVData('fileName.vhdr');

function EEG = doLoadBioData(varargin)

    if size(varargin,1) == 0

        [filename, pathname, filterindex] = uigetfile('*.*','Pick a Biosemi format .vhdr file to load');
        cd(pathname);
        
    else
        
        filename = varargin{1};
        pathname = which(filename);
        pathname = erase(pathname,filename);
        cd(pathname);
        
    end

    EEG = pop_readbdf(pathname,filename);
    %EEG = pop_chanedit(EEG,'lookup','Standard-10-20-Cap81.ced');
    EEG.pathname = pathname;
    EEG.filename = filename;
    
end