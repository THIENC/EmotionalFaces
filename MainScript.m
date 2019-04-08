% Pipeline script for emotional faces
% Add SPM
addpath('D:\³ÌÐò\spm12_7219\spm12_7219');
spm('defaults', 'EEG');
% Add path
addpath(genpath('C:\Users\Leron Zhang\Documents\GitHub\EmotionalFaces'))
% path manipulation
clear
ScriptFolder = 'C:\Users\Leron Zhang\Documents\GitHub\EmotionalFaces';
cd(ScriptFolder)

SubjectFolder = 'C:\Users\Leron Zhang\Desktop\PT050_Emotional_Faces';
cd(SubjectFolder)

%% File IO
% load the raw edf data and convert it to SPM format
D = edf_TO_SPM_converter_GUI([],[],'meeg_');

% load and convert the DC channel
DC = edf_TO_SPM_converter_GUI([],[],'DC_');

%% Channel Rename
Channel_Renaming_UI
pause
DC = spm_eeg_load();
D = spm_eeg_load();
%% Downsampling
% Downsample the data to 1000 if > 1000Hz
if D.fsample > 1003
    clear S
    S.D = D;
    S.fsample_new = 1000;
    D = spm_eeg_downsample(S);
end
if DC.fsample > 1003
    clear S
    S.D = DC;
    S.fsample_new = 1000;
    DC = spm_eeg_downsample(S);
end

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
%% Bad channel detection
D = LBCN_filter_badchans_China();
D = D{1,1};

%% Common average rereference
AverageChannels = [1:D.nchannels];
BadChannelInd = D.badchannels;
AverageChannels(BadChannelInd) = [];
[D,montage_file] = SPM_Manual_Montage(D,'AvgM',AverageChannels);
% label bad channel
D = D.badchannels([BadChannelInd],1);
save(D)
%% Epoch
timeStampNew = FindCCEPTriggers(DC);
timeStampNew = timeStampNew(2:3:90);
% Compare the triggers with Behavioral data

% define the trl
for i = 1:length(timeStampNew)
    trl(i,1) = timeStampNew(i)*DC.fsample - 700;
    trl(i,2) = timeStampNew(i)*DC.fsample + 1500;
    trl(i,3) = -700;
end


load('PT050_WAQIEmotionalFacesBlock1.mat')
TagsRaw = orderData(2:3:90)';
for i = 1:30
    if contains(TagsRaw{i},'angry','IgnoreCase',true)
        TagsNew{i} = 'angry';
    elseif contains(TagsRaw{i},'happy','IgnoreCase',true)
        TagsNew{i} = 'happy';
    elseif contains(TagsRaw{i},'neutral','IgnoreCase',true)
        TagsNew{i} = 'neutral';
    end
end

clear S
S.D = D;
S.bc = 1;
S.trl = trl;
S.prefix = 'e';
S.conditionlabels = TagsNew';
D = spm_eeg_epochs(S);
%% Define bad trials

%% Time Frequency decomposition
clear S 
S.D                 = D;
S.channels          = 'All';     
S.frequencies       = [1:10, 11:2:20, 21:3:40, 41:4:70, 70:5:200];
S.method            = 'morlet'; 
S.phase             = 0;      
S.prefix            = 'tf_'; 
D = spm_eeg_tf(S);


%% Crop before the TF rescale
clear S 
S.D = D;
S.timewin = [-600 1400];
D = spm_eeg_crop(S);

%% Rescale the raw TF map
clear S 
S.D            = D;
S.method       = 'Rel';
S.timewin      = [-600 0];

D = spm_eeg_tf_rescale(S);

FinalTaskEEGTF = D(:,:,:,:);
FinalTaskEEGTFMeanEpoch = squeeze(mean(FinalTaskEEGTF,4));
% save('EmotionalFaces1Final.mat','FinalTaskEEGTF')

% Smooth the TF map before plot
% Selected Channel to plot
FrequenciesOfInterest = [1:10, 11:2:20, 21:3:40, 41:4:70, 70:5:200];
for i = 1:D.nchannels
    figure
    SmoothedImage = imgaussfilt(squeeze(FinalTaskEEGTFMeanEpoch(i,:,:)),[1,20]);
    imagesc(SmoothedImage)
    axis xy
    title(['Channel' '_' D.chanlabels{i}],'Interpreter','none')
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
    print([ 'Channel' '_' D.chanlabels{i}],'-dpng')
    close
end













