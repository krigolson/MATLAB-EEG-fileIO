% matt analysis

EEG1 = doLoadMindMonitor('matt_open2.csv',2);
EEG2 = doLoadMindMonitor('matt_closed2.csv',2);

EEG1 = doFilter(EEG1,0.1,30,2,0,EEG1.srate);
EEG2 = doFilter(EEG2,0.1,30,2,0,EEG2.srate);

EEG1 = doTemporalEpochs(EEG1,1000,900);
EEG2 = doTemporalEpochs(EEG2,1000,900);

EEG1 = doArtifactRejection(EEG1,'Difference',60);
EEG2 = doArtifactRejection(EEG2,'Difference',60);

EEG1 = doRemoveEpochs(EEG1,EEG1.artifact.badSegments,0);
EEG2 = doRemoveEpochs(EEG2,EEG2.artifact.badSegments,0);

FFT1 = doFFT(EEG1,{'S  1'});
FFT2 = doFFT(EEG2,{'S  1'});

figure

subplot(2,2,1);
plot(FFT1.data(1,1:30));
hold on;
plot(FFT2.data(1,1:30));

subplot(2,2,2);
plot(FFT1.data(2,1:30));
hold on;
plot(FFT2.data(2,1:30));

subplot(2,2,3);
plot(FFT1.data(3,1:30));
hold on;
plot(FFT2.data(3,1:30));

subplot(2,2,4);
plot(FFT1.data(4,1:30));
hold on;
plot(FFT2.data(4,1:30));