%
clear
PatientList = [32,33,35,37:40,42:47];
IndexInUse = struct;
cd('E:\EmotionalFaces')
MainDir = dir('*0*');
for i = 1:length(PatientList)
    for j = 1:length(MainDir)
    if contains(MainDir(j).name,['0' num2str(PatientList(i))])
        cd(MainDir(j).name)
        %% for channels
        [filename, path] = uigetfile('*.edf','Please select edf file to convert');
        % read edf header using function in field trip
        edf_header = ft_read_header(filename);
        [index_to_keep,~] = listdlg('ListString',edf_header.label,'PromptString','Select Channels to Keep' );
        IndexInUse = index_to_keep;
         %% for DC channels
        [filename, path] = uigetfile('*.edf','Please select edf file to convert');
        % read edf header using function in field trip
        edf_header = ft_read_header(filename);
        [index_to_keep,~] = listdlg('ListString',edf_header.label,'PromptString','Select Channels to Keep' );
        DCChannel = index_to_keep;
        
        %% write 
        IndexInUse(i).ID = ['PT0' num2str(PatientList(i))];
        IndexInUse(i).Channels = [ChannelIndex];
        IndexInUse(i).DCChannel = [DCChannel];
        cd ..
        cd ..
    end
    end
end
    save('EmotionalFacesChannels.mat','IndexInUse');
