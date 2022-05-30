function EEG = convertEDFtoEEG(data,srate)

    x = data{1,2};
    y = cell2mat(x);
    samplingRate = size(y,1);

    TT=timetable2table(data);

    timePoints = size(TT,1);

    channels = size(TT,2);

    channelCount = channels - 2;

    channelNames = TT.Properties.VariableNames;
    
    rawEEG = [];

    for channelCounter = 2:20

        tempEEG = [];

        for timeCounter = 1:timePoints

            tempD = table2array(TT(timeCounter,channelCounter));

            tempData = tempD{1};

            tempEEG = [tempEEG; tempData];

        end

        rawEEG(channelCounter-1,:) = tempEEG;

    end

    EEG = [];
    
    EEG = eeg_emptyset;
    EEG.chanlocs = x;

    EEG.srate = srate;
 
    EEG.data = rawEEG;

    EEG.pnts = length(EEG.data);

    % correct time stamps for EEGLAB format
    EEG.times = [];
    EEG.times(1) = 0;
    for counter = 2:size(EEG.data,2)
        EEG.times(counter) = EEG.times(counter-1) + (1/EEG.srate*1000);
    end
    EEG.xmin = EEG.times(1);
    EEG.xmax = EEG.times(end)/1000;

    EEG.nbchan = channelCount;

end