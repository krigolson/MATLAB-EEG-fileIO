function [EEG] = doLoadCGX(pathName,fileName,nbEEGChan,chanNames,validChannels,dataType,isPatch)

    % function to load CGX data saved through the native app in Brain Vision format, through
    % LSL in XDF format (requires the xdfimport library), or throuhg PEER
    % in csv format

    % try brain vision format first
    
    % dataType = 1 is pure CSV, dataType = 2 is extended csv with all the other detail
    % isPatch = 1 if yes = 0 if no.
    
    if isPatch == 1
        vMultipler = 1;
    else
        vMultipler = 1000000;
    end
    
    try
        if strcmp(fileName(end-4:end),'.vhdr')
            EEG = doLoadBVData(pathName,fileName);
            allData = EEG.data;
            eegData = allData(1:nbEEGChan,:);
            markers = allData(13,:);
            position = 1;
            checkValue = 0;
            while 1
                currentValue = markers(position);
                if currentValue > 0 && currentValue ~= checkValue
                    checkValue = currentValue;
                else
                    markers(position) = 0;
                end
                position = position + 1;
                if position > length(markers)
                    break
                end
            end
            markers = markers / 256;
        end
        if strcmp(fileName(end-3:end),'.xdf')
            streams = load_xdf(fileName);
            if streams{1,1}.info.name(1) == 'M'
                mStream = 1;
                dStream = 2;
            else
                mStream = 2;
                dStream = 1;
            end
            allData = streams{1,dStream}.time_series;
            timeStamps = streams{1,dStream}.time_stamps;
            eegData = allData(1:nbEEGChan,:);
            streamMarkers = streams{1,mStream}.time_series;
            markerTimes = streams{1,mStream}.time_stamps;
            markers(1:length(timeStamps)) = 0;

            for markerCounter = 1:length(timeStamps)

                currentMarkerTime = markerTimes(markerCounter);

                for timeCounter = 1:length(timeStamps)

                    checkTime = timeStamps(timeCounter);
                    if abs(checkTime - currentMarkerTime) < 0.001
                        break
                    end

                end

                markers(timeCounter) = str2num(streamMarkers{markerCounter});

            end
            
        end
        if strcmp(fileName(end-3:end),'.csv')
            
            if dataType == 1
                allData = csvread(fileName);
                % figure out the marker channel
                if max(allData(:,1)) == 0
                    mChannel = 1;
                    eegData = allData(:,validChannels);
                    eegData = eegData';
                    eegData = eegData * vMultipler;
                    markers = allData(:,mChannel);
                else
                    %mChannel = size(allData,2);
                    %eegData = allData(:,1:mChannel-1)';
                    %eegData = eegData * 1000000;
                    %markers = allData(:,mChannel);
                    mChannel = 1;
                    eegData = allData(:,validChannels);
                    eegData = eegData';
                    eegData = eegData * vMultipler;
                    markers = allData(:,mChannel);
                end
            else
                allData = complexCGX(fileName);
                markers = allData(:,1);
                allData(:,[1 2]) = [];
                eegData = allData';
            end

            if max(allData(:,1)) > 0
            
                lastPosition = length(markers);
                currentPosition = 2;
                while 1
                    if markers(currentPosition) ~= markers(currentPosition-1)
                        zeroPosition = currentPosition + 1;
                        if zeroPosition > length(markers)
                            break
                        end
                        currentTarget = markers(currentPosition);
                        while 1
                            if markers(zeroPosition) == currentTarget
                                markers(zeroPosition) = 0;
                            else
                                currentPosition = zeroPosition - 1;
                                break
                            end
                            zeroPosition = zeroPosition + 1;
                            if zeroPosition > length(markers)
                                break
                            end
                        end
                    end
                    currentPosition = currentPosition + 1;
                    if currentPosition > length(markers)
                        break
                    end
                end
                
            end
            
        end
    catch
        disp('No recognizable data found');
    end
    
    % convert markers to EEGLAB format
    
    if max(allData(:,1)) > 0
    
        % create markers data
        markerCounter = 1;
        for counter = 1:length(markers)
            if markers(counter) ~= 0
                markerData(markerCounter,1) = markers(counter);
                markerData(markerCounter,2) = counter;
                markerCounter = markerCounter + 1;
            end
        end
        
    end
    
    % setup the EEGLAB format
    EEG = [];
    EEG = eeg_emptyset;

    % create an EEGLAB event variable
    EEG.event = [];
    
    if max(allData(:,1)) > 0
    
        for counter = 1:size(markerData,1)
            EEG.event(counter).latency = markerData(counter,2);
            EEG.event(counter).duration = 1;
            EEG.event(counter).channel = 0;
            EEG.event(counter).bvtime = [];
            EEG.event(counter).bvmknum = counter;

            if markerData(counter,1) < 10
                stringMarker = ['S  ' num2str(markerData(counter,1))];
            end
            if markerData(counter,1) > 9 && markerData(counter,1) < 100
                stringMarker = ['S ' num2str(markerData(counter,1))];
            end
            if markerData(counter,1) > 99
                stringMarker = ['S' num2str(markerData(counter,1))];
            end   
            EEG.event(counter).type = stringMarker;
            EEG.event(counter).code = 'Stimulus';
            EEG.event(counter).urevent = counter;
        end
        
        EEG.allMarkers = markerData;
        
    end
    EEG.urevent = EEG.event;
    
    % default sampling rate for CGX systems
    if isPatch == 0
        EEG.srate = 500;
    else
        EEG.srate = 250;
    end

    EEG.data = eegData;

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
    
    EEG.chanlocs = struct('labels',chanNames);
    EEG = pop_chanedit(EEG,'lookup','Standard-10-20-Cap81.ced');
    
end
