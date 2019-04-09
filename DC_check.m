% Compare the DC triggers with Behavioral data
load('PT050_WAQIEmotionalFacesBlock1.mat');
TheData = orderData(2:3:90,2);
timeStampBehaviorRaw = zeros(1,length(TheData));
for ii = 1:length(TheData)
    timeStampBehaviorRaw(1,ii) = TheData{ii,1}.StimulusOnsetTime;
end
timeStampBehaviorNew = (timeStampBehaviorRaw - timeStampBehaviorRaw(1))';
timeStampDCNew = timeStampDC - timeStampDC(1);
figure
plot(timeStampDCNew,'o','MarkerSize',8,'LineWidth',3)
hold on 
plot(timeStampBehaviorNew,'r*')
diff = timeStampDCNew - timeStampBehaviorNew;
if ~all(abs(diff) < 0.01)
    error('Behavioral timestamp  and DC timestamp mismatch')
end