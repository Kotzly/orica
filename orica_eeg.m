% This is a test script for running orica()
% Start EEGLAB for data analysis. 
% EEGLAB can be downloaded at https://bitbucket.org/sccn_eeglab/eeglab

function [EEG] = orica_eeg()

arg_list = argv();

addpath("/home/paulo/Documents/GIT/eeglab");
addpath("/home/paulo/Documents/GIT/orica");

csv_file = arg_list{1};
save_file = arg_list{2};

eeglab
close

data = csvread(csv_file);
%data = csvread("/home/paulo/Documents/GIT/BCI_MsC/experiments/orica/sample.csv");
%% load sample EEG dataset
EEG = pop_loadset('SIM_STAT_16ch_3min.set');
EEG.data = double(data);		% convert to double precision to avoid round-off errors
disp("MAX");
disp(num2str(max(max(abs(data)))));
EEG.icawinv_true = EEG.etc.LFM{1};	% ground truth mixing matrix
EEG.icawinv = EEG.icawinv_true; EEG.icaweights = pinv(EEG.icawinv); EEG.icasphere = eye(EEG.nbchan); EEG = eeg_checkset(EEG);

[nChs, nPts] = size(data);
EEG.icaweights = [];    
EEG.icasphere  = [];
EEG.icawinv    = [];    
EEG.icaact     = [];

%% simulate online processing with ORICA
[EEG.icaweights, EEG.icasphere] = orica(EEG.data,'numpass',1, ...
	'sphering','online','block_white',8,'block_ica',8,'nsub',0, ...
	'forgetfac','cooling','localstat',Inf,'ffdecayrate',0.6, ...
	'evalconverg',1,'verbose','on', 'save_file', save_file);
%[EEG.icaweights, EEG.icasphere] = orica(EEG.data,'numpass',1, ...
%	'sphering','online','block_white',8,'block_ica',8,'nsub',0, ...
%	'forgetfac','adaptive','localstat',Inf,'ffdecayrate',0.6, ...
%	'evalconverg',1,'verbose','on');

end