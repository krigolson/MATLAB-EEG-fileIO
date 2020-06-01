function [EEG] = doLoadCGXDevKit(fileName)

    streams = load_xdf(fileName);

    allData = streams{1,1}.time_series;

    eegData = allData(1:8,:);

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

    EEG.data(1,:) = eegData(1,:);
    EEG.data(2,:) = eegData(2,:);
    EEG.data(3,:) = eegData(3,:);
    EEG.data(4,:) = eegData(4,:);
    EEG.data(5,:) = eegData(5,:);
    EEG.data(6,:) = eegData(6,:);    
    EEG.data(7,:) = eegData(7,:);
    EEG.data(8,:) = eegData(8,:);
    
    % because we are only using two channels
    EEG.data(3:8,:) = [];

    EEG.pnts = length(EEG.data);

    % create an EEGLAB event variable
    EEG.event = [];
    eventCounter = 1;
    for counter = 1:length(markerData)
        if markerData(counter) ~= 0
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

    EEG.nbchan = 2;
    
end
