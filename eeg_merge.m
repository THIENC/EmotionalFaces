script merge
clear
% fname = dir('C:\Users\Leron Zhang\Desktop\PT050_EmotionnalFaces_meeg');
% fname = {fname(3:end).name};
% K1 = spm_eeg_load();
S.recode = 'same';
S.prefix = 'c';
efile{1} = 'eAvgMffffdmeeg_Emotionnal_Faces_1.mat';

% K2 = spm_eeg_load();
efile{2} = 'eAvgMffffdmeeg_Emotionnal_Faces_2.mat';
efile{3} = 'eAvgMffffdmeeg_Emotionnal_Faces_3.mat'
S.D = char(efile);
M = spm_eeg_merge(S);
