script merge
clear
% fname = dir('C:\Users\Leron Zhang\Desktop\PT050_EmotionnalFaces_meeg');
% fname = {fname(3:end).name};
% K1 = spm_eeg_load();
S.recode = 'same';
S.prefix = 'c';
fname1 = 'C:\Users\Leron Zhang\Desktop\PT050_EmotionnalFaces_meeg\meeg_Emotionnal_Faces_1.mat';
S(1).D = fname1;
% K2 = spm_eeg_load();
fname2 = 'C:\Users\Leron Zhang\Desktop\PT050_EmotionnalFaces_meeg\meeg_Emotionnal_Faces_2.mat';
S(2).D = fname2;
M = spm_eeg_merge(S);
