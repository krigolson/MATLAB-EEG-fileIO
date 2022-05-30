function [ERP] = loadBVConditionData(numberOfParticipants,numberOfConditions,numberOfChannels,conditionOrder,epochTimes,samplingRate);
% by Olav Krigolson, June 2018
% This function loads BV exported conditional data with channel names. It
% returns an ERP.data matrix = channels x time x conditions x participants. It
% all returns a EEGLAB channel locations file for topographical plotting (ERP.chanlocs).
% The function reorders the channels for consitency aligned with the first
% participant (in case channels were deleted and interpolated).
% You need to pass this function the number of participants, the number of
% conditions, and the number of channels.
% It also asks for the actual condition order [1 2 4 3] for example if you
% want to swap the 3rd and 4th conditions. For no swap, just go [1 2 3 4].
% Finally, for a time vector you need to pass it the epoch window [-200
% 596] and the sampling rate 250.
    
    directoryname = uigetdir;
    cd(directoryname);
    files = dir('*.txt');

    fileNumber = 1;

    for fileCounter = 1:numberOfParticipants
        
        disp('Currently on...');
        fileCounter

        for conditionCounter = 1:numberOfConditions

            fileName = files(fileNumber).name;
            
            disp('Current file name...');
            fileName
            
            data = [];
            data = importBVConditionERPData(fileName, 1, numberOfChannels);
            tempERP(:,:,conditionCounter,fileCounter) = data;
            channelNames{fileCounter,:} = importBVChannelNames(fileName, 1, numberOfChannels);
            
            fileNumber = fileNumber + 1;

        end

    end
    
    % check to ensure channels in the right order for everyone, assume
    % person number one is in the right order
    
    correctChannelOrder = channelNames{1};
    
    disp('Number of Channels to be used...');
    size(correctChannelOrder)
    
    sortedERP(1:numberOfChannels,size(tempERP,2),1:numberOfConditions,1:numberOfParticipants) = NaN;
    sortedERP(:,:,:,1) = tempERP(:,:,:,1);
    
    for participantCounter = 2:numberOfParticipants
        
        for channelCounter = 1:numberOfChannels
            
            %disp('Current Participant... ');
            %participantCounter
            
            %disp('Current Channel... ');
            %correctChannelOrder(channelCounter)
            
            whereItIs = find(channelNames{participantCounter} == correctChannelOrder(channelCounter));
            sortedERP(channelCounter,:,:,participantCounter) = tempERP(whereItIs,:,:,participantCounter);
            
        end
        
    end
    
    % reorder conditions in case names are not in a logical order
    
   for conditionCounter = 1:numberOfConditions
       ERP.data(:,:,conditionCounter,:) = sortedERP(:,:,conditionOrder(conditionCounter),:);
   end

    % get channel location info
    allLocs = readlocs('Standard-10-20-Cap81.ced');
    channelCounter = 1;
    for counter = 1:length(allLocs)
        check = find(allLocs(counter).labels == correctChannelOrder);
        if length(check) > 0
            ERP.chanlocs(channelCounter) = allLocs(counter);
            channelCounter = channelCounter + 1;
        end
    end
    
    % generate time data
    ERP.time = [epochTimes(1):1/samplingRate*1000:epochTimes(2)];
    
end