PatientList = [32,33,35,37:47];
% Move the edf files to the analysis folder
for i = 1:length(PatientList)
    cd('T:\')
    MainDir = dir('*0*');
    for j = 1:length(MainDir)
        if contains(MainDir(j).name,['0' num2str(PatientList(i))])
            mkdir(['E:\EmotionalFaces\' 'PT0' num2str(PatientList(i))])
            cd(MainDir(j).name)
            ECoGDir = dir('*ECoG');
            cd(ECoGDir.name)
            EmotionalDir = dir('Emotional*');
            cd(EmotionalDir.name)
            copyfile('*.edf',['E:\EmotionalFaces\' 'PT0' num2str(PatientList(i))])
            cd ..
            cd ..
            cd ..
        end
    end
end

% Move the mat files to the analysis folder
for i = 1:length(PatientList)
    cd('T:\')
    MainDir = dir('*0*');
    for j = 1:length(MainDir)
        if contains(MainDir(j).name,['0' num2str(PatientList(i))])
            cd(MainDir(j).name)
            ECoGDir = dir('*Behavioral');
            cd(ECoGDir.name)
            EmotionalDir = dir('Emotional*');
            cd(EmotionalDir.name)
            copyfile('*.mat',['E:\EmotionalFaces\' 'PT0' num2str(PatientList(i))])
            cd ..
            cd ..
            cd ..
        end
    end
end