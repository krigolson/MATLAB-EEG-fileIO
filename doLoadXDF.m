% function EEG = doLoadXDF(fileName);

    %fileName = ''

    % load xdf file
    streams = load_xdf(fileName);
    % extract EEG data
    tempData = streams{1,1}.time_series;
    % extract EEG time stamps
    eegTime = streams{1,1}.time_stamps;
    % extract marker time stamps
    markers = streams{1,2}.time_series;
    % extract marker time stamps
    markerTime = streams{1,2}.time_stamps;

