%% Pipeline script for emotional faces

% % Add path
% % addpath(genpath('C:\Users\THIENC\Desktop\EmotionalFaces'))
% addpath(genpath('D:\EmotionalFaces'))
clear
% path manipulation
[ScriptFolder,SubjectFolder] = PathManipulation('BaotianZ620');

% ScriptFolder = 'D:\EmotionalFaces';
cd(ScriptFolder)

% SubjectFolder = 'E:\';
cd(SubjectFolder)

cd('E:\EmotionalFaces')
% load the combined data
D = spm_eeg_load();

for j = 1:2%:D.nchannels
    figure
    for i = 1:D.ntrials
        condition = D.condlist;
            if strcmp(D.conditions{i},'happy')
                Data = squeeze(D(j,:,i));
                plot(D.time,Data,'Color',[255 192 159]/255,'LineWidth',0.1);
                hold on
            elseif strcmp(D.conditions{i},'neutral')
                Data = squeeze(D(j,:,i));
                plot(D.time,Data,'Color',[0.5 0.5 0.5],'LineWidth',0.1);
                hold on
            elseif strcmp(D.conditions{i},'angry')
                Data = squeeze(D(j,:,i));
                plot(D.time,Data,'Color',[27 152 224]/255,'LineWidth',0.1);
                hold on
            end
    end
    title(D.chanlabels{j})
    axis tight
    grid on
end

Data = squeeze(D(1,:,:));
KmeanInd = kmeans(Data(700:2000,:)',3);

conditions = D.conditions';