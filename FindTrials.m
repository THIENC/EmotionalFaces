%% Find trials in different conditions 

happy = zeros(1,size(FinalTaskEEGTF,4));
angry = zeros(1,size(FinalTaskEEGTF,4));
neutral = zeros(1,size(FinalTaskEEGTF,4));
for i = 1:size(FinalTaskEEGTF,4)
    if contains(d.trials(i).label,'happy')
        happy(i) = 1;
    elseif contains(d.trials(i).label,'angry')
        angry(i) = 1;
    elseif contains(d.trials(i).label,'neutral')
        neutral(i) = 1;
    end
end


clear S
S.happy = FinalTaskEEGTF(:,:,:,[find(happy)]);
S.angry = FinalTaskEEGTF(:,:,:,[find(angry)]);
S.neutral = FinalTaskEEGTF(:,:,:,[find(neutral)]);
%%plot shade error bar
for j = 1:size(FinalTaskEEGTF,1)
%plot happy trial on the high frequency

PowertoPlot_happy = [];
for i = 1:size(FinalTaskEEGTF,4)/3 % three kinds of trials
Happy = squeeze(S.happy(j,:,:,i));
HighFrequency_happy = Happy([31:57],:);%FrequenciesOfInterest=[1:10, 11:2:20, 21:3:40, 41:4:70, 70:5:200] %High frequency band=[70:5:200]
MeanPower_happy = mean(HighFrequency_happy,1);
PowertoPlot_happy = [PowertoPlot_happy;MeanPower_happy];
end

%plot angry trial on the high frequency

PowertoPlot_angry = [];
for i = 1:10
Angry = squeeze(S.angry(j,:,:,i));
HighFrequency_angry = Angry([31:57],:);
MeanPower_angry = mean(HighFrequency_angry,1);
PowertoPlot_angry = [PowertoPlot_angry;MeanPower_angry];
end

%plot neutral trial on the high frequency

PowertoPlot_neutral = [];
for i = 1:10
Neutral = squeeze(S.neutral(j,:,:,i));
HighFrequency_neutral = Neutral([31:57],:);
MeanPower_neutral = mean(HighFrequency_neutral,1);
PowertoPlot_neutral = [PowertoPlot_neutral;MeanPower_neutral];
end

% shade error bar
figure
shadedErrorBar([],PowertoPlot_happy,{@median,@std},{'r-o','markerfacecolor','r'});
hold on
shadedErrorBar([],PowertoPlot_angry,{@median,@std},{'b-*','markerfacecolor','b'}); 
hold on
shadedErrorBar([],PowertoPlot_neutral,{@median,@std},{'g-.','markerfacecolor','g'}); 
end
