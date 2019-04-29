%EmostionalFacesChannels index
clear
[D,ChannelIndex] = edf_TO_SPM_converter_GUI();
[D,DCChannel] = edf_TO_SPM_converter_GUI();


IndexInUse = struct;
IndexInUse(1).ID = 'PT041';
IndexInUse(1).Channels = [ChannelIndex];
IndexInUse(1).DCChannel = [DCChannel];

save('EmotionalFacesChannels.mat','IndexInUse');