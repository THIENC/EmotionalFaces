
happy = zeros(size(D.trials));
angry = zeros(size(D.trials));
neutral = zeros(size(D.trials));
for i = 1:size(D.trials,2)
    if contains(D.trials(i).label,'happy')
        happy(i) = 1;
    elseif contains(D.trials(i).label,'angry')
        angry(i) = 1;
    elseif contains(D.trials(i).label,'neutral')
        neutral(i) = 1;
    end
end
Amyg = 2;

D = meeg(D);
happyInd = find(happy);
happyData = D(Amyg,:,happyInd);
angryData = D(Amyg,:,[find(angry)]);
neutralData = D(Amyg,:,[find(neutral)]);
Happy = squeeze(happyData);
Angry = squeeze(angryData);
Neutral = squeeze(neutralData);


options.handle     = figure(1);
options.color_area = [128 193 219]./255;    % Blue theme
options.color_line = [ 52 148 186]./255;
%options.color_area = [243 169 114]./255;    % Orange theme
%options.color_line = [236 112  22]./255;
options.alpha      = 0.5;
options.line_width = 3;
options.error      = 'sem';
plot_areaerrorbar(Happy',options)
hold on
options.handle     = figure(1);
% options.color_area = [128 193 219]./255;    % Blue theme
% options.color_line = [ 52 148 186]./255;
options.color_area = [243 169 114]./255;    % Orange theme
options.color_line = [236 112  22]./255;
options.alpha      = 0.5;
options.line_width = 3;
options.error      = 'sem';
plot_areaerrorbar(Neutral',options)
hold on
options.handle     = figure(1);
% options.color_area = [128 193 219]./255;    % Blue theme
% options.color_line = [ 52 148 186]./255;
% options.color_area = [243 169 114]./255;    % Orange theme
% options.color_line = [236 112  22]./255;
options.color_area = [255 200 200]./255;   % yellow theme 
options.color_line = [255 200 22]./255;
options.alpha      = 0.5;
options.line_width = 3;
options.error      = 'sem';
plot_areaerrorbar(Angry',options)
axis tight
grid on