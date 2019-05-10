data = h.iEEG_MEEG{1}(:,1000:2500,2:2:216);


for chan = 2
    figure
for i = 1:size(data,3)
    plot(data(chan,:,i),'Color',[0.5 0.5 0.5],'LineWidth',0.1);
    hold on
end
end


options.handle     = figure(2);
options.color_area = [128 193 219]./255;    % Blue theme
options.color_line = [ 52 148 186]./255;
%options.color_area = [243 169 114]./255;    % Orange theme
%options.color_line = [236 112  22]./255;
options.alpha      = 0.5;
options.line_width = 3;
options.error      = 'std';
plot_areaerrorbar(squeeze(data(2,:,:))',options)
hold on
options.handle     = figure(2);
% options.color_area = [128 193 219]./255;    % Blue theme
% options.color_line = [ 52 148 186]./255;
options.color_area = [243 169 114]./255;    % Orange theme
options.color_line = [236 112  22]./255;
options.alpha      = 0.5;
options.line_width = 3;
options.error      = 'std';
plot_areaerrorbar(squeeze(data(2,:,1:54))',options)
axis tight
grid on
