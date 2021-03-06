%% Pipeline script for emotional faces

clear
% path manipulation
[ScriptFolder,SubjectFolder] = PathManipulation('Ziqing');

%create index
CreateIndexInUse

% ScriptFolder = 'D:\EmotionalFaces';
cd(ScriptFolder)

% SubjectFolder = 'E:\';
cd(SubjectFolder)

load('EmotionalFacesChannels.mat')
% cd('EmotionalFaces')
EmotionalDir = dir(pwd);
EmotionalDir = EmotionalDir(4:end);

%% File IO
for Sub = 1
    cd(EmotionalDir(Sub).name)
    edfFiles = dir('*.edf');
    BehaviorData = dir('*0*.mat');
    clear FileCombine;
    for loops = 1:length(edfFiles)
        
        % load the raw edf data and convert it to SPM format
        [D,Index] = edf_TO_SPM_converter_GUI(edfFiles(loops).name,IndexInUse(Sub).Channels,'meeg_');
        
        % load and convert the DC channel
        [DC,Index] = edf_TO_SPM_converter_GUI(edfFiles(loops).name,IndexInUse(Sub).DCChannel,'DC_');
               
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
        D = LBCN_filter_badchans_China(D.fname,[],[],[],[]);
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
        mkdir('figs')
        cd('figs')
        timeStampDC = FindCCEPTriggers(DC);
        timeStampDC = timeStampDC(2:3:90); %find timeonsets of each trials from Emotional_Faces
        cd ..
        % Compare the DC triggers with Behavioral data
        
        load(BehaviorData(loops).name);
        TheData = orderData(2:3:90,2);
        timeStampBehaviorRaw = zeros(1,length(TheData));
        for ii = 1:length(TheData)
            timeStampBehaviorRaw(1,ii) = TheData{ii,1}.StimulusOnsetTime;
        end
        timeStampBehaviorNew = (timeStampBehaviorRaw - timeStampBehaviorRaw(1))';
        timeStampDCNew = timeStampDC - timeStampDC(1);
        cd('figs')
        figure
        plot(diff(timeStampDCNew),'o','MarkerSize',8,'LineWidth',3)
        hold on
        plot(diff(timeStampBehaviorNew),'r*')
        difference = timeStampDCNew - timeStampBehaviorNew;
        print(['Behavioral_DC_' num2str(loops)],'-dpng')
        if ~all(abs(difference) < 0.01)
            error('Behavioral timestamp and DC timestamp mismatch')
        end
        cd ..
        
        % define the trl
        for i = 1:length(timeStampDC)
            trl(i,1) = timeStampDC(i)*DC.fsample - 600;
            trl(i,2) = timeStampDC(i)*DC.fsample + 1600;
            trl(i,3) = -600;
        end
        
        % Define Labels
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
        % For EEG merge
               
        FileCombine(loops,:) = D.fname;
    end
    
    %% EEG merge
    clear S
    S.D = FileCombine;
    S.recode = 'same';
    S.prefix = 'c';
    D = spm_eeg_merge(S);
    save(D)
    %% Time Frequency decomposition
    clear S
    S.D                 = D;
    S.channels          = 'All';
    % S.frequencies       = [1:10, 11:2:20, 21:3:40, 41:4:70, 70:5:200]; %
    % for finer frequency resolution
    S.frequencies       = [1:10, 11:2:20, 21:5:40, 41:10:70, 70:10:200]; % For faster speed
    S.method            = 'morlet';
    S.phase             = 0;
    S.prefix            = [];
    D = spm_eeg_tf(S);
    
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
    
    FinalTaskEEGTF = D(:,:,:,:);
    FinalTaskEEGTFMeanEpoch = squeeze(mean(FinalTaskEEGTF,4));
    % save('EmotionalFaces1Final.mat','FinalTaskEEGTF')
    
    % Smooth the TF map before plot
    % Selected Channel to plot
    % FrequenciesOfInterest = [1:10, 11:2:20, 21:3:40, 41:4:70, 70:5:200];
    cd('figs')
    FrequenciesOfInterest = [1:10, 11:2:20, 21:5:40, 41:10:70, 70:10:200];
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
        yticks([1:3:36])
        yticklabels(FrequenciesOfInterest(1:3:36));
        xlabel('Time(s)')
        ylabel('Frequency(Hz)')
        set(gca,'FontSize',25)
        set(gcf,'position',[100 100 1100 800])
        line([501 501],[0 36],'Color','w','LineStyle','--','LineWidth',4)
        print([ 'tf_Channel' '_' D.chanlabels{i}],'-dpng')
        close
    end
    cd ..
    cd ..
end
