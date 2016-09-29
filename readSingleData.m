s = csvread('ambiantLighttest@100ms-iter-00001-step-01-acq-00001.csv');
x = s(:,1);
y = s(:,2);
disp('the length of y is: ');

%%graph all the intensities in a single graph 
figure(1);
plot(x,y);