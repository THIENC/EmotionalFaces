%
clear
PatientList = [32,33,35,37:40,42:47];
IndexInUse = struct;
cd('E:\')
MainDir = dir('*0*');
for i = 1:length(PatientList)
    for j = 1:length(MainDir)
    if contains(MainDir(j).name,['0' num2str(PatientList(i))])
        cd(MainDir(j).name)
        ECoGDir = dir('*ECoG');
        cd(ECoGDir.name)
        EmotionalDir = dir('Emotional*');
        cd(EmotionalDir.name)
        [~,ChannelIndex] = edf_TO_SPM_converter_GUI();
        [~,DCChannel] = edf_TO_SPM_converter_GUI();
        IndexInUse(i).ID = ['PT0' num2str(PatientList(i))];
        IndexInUse(i).Channels = [ChannelIndex];
        IndexInUse(i).DCChannel = [DCChannel];
        cd ..
        cd ..
    end
    end
end
    save('EmotionalFacesChannels.mat','IndexInUse');
