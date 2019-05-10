function  [ScriptFolder,SubjectFolder] = PathManipulation(User)
%PATHMANIPULATION Summary of this function goes here
%   Detailed explanation goes here
switch User
    case 'BaotianMacmini'
        % Add SPM
       
        addpath('/Users/Baotian/Desktop/ToolBoxes/spm12');
        spm('defaults', 'EEG');
        
        % Add path
        % addpath(genpath('C:\Users\THIENC\Desktop\EmotionalFaces'))
        addpath(genpath('/Users/Baotian/Desktop/ToolBoxes/EmotionalFaces'))
        ScriptFolder = '/Users/Baotian/Desktop/ToolBoxes/EmotionalFaces';
        SubjectFolder = '/Users/Baotian/Desktop/Data/EmotionalFaces/PT050';
    case 'BaotianZ620'
        % Add SPM
        
        addpath('D:\spm12_7219');
        spm('defaults', 'EEG');
        
        % Add path
        % addpath(genpath('C:\Users\THIENC\Desktop\EmotionalFaces'))
        addpath(genpath('D:\EmotionalFaces'))
        ScriptFolder = 'D:\EmotionalFaces';
        SubjectFolder = 'E:\';
    case 'Ziqing'
        % Add SPM
        
        addpath('D:\³ÌÐò\spm12_7219\spm12_7219');
        spm('defaults', 'EEG');
        
        % Add path
        
        addpath(genpath('D:\GitHub\EmotionalFaces'))
        addpath(genpath('D:\EmotionalFaces_preprocessing_data'))
        ScriptFolder = 'D:\GitHub\EmotionalFaces';
        SubjectFolder = 'D:\EmotionalFaces_preprocessing_data';
end

end

