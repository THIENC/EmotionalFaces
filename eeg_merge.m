script merge
clear S
efile{2} = 'eAvgMffffdmeeg_Emotionnal_Faces_2.mat';
efile{3} = 'eAvgMffffdmeeg_Emotionnal_Faces_3.mat';
efile = efile';
S.D = char(efile);
S.recode = 'same';
S.prefix = 'c';
spm_eeg_merge(S);
D_c = spm_eeg_load();