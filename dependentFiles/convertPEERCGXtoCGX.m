function EEG = convertPEERCGXtoCGX(EEG)

    load('cgxLocs.mat');

    tempData(1,:) = EEG.data(2,:);   %Fp1
    tempData(2,:) = EEG.data(3,:);   %Fp2
    tempData(3,:) = EEG.data(5,:);   %F3 
    tempData(4,:) = EEG.data(7,:);   %F4
    tempData(5,:) = EEG.data(8,:);   %C3
    tempData(6,:) = EEG.data(18,:);  %C4
    tempData(7,:) = EEG.data(15,:);  %P3 
    tempData(8,:) = EEG.data(13,:);  %P4
    tempData(9,:) = EEG.data(16,:);  %O1
    tempData(10,:) = EEG.data(17,:); %O2
    tempData(11,:) = EEG.data(1,:);  %F7
    tempData(12,:) = EEG.data(4,:);  %F8
    tempData(13,:) = EEG.data(14,:); %T7 
    tempData(14,:) = EEG.data(19,:); %T8
    tempData(15,:) = EEG.data(11,:); %P7
    tempData(16,:) = EEG.data(10,:); %P8
    tempData(17,:) = EEG.data(6,:);  %Fz
    tempData(18,:) = EEG.data(9,:);  %Cz
    tempData(19,:) = EEG.data(12,:); %Pz

    EEG.data = [];
    EEG.data = tempData;

    EEG.chanlocs = [];
    EEG.chanlocs = chanlocs;

end