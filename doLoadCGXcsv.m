function [EEG] = doLoadCGXcsv(fileName)

    % read the file;
    rawData = readmatrix(fileName);

    % remove nan values
    rawData = rmmissing(rawData);

    % strip non eeg data
    rawData(:,20:end) = [];
    
    % setup the EEGLAB format
    EEG = [];
    EEG = eeg_emptyset;

    EEG.srate = 500;

    EEG.data = rawData';

    EEG.pnts = length(EEG.data);

    %correct time stamps for EEGLAB format
    EEG.times = [];
    EEG.times(1) = 0;
    for counter = 2:size(EEG.data,2)
        EEG.times(counter) = EEG.times(counter-1) + (1/EEG.srate*1000);
    end
    EEG.xmin = EEG.times(1);
    EEG.xmax = EEG.times(end)/1000;

    EEG.nbchan = size(EEG.data,1);
    
    % requires a correct channel map
    load('cgxQ20locs.mat');
    EEG.chanlocs = locs;
    
    % update to modern channel names
    for i = 1:length(EEG.chanlocs)
        if strcmp(EEG.chanlocs(i).labels,'T3')
            EEG.chanlocs(i).labels = 'T7';
        end
        if strcmp(EEG.chanlocs(i).labels,'T4')
            EEG.chanlocs(i).labels = 'T8';
        end
        if strcmp(EEG.chanlocs(i).labels,'T5')
            EEG.chanlocs(i).labels = 'P7';
        end
        if strcmp(EEG.chanlocs(i).labels,'T6')
            EEG.chanlocs(i).labels = 'P8';
        end
    end
    EEG = pop_chanedit(EEG,'lookup','Standard-10-20-Cap81.ced');
    
end
