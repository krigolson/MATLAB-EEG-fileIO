function EEG = doLoadEDF(fileName,chanLocs,samplingRate)

    % function to load EDF format files, you need to specify the fileName
    % and the samplingRate, note, the target file needs to be in the path

    data = edfread(fileName);
    EEG = convertEDFtoEEG(data,samplingRate);
    EEG.chanlocs = chanLocs;

end