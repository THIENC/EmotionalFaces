%% plot ERP for each channel based on three kinds of conditions（happy，angry，neutral）
% add path
addpath(genpath('F:\EmotionalFaces'))
ERPDir = dir('F:\EmotionalFaces');
ERPDir = ERPDir(3:end);
% loop for each subject
for sub = 1:length(ERPDir)
    cd(ERPDir(sub).name)
    path = pwd;  %指定当前文件夹
    disp_filename=dir([path,'\ce*.mat']); %读取指定的文件名，前缀是ce,后缀为.mat的文件
    D = load([path,'\',disp_filename.name]);
    % find three different conditions
    happy = zeros(size(D.D.trials));
    angry = zeros(size(D.D.trials));
    neutral = zeros(size(D.D.trials));
  for i = 1:size(D.D.trials,2)
    if contains(D.D.trials(i).label,'happy')
        happy(i) = 1;
    elseif contains(D.D.trials(i).label,'angry')
        angry(i) = 1;
    elseif contains(D.D.trials(i).label,'neutral')
        neutral(i) = 1;
    end
  end
  % loop for each channel
   for i = 1:length(D.D.channels)

       d = meeg(D.D);
      
       happyData = d(i,:,[find(happy)]);
       angryData = d(i,:,[find(angry)]);
       neutralData = d(i,:,[find(neutral)]);
       Happy = squeeze(happyData);
       Angry = squeeze(angryData);
       Neutral = squeeze(neutralData);
       
       % plot ERP for three conditions in one figure
       % blue for happy,yellow for angry,red for neutral
       options.handle     = figure(sub);
       options.color_area = [128 193 219]./255;    % Blue theme
       options.color_line = [ 52 148 186]./255;
       %options.color_area = [243 169 114]./255;    % red theme
       %options.color_line = [236 112  22]./255;
       options.alpha      = 0.5;
       options.line_width = 3;
       options.error      = 'sem';
       plot_areaerrorbar(Happy',options);
       hold on
       options.handle     = figure(sub);
       % options.color_area = [128 193 219]./255;    % Blue theme
       % options.color_line = [ 52 148 186]./255;
       options.color_area = [243 169 114]./255;    % red theme
       options.color_line = [236 22  22]./255;
       options.alpha      = 0.5;
       options.line_width = 3;
       options.error      = 'sem';
       plot_areaerrorbar(Neutral',options)
       hold on
       options.handle     = figure(sub);
       % options.color_area = [128 193 219]./255;    % Blue theme
       % options.color_line = [ 52 148 186]./255;
       % options.color_area = [243 169 114]./255;    % red theme
       % options.color_line = [236 112  22]./255;
       options.color_area = [255 250 100]./255;   % yellow theme
       options.color_line = [250 200 22]./255;
       options.alpha      = 0.5;
       options.line_width = 3;
       options.error      = 'sem';
       plot_areaerrorbar(Angry',options)
       line([601 601],[-150 150],'Color','b','LineStyle','--','LineWidth',2)
       axis tight
       grid on
       title(['Channel' '_' d.chanlabels{i}])
       xlabel('Time(s)')
       ylabel('Amplitude(μV)')
       legend({'','happy','','neutral','','angry'})
       cd('figs')
       print([ 'ERP_Channel' '_' d.chanlabels{i}],'-dpng')
       close
       cd ..
   end
   cd ..
end