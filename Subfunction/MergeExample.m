%% Pipeline for post reprocessing of each run of CPT
% global globalECoGDir;
globalECoGDir = 'C:\Users\Leron Zhang\Desktop\PT050_EmotionnalFaces_meeg';
Patient_IDs = dir(globalECoGDir);
Patient_IDs = {Patient_IDs(3:end).name}';
for sub = 1:11
    %% Make new directory for merged runs
    cd([globalECoGDir '\' Patient_IDs{sub}]);
    mkdir('mRun1_2');
    %% combine the rtf files 
    for condition = 1:3
        for runs = 1:2
            runname = ['Run' num2str(runs)];
            % Merge files and save
            cd(runname);
            rtf = dir('rtf_*.mat');
            rtf = {rtf.name};
            % fname for each condition
            fname = rtf{condition};
            D=spm_eeg_load(fname);
            fname = D.fullfile;
            datfname=fname; datfname(end-2)='d';
            cd ..
            cd('mRun1_2');
            copyfile(fname); copyfile(datfname);
            efile{runs}=D.fname;
            cd ..
        end
        cd ('mRun1_2')
        S.D=char(efile);
        S.recode='same';
        S.prefix='mRun1_2';
        D=spm_eeg_merge(S);
        % change the condition labels
        if condition == 1
            Change_CEs_Labels(D)
        elseif condition == 2
            Change_Cities_Labels(D)
        elseif condition == 3
            Change_mountains_Labels(D)
        end
        % plot the TFmap for combined file: only for the mountains
        if condition == 3
            fname = dir('mRun1_2rtf_aeMountMfff*.mat');
            fname = fname.name;
            D = spm_eeg_load(fname);
            TFmap_All_Freq(D);
            TFmap_Above_Alpha(D);
        end
        cd ..
    end
    %% combine the HighGamma files
    for condition = 1:3
        for runs = 1:2
            runname = ['Run' num2str(runs)];
            % Merge files and save
            cd(runname);
            HighGamma  = dir('HighGamma*.mat');
            HighGamma  = {HighGamma.name};
            % fname for each condition
            fname = HighGamma{condition};
            D=spm_eeg_load(fname);
            fname = D.fullfile;
            datfname=fname; datfname(end-2)='d';
            cd ..
            cd('mRun1_2');
            copyfile(fname); copyfile(datfname);
            efile{runs}=D.fname;
            cd ..
        end
        cd ('mRun1_2')
        S.D=strvcat(efile);
        S.recode='same';
        S.prefix='mRun1_2';
        D=spm_eeg_merge(S);
        % change the condition labels
        if condition == 1
            Change_CEs_Labels(D)
        elseif condition == 2
            Change_Cities_Labels(D)
        elseif condition == 3
            Change_mountains_Labels(D)
        end
        cd ..
    end
    %% combine the SHighGamma files
    for condition = 1:3
        for runs = 1:2
            runname = ['Run' num2str(runs)];
            % Merge files and save
            cd(runname);
            SHighGamma = dir('SHighGamma*.mat');
            SHighGamma = {SHighGamma.name};
            % fname for each condition
            fname = SHighGamma{condition};
            D=spm_eeg_load(fname);
            fname = D.fullfile;
            datfname=fname; datfname(end-2)='d';
            cd ..
            cd('mRun1_2');
            copyfile(fname); copyfile(datfname);
            efile{runs}=D.fname;
            cd ..
        end
        cd ('mRun1_2')
        S.D=strvcat(efile);
        S.recode='same';
        S.prefix='mRun1_2';
        D=spm_eeg_merge(S);
        % change the condition labels
        if condition == 1
            Change_CEs_Labels(D)
        elseif condition == 2
            Change_Cities_Labels(D)
        elseif condition == 3
            Change_mountains_Labels(D)
        end
        % plot the smoothed data
        if condition == 1 
            fname = dir('mRun1_2SHighGammartf_aeCEsMfff*.mat');
            fname = fname.name;
            D = spm_eeg_load(fname);
        labs = D.condlist;
        colors = colormap(lines(length(labs)-1));
        LBCN_plot_averaged_signal_epochs_gradCPT_HFB(D.fname,[],[],[-1500 1500],1,'CEs',[[200 10 150]/255; colors],Patient_IDs{sub});
        close('all')
        elseif condition == 2 
            fname = dir('mRun1_2SHighGammartf_aeCitiesMfff*.mat');
            fname = fname.name;
            D = spm_eeg_load(fname);
        labs = D.condlist;
        colors = colormap(lines(length(labs)-1));
        LBCN_plot_averaged_signal_epochs_gradCPT_HFB(D.fname,[],[],[-600 1900],1,'Cities',[[200 10 150]/255; colors],Patient_IDs{sub});
        close('all')
        elseif condition == 3
            fname = dir('mRun1_2SHighGammartf_aeMountMfff*.mat');
            fname = fname.name;
            D = spm_eeg_load(fname);
        labs = D.condlist;
        colors = colormap(lines(length(labs)-1));
        LBCN_plot_averaged_signal_epochs_gradCPT_HFB(D.fname,[],[],[-800 1500],1,'mountains',[[200 10 150]/255; colors],Patient_IDs{sub});
        close('all');
        end
        cd ..
    end
end