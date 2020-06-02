function [EEG] = doLoadCGXDevKit(pathName,fileName,nbEEGChan,chanNames)

    % function to load Dev Kit data saved through the native app or through
    % LSL

    % try brain vision format first
    if strcmp(fileName(end-4:end),'.vhdr')
        EEG = doLoadBVData(pathName,fileName);
        allData = EEG.data;
    else
        streams = load_xdf(fileName);
        allData = streams{1,1}.time_series;
    end

    % isolate EEG data
    eegData = allData(1:nbEEGChan,:);

    % correct markers
    markerData = allData(13,:);
    position = 1;
    checkValue = 0;
    while 1
        currentValue = markerData(position);
        if currentValue > 0 && currentValue ~= checkValue
            checkValue = currentValue;
        else
            markerData(position) = 0;
        end
        position = position + 1;
        if position > length(markerData)
            break
        end
    end
    markerData = markerData / 256;

    % setup the EEGLAB format
    EEG = eeg_emptyset;

    % default sampling rate for MUSE
    EEG.srate = 500;

    EEG.data = eegData;

    EEG.pnts = length(EEG.data);

    % create an EEGLAB event variable
    EEG.event = [];
    eventCounter = 1;
    for counter = 1:length(markerData)
        if markerData(counter) ~= 0 & counter > EEG.srate * 2 % add this in to remove markers in the first bit of data
            EEG.event(eventCounter).latency = counter;
            EEG.event(eventCounter).duration = 1;
            EEG.event(eventCounter).channel = 0;
            EEG.event(eventCounter).bvtime = [];
            EEG.event(eventCounter).bvmknum = counter;

            if markerData(counter) < 10
                stringMarker = ['S  ' num2str(markerData(counter))];
            end
            if markerData(counter) > 10 && markerData(counter) < 100
                stringMarker = ['S ' num2str(markerData(counter))];
            end
            if markerData(counter) > 99
                stringMarker = ['S' num2str(markerData(counter))];
            end   
            EEG.event(eventCounter).type = stringMarker;
            EEG.event(eventCounter).code = 'Stimulus';
            EEG.event(eventCounter).urevent = counter;
            eventCounter = eventCounter + 1;
        end
    end
    EEG.urevent = EEG.event;
    EEG.allMarkers = markerData;        

    %correct time stamps for EEGLAB format
    EEG.times = [];
    EEG.times(1) = 0;
    for counter = 2:size(EEG.data,2)
        EEG.times(counter) = EEG.times(counter-1) + (1/EEG.srate*1000);
    end
    EEG.xmin = EEG.times(1);
    EEG.xmax = EEG.times(end)/1000;

    EEG.nbchan = nbEEGChan;
    
    EEG.chanlocs = struct('labels',chanNames);
    EEG = pop_chanedit(EEG,'lookup','Standard-10-20-Cap81.ced');
    
end
