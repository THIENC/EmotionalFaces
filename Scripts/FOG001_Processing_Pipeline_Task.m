%% define some parameters
% task = 'Before_Drug';
% % define parameters
% fieldepoch = 'start';
% twepoch = [-300 1100];
% bc = 1;
% bcfield = 'start';
% twbc = [-200 0];
% smoothwin = 50;
% twResc = [-200 0];
% twsmooth = [-200 1000];
% Scripts for FOG001 patient
% Baotian Zhao Beijing 20180917
% zhaobaotian0220@foxmail.com

% Add SPM
addpath('D:\spm12_7219');
spm('defaults', 'EEG');
% Add path
addpath(genpath('D:\PrivateLibrary\DBS_FOG_Project_Analysis_Pipeline'))

clear
ScriptFolder = 'D:\PrivateLibrary\DBS_FOG_Project_Analysis_Pipeline';
cd(ScriptFolder)

SubjectFolder = 'D:\0.FOG_Cohort\FOG001_²Ü´«Ã÷_Raw\ConvertedTOSPM\RightHandClench';
cd(SubjectFolder)


%% convert data to SPM format
D = AOConvertedMat_TO_SPM();
D = spm_eeg_load();
%% view the raw data in time traces and power spectrum
% Raw traces
plotECG(D.time,D(:,:,1)','AutoStackSignals',D.chanlabels)
% Raw power spectrum
% for visually check PSD using pwelch method
TimeWindow = [1 50]; % In second

mkdir('figs')
mkdir('PwelchPSD')
cd('PwelchPSD')
parfor i = 1:size(D,1)
    figure
    pwelch(D(i,TimeWindow(1)*D.fsample:TimeWindow(2)*D.fsample,1),1375,1300,(1:250),1375);
    title(D.chanlabels{i},'Interpreter','none')
    set(gca,'FontSize',20)
    set(findobj(gca,'type','line'),'linew',4)
    print([D.chanlabels{i} '_' 'PowerSpec'],'-dpng')
    close
end
cd ..
cd ..
%% Down sampling to 1000Hz
clear S
S.D = D;
S.fsample_new = 1000;
D = spm_eeg_downsample(S);

%% Filter the signal 4 times, minimal preprocessing the raw resting data
% 1st, 2nd, 3rd, 4th are bandstop around 50Hz, 100Hz, 150Hz, 200Hz
% respectively
for i = 1:4
    clear S
    S.D              = D;
    S.band           = 'stop';
    S.freq           = [50*i-3 50*i+3];
    S.order          = 5;
    S.prefix         = 'f';
    D = spm_eeg_filter(S);
end

% for i = 1:32
%     figure
%     pwelch(D(i,TimeWindow(1)*D.fsample:TimeWindow(2)*D.fsample,1),5000,2500,[1:250],1000);
% end

%% Montage (averge good channels)
[D,montage_file] = SPM_Manual_Montage(D,'M');

%% High pass before epoch
clear S
S.D              = D;
S.band           = 'high';
S.freq           = 1;
S.order          = 5;
S.prefix         = 'HighP';
D = spm_eeg_filter(S);

%% Epoch Data in from trigger
load('TimeStamps.mat')
TimeStampsFinal = TimeStampsFinal(4:43);
% construct the trl matrix
TrlOnsets    = round(TimeStampsFinal*1000) - 700;
TrlOffsets   = round(TimeStampsFinal*1000) + 1700;
OnsetTime    = repmat(-700,[40,1]);
Trl          = [TrlOnsets',TrlOffsets',OnsetTime];
clear S
S.D               = D;
S.bc              = 1;
S.trl             = Trl; % in ms
S.conditionlabels = 'RightHandClench';
D = spm_eeg_epochs(S);

%% set the bad trials and bad channels
D = D.badchannels([9 16 19],1);
save(D)
% mannual label the bad trials in SPM GUI

%% Time frequency transform
clear S 
S.D                 = D;
S.channels          = 'All';     
S.frequencies       = [1:10, 11:2:20, 21:3:40, 41:4:70, 70:5:200];
S.method            = 'morlet'; 
S.phase             = 0;      
S.prefix            = 'tf_'; 
D = spm_eeg_tf(S);
% for i = 1:40
%     figure
% imagesc(squeeze(D(8,:,:,i)))
% axis ij
% end
%% Crop before the TF rescale
clear S 
S.D = D;
S.timewin = [-500 1500];
D = spm_eeg_crop(S);
%% Rescale the raw TF map
clear S 
S.D            = D;
S.method       = 'Rel';
S.timewin      = [-500 0];

D = spm_eeg_tf_rescale(S);
%% average the epochs
FinalTaskEEGTF = D(:,:,:,:);
FinalTaskEEGTFMeanEpoch = squeeze(mean(FinalTaskEEGTF,4));
save('ImagineClench1Final.mat','FinalTaskEEGTF')

% Smooth the TF map before plot
% Selected Channel to plot
FrequenciesOfInterest = [1:10, 11:2:20, 21:3:40, 41:4:70, 70:5:200];
for i = 1:32
    figure
    SmoothedImage = imgaussfilt(squeeze(FinalTaskEEGTFMeanEpoch(i,:,:)),[1,20]);
    imagesc(SmoothedImage)
    axis xy
    title(['Channel' '_' num2str(i)],'Interpreter','none')
    c = colorbar;
    title(c,'% Change')
    colormap('jet')
    xticks([101:200:2001]);
    xticklabels([-0.400:0.200:1.500]);
    yticks([1:3:57])
    yticklabels(FrequenciesOfInterest(1:3:57));
    xlabel('Time(s)')
    ylabel('Frequency(Hz)')
    set(gca,'FontSize',25)
    set(gcf,'position',[100 100 1100 800])
    line([501 501],[0 57],'Color','w','LineStyle','--','LineWidth',4)
    print([ 'Channel' '_' num2str(i)],'-dpng')
    close
end



% For anticorrelation pre and post stimulus
D_Epoched_Trace = spm_eeg_load();
Channel1 = 8;
Channel2 = 21;
Traces1 = squeeze(D_Epoched_Trace(Channel1,:,:));
Traces2 = squeeze(D_Epoched_Trace(Channel2,:,:));

for i = 1:40
    [r1(i), p1(i)] = corr(Traces1(1:700,i),Traces2(1:700,i));
    [r2(i), p2(i)] = corr(Traces1(701:1401,i),Traces2(701:1401,i));
end

% for R dataframe and plot
RDataFrame  = [r1';r2'];
RDataFrame2 = [ones(40,1);ones(40,1)*2];
RDataFrame  = [RDataFrame,RDataFrame2];
csvwrite('AntiCorrR.txt',RDataFrame)



