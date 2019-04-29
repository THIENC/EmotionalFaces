%% Pipeline script for emotional faces

% Add SPM

% addpath('C:\Users\THIENC\Desktop\spm12_7219');
addpath('D:\spm12_7219');
spm('defaults', 'EEG');

% Add path
% addpath(genpath('C:\Users\THIENC\Desktop\EmotionalFaces'))
addpath(genpath('D:\EmotionalFaces'))

% path manipulation

clear

ScriptFolder = 'D:\EmotionalFaces';
cd(ScriptFolder)

SubjectFolder = 'E:\EmotionalFaces';
cd(SubjectFolder)

PatientList = [32,33,35,37:47];
% % Move the edf files to the analysis folder
% for i = 1:length(PatientList)
%     cd('T:\')
%     MainDir = dir('*0*');
%     for j = 1:length(MainDir)
%         if contains(MainDir(j).name,['0' num2str(PatientList(i))])
%             mkdir(['E:\EmotionalFaces\' 'PT0' num2str(PatientList(i))])
%             cd(MainDir(j).name)
%             ECoGDir = dir('*ECoG');
%             cd(ECoGDir.name)
%             EmotionalDir = dir('Emotional*');
%             cd(EmotionalDir.name)
%             copyfile('*.edf',['E:\EmotionalFaces\' 'PT0' num2str(PatientList(i))])
%             cd ..
%             cd ..
%             cd ..
%         end
%     end
% end

% % Move the mat files to the analysis folder
% for i = 1:length(PatientList)
%     cd('T:\')
%     MainDir = dir('*0*');
%     for j = 1:length(MainDir)
%         if contains(MainDir(j).name,['0' num2str(PatientList(i))])
%             cd(MainDir(j).name)
%             ECoGDir = dir('*Behavioral');
%             cd(ECoGDir.name)
%             EmotionalDir = dir('Emotional*');
%             cd(EmotionalDir.name)
%             copyfile('*.mat',['E:\EmotionalFaces\' 'PT0' num2str(PatientList(i))])
%             cd ..
%             cd ..
%             cd ..
%         end
%     end
% end
cd('E:\EmotionalFaces')
EmotionalDir = dir(pwd);
EmotionalDir = EmotionalDir(3:end);
%% File IO
for i = 1:length(EmotionalDir)
    cd(EmotionalDir(i).name)
    edfFiles = dir('*.edf');
    BehaviorData = dir('*.mat');
    index = [1:142];
    for loops = 1:length(edfFiles)
        
        % load the raw edf data and convert it to SPM format
        [D,IndexInUse] = edf_TO_SPM_converter_GUI(edfFiles(loops).name,[[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141]],'meeg_');
        
        % load and convert the DC channel
        loc_DC = index(41);
        spm('defaults', 'EEG');
        DC = edf_TO_SPM_converter_GUI(edfFiles(loops).name,loc_DC,'DC_');
        
        %% Channel Rename
        % Channel_Renaming_UI
        % pause
        % D = spm_eeg_load();
        % DC = spm_eeg_load();
        Channel_Labels_Raw = D.chanlabels';
        
        Channel_Labels_New = Deblank_Names(Channel_Labels_Raw);
        
        Pattern = '-Ref';
        Channel_Labels_New = Remove_Name_Pattern(Channel_Labels_New,Pattern);
        
        Channel_Labels_New = cellfun(@(x) x(3+1:end),Channel_Labels_New,'UniformOutput',false);
        
        D = struct(D);
        for j = 1:length(Channel_Labels_New)
            D.channels(j).label = Channel_Labels_New{j};
        end
        D = meeg(D);
        save(D);
        
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
        D = LBCN_filter_badchans_China(['ffffdmeeg_Emotional_Faces_' num2str(loops) '.mat'],[],[],[],[]);
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
        timeStampDC = FindCCEPTriggers(DC);
        timeStampDC = timeStampDC(2:3:90); %find timeonsets of each trials from Emotional_Faces
        % Compare the DC triggers with Behavioral data
        
        pause
        TheData = orderData(2:3:90,2);
        timeStampBehaviorRaw = zeros(1,length(TheData));
        for ii = 1:length(TheData)
            timeStampBehaviorRaw(1,ii) = TheData{ii,1}.StimulusOnsetTime;
        end
        timeStampBehaviorNew = (timeStampBehaviorRaw - timeStampBehaviorRaw(1))';
        timeStampDCNew = timeStampDC - timeStampDC(1);
        figure
        plot(timeStampDCNew,'o','MarkerSize',8,'LineWidth',3)
        hold on
        plot(timeStampBehaviorNew,'r*')
        diff = timeStampDCNew - timeStampBehaviorNew;
        if ~all(abs(diff) < 0.01)
            error('Behavioral timestamp  and DC timestamp mismatch')
        end
        
        % define the trl
        for i = 1:length(timeStampDC)
            trl(i,1) = timeStampDC(i)*DC.fsample - 700;
            trl(i,2) = timeStampDC(i)*DC.fsample + 1500;
            trl(i,3) = -700;
        end
        
        % Define Lables
        TagsRaw = orderData(2:3:90)';
        for i = 1:length(TagsRaw)
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
        save(D)
    end
    
    %% EEG merge
    efile = cell(length(edfFiles),1);
    for i = 1:length(edfFiles)
        efile{i} = ['eAvgMffffdmeeg_Emotional_Faces_' num2str(i) '.mat'];
    end
    S.D = char(efile);
    S.recode = 'same';
    S.prefix = 'c';
    D = spm_eeg_merge(S);
    save(D)
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
        print([ 'tf_Channel' '_' D.chanlabels{i}],'-dpng')
        close
    end
end