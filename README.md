# MATLAB-EEG-fileIO

The files in this repository are for ERP data from Brain Vision Analyzer into MATLAB for statistical analysis. 

You will need to have EEGLAB, the dependentFunctions subfolder, and the bva-io subfolder in your path. 

1. To load in raw BV data using a popup to select a file simply type: 

EEG = loadBVData();

or

EEG = loadBVData('fileName.vhdr');

To load in raw data from a script.

2. To load averaged ERP data from BV Analyzer:

First, in Analyzer, export your average data with channel names. Make sure you have unique condition names! Also, this software is quite dumb, it assumes that all the condition files are in the same order for each person:

subject1_condition1 subject1_condition2 subject2_condition1 subject2_condition2 subject3_condition1 etc...

All of the data needs to be in a single folder with nothing else.

The function call to load average data is:

[ERP] = loadBVConditionData(15,4,36,[1 2 4 3],[-200 596],250);

Note, this function will load all of the data from one directory! In this case, it is expecting 60 files (15 participants x 4 conditions)!

So, the command in this instance is specifying 15 participants, 4 conditions, 36 channels. The next bit allows you to reorder conditions - so in this case the positions of conditions 3 and 4 are being swapped. At the end we are specifying a start and end time for the time vector and the sampling rate (250 Hz).

The function will create a variable ERP that has data in the format of channels x time x conditions x participants in ERP.data. It will also create ERP.time for plotting. Finally, it will create an EEGLAB chanlocs file (ERP.chanlocs) for topographical plotting.

One quirk this software fixes relates to Analyzer. In Analyzer interplated channels are put in the last position so your channels will be in the wrong order if combined directly. This software will ensure that all subjects after the first have the same channel order as the first subject loaded.
