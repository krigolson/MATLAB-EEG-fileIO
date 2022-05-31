function EEG = doLoadEDF(fileName,chanLocs)

    % function to load EDF format files, you need to specify the fileName
    % and the samplingRate, note, the target file needs to be in the path

    data = edfread(fileName);
    EEG = convertEDFtoEEG(data);
    EEG.chanlocs = chanLocs;

end