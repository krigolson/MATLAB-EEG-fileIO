function [EEG] = doLoadCGX20(fileName)

    % by Olav Krigolson, April 2019
    % load PEER CSV data into MATLAB in EEGLAB format
    % note this code reorders the channels into logical order of AF7, AF8,
    % TP9, and TP10 and not the MUSE order of TP9, AF7, AF8, TP10. The data
    % is also detrended to remove the DC offset in the signal - the so
    % called MUSE unit conversion
    % set targetMarkers = {'N'} if there are no markers in the data

    % If dataLines is not specified, define defaults
    if nargin < 2
        dataLines = [2, Inf];
    end

    opts = delimitedTextImportOptions("NumVariables", 50);

    % Specify range and delimiter
    opts.DataLines = dataLines;
    opts.Delimiter = ",";

    % Specify column names and types
    opts.VariableNames = ["Timestamp", "Trial", "Block", "Marker", "Trigger", "F7", "FP1", "FP2", "F8", "F3", "FZ", "F4", "C3", "Cz", "P8", "P7", "PZ", "P4", "T7", "P3", "O1", "O2", "C4", "T8", "A1", "A2", "F7Impedance", "FP1Impedance", "FP2Impedance", "F8Impedance", "F3Impedance", "FZImpedance", "F4Impedance", "C3Impedance", "CzImpedance", "P8Impedance", "P7Impedance", "PZImpedance", "P4Impedance", "T7Impedance", "P3Impedance", "O1Impedance", "O2Impedance", "C4Impedance", "T8Impedance", "A1Impedance", "A2Impedance", "AccelX", "AccelY", "AccelZ"];
    opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

    % Specify file level properties
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";

    % Import the data
    tempData = readtable(fileName, opts);
    tempData = table2array(tempData);
    
    eegData = tempData(:,6:26);
    eegData = eegData';
    impedanceData = tempData(:,27:47);
    accData = tempData(:,48:50);
    markerDataRaw = tempData(:,4);
    timeData = tempData(:,1);
    trialData = tempData(:,2);
    blockData = tempData(:,3);
    triggerData = tempData(:,5);

    % setup the EEGLAB format
    EEG = eeg_emptyset;
    
    % default sampling rate for MUSE
    EEG.srate = 500;

    % put the data into EEGLAB format and reorder to logical order of AF7, AF8,
    % TP9, TP10 - also use detrend to remove the mean and any DC trends
    EEG.data(1,:) = detrend(eegData(1,:));
    EEG.data(2,:) = detrend(eegData(2,:));
    EEG.data(3,:) = detrend(eegData(3,:));
    EEG.data(4,:) = detrend(eegData(4,:));
    EEG.data(5,:) = detrend(eegData(5,:));
    EEG.data(6,:) = detrend(eegData(6,:));    
    EEG.data(7,:) = detrend(eegData(7,:));
    EEG.data(8,:) = detrend(eegData(8,:));
    EEG.data(9,:) = detrend(eegData(9,:));
    EEG.data(10,:) = detrend(eegData(10,:));
    EEG.data(11,:) = detrend(eegData(11,:));
    EEG.data(12,:) = detrend(eegData(12,:));    
    EEG.data(13,:) = detrend(eegData(13,:));
    EEG.data(14,:) = detrend(eegData(14,:));
    EEG.data(15,:) = detrend(eegData(15,:));
    EEG.data(16,:) = detrend(eegData(16,:));
    EEG.data(17,:) = detrend(eegData(17,:));
    EEG.data(18,:) = detrend(eegData(18,:));   
    EEG.data(19,:) = detrend(eegData(19,:));
    EEG.data(20,:) = detrend(eegData(20,:));
    EEG.data(21,:) = detrend(eegData(21,:));
    
    EEG.pnts = length(EEG.data);

    % checks to make sure that markers are single digits and not
    % consecutive replicates
    lastPosition = length(markerDataRaw);
    currentPosition = 2;
    while 1
        if markerDataRaw(currentPosition,1) ~= markerDataRaw(currentPosition-1,1)
            zeroPosition = currentPosition + 1;
            if zeroPosition > length(markerDataRaw)
                break
            end
            currentTarget = markerDataRaw(currentPosition,1);
            while 1
                if markerDataRaw(zeroPosition,1) == currentTarget
                    markerDataRaw(zeroPosition,1) = 0;
                else
                    currentPosition = zeroPosition - 1;
                    break
                end
                zeroPosition = zeroPosition + 1;
                if zeroPosition > length(markerDataRaw)
                    break
                end
            end
        end
        currentPosition = currentPosition + 1;
        if currentPosition > length(markerDataRaw)
            break
        end
    end

    % create markers data
    markers = [];
    markers = markerDataRaw;
    markerCounter = 1;
    for counter = 1:size(tempData,1)
        if markerDataRaw(counter) ~= 0
            markerData(markerCounter,1) = markerDataRaw(counter);
            markerData(markerCounter,2) = counter;
            markerCounter = markerCounter + 1;
        end
    end

    % create an EEGLAB event variable
    EEG.event = [];
    for counter = 1:length(markerData)
        EEG.event(counter).latency = markerData(counter,2);
        EEG.event(counter).duration = 1;
        EEG.event(counter).channel = 0;
        EEG.event(counter).bvtime = [];
        EEG.event(counter).bvmknum = counter;
        
        if markerData(counter,1) < 10
            stringMarker = ['S  ' num2str(markerData(counter,1))];
        end
        if markerData(counter,1) > 10 && markerData(counter,1) < 100
            stringMarker = ['S ' num2str(markerData(counter,1))];
        end
        if markerData(counter,1) > 99
            stringMarker = ['S' num2str(markerData(counter,1))];
        end   
        EEG.event(counter).type = stringMarker;
        EEG.event(counter).code = 'Stimulus';
        EEG.event(counter).urevent = counter;
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
    
    EEG.nbchan = 21;
    
    EEG.chanlocs(1).labels = 'F7';
    EEG.chanlocs(2).labels = 'Fp1';
    EEG.chanlocs(3).labels = 'Fp2';
    EEG.chanlocs(4).labels = 'F8';
    EEG.chanlocs(5).labels = 'F3';
    EEG.chanlocs(6).labels = 'Fz';
    EEG.chanlocs(7).labels = 'F4';
    EEG.chanlocs(8).labels = 'C3';
    EEG.chanlocs(9).labels = 'Cz';
    EEG.chanlocs(10).labels = 'P8';
    EEG.chanlocs(11).labels = 'P7';
    EEG.chanlocs(12).labels = 'Pz';
    EEG.chanlocs(13).labels = 'P4';
    EEG.chanlocs(14).labels = 'T7';
    EEG.chanlocs(15).labels = 'P3';
    EEG.chanlocs(16).labels = 'O1';
    EEG.chanlocs(17).labels = 'O2';
    EEG.chanlocs(18).labels = 'C4';
    EEG.chanlocs(19).labels = 'T8';
    EEG.chanlocs(20).labels = 'TP9';
    EEG.chanlocs(21).labels = 'TP10';
    
    EEG = pop_chanedit(EEG,'lookup','Standard-10-20-Cap81.ced');
    
end