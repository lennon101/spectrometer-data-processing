close all;
clear;
clc;
%% main globals
mainDataFileName = '27-09-2016_14|16|13 3deg@300ms 2nd trial.csv';
whiteFileName = 'white500.csv';
whiteIntegTimesFileName = 'white500_integ_times.csv';
d1DarkFileName = 'd1Dark@500ms.csv';
d2DarkFileName = 'd2Dark@500ms.csv';
focusPlot = 0;
ambiantSerialNum = 'S07408';
FOV = 1; %degrees

%% get white ref data
w = importdata(whiteFileName,',',2);

%get the white ref for d1 and d2
if strcmp(w.textdata(3,2),ambiantSerialNum)
    d2White = w.data(1,7:end);
    d1White = w.data(2,7:end);
else
    d1White = w.data(1,7:end);
    d2White = w.data(2,7:end);
end

%get the integration time of each white reference 
wt = importdata(whiteIntegTimesFileName,',',1);

%get the white ref integration times for d1 and d2
if strcmp(w.textdata(2,1),ambiantSerialNum)
    d2WhiteTime = wt.data(1);
    d1WhiteTime = wt.data(2); 
else
    d1WhiteTime = wt.data(1); 
    d2WhiteTime = wt.data(2);
end

%% get wavs
wavs = csvread(mainDataFileName,0,10,[0 10 1 1033]);
wav1 = wavs(1,:);

%% get dark ref
d1Dark = csvread(d1DarkFileName,0,1);
d2Dark = csvread(d2DarkFileName,0,1);

d1Dark = d1Dark';
d2Dark = d2Dark';

%% get main spectrum
d = importdata(mainDataFileName,',',2);

% get the samples 
samples = d.data(:,7:end);

alts = d.data(:,1);
serialNums = d.textdata(3:end,2);

disp('the number of total samples is: ');
totalSamples = length(samples(:,1));
disp(totalSamples);

%% separate d1 from d2
if strcmp(serialNums(1,1),ambiantSerialNum)
    d2 = samples(1:2:totalSamples,:);
    d1 = samples(2:2:totalSamples,:);
else
    d1 = samples(1:2:totalSamples,:);
    d2 = samples(2:2:totalSamples,:);  
end

disp('the number of samples per device is: ');
numSamples = totalSamples/2;
disp(numSamples);

%% calc samples baseline integration time
d1 = d1/300;
d2 = d2/300;

d1White = d1White/d1WhiteTime;
d2White = d2White/d2WhiteTime;

d1Dark = d1Dark/500;
d2Dark = d2Dark/500;
%% Smooth the data 
for i = 1:totalSamples
    %samples(i,:) = medfilt1(samples(i,:),15);
end 

%% Calc Reflectance Ratio 

%Ambient = (ambient - ambient device dark)/(ambient device white - ambient device dark)
for i = 1:length(d2(:,1))
    d2(i,:) = (d2(i,:) - d2Dark) ./ (d2White - d2Dark);
end

%Reflectance = (spectrum - dark)/(white- dark)
for i = 1:length(d1(:,1))
    d1(i,:) = (d1(i,:) - d1Dark) ./ (d1White - d1Dark);
end

%% Calc the Noramlised 
%Normalised = Reflectance / Ambient


%% graph intensities
figure(1);
titleOfGraph = strcat('Intensity vs Wavelength for: ',mainDataFileName);
title(titleOfGraph);
xlabel('Wavelength (nm)');
ylabel('Intensity');

hold on;
image = imread('image.png');
imagesc([300 900],[min(min(d1(:,:)))*0.5 min(min(d1(:,:)))*0.8],image);
set(gca, 'ydir','normal'); % invert the y axis 
axis([350 850 0 max(max(abs(d1)))*1.1]);

if (focusPlot>0)
    plot(wav1,d1(focusPlot,1:end),'Linewidth',2);
    disp(alts)
    Legend=cell(1,1);
    Legend{1}=strcat('plot: ',num2str(focusPlot),' - alt =',num2str(alts(focusPlot*2-1)));
else    
    for i=1:length(d1(:,1));
        plot(wav1,d1(i,:),'Linewidth',2);
        [M,I] = max(d1(i,:));
        text(wav1(I),M,num2str(i))
    end

    Legend=cell(numSamples,1);
    for i=1:numSamples
        Legend{i}=strcat(num2str(i),' - alt =', num2str(alts(i*2)));
    end
end
legend(Legend)
 
 %% get KML ready
 %want a csv file with sampleNum, lat, lon, NDVI 
 sampleNumbers = 1:numSamples;
 sampleNums = sampleNumbers';
 
 %find the NIR,R, and B wavelength in the samples
 for i=1:length(wav1);
     if wav1(i) >= 790
         NIR_index = i;
         break;
     end
 end
 
  for i=1:length(wav1);
     if wav1(i) >= 660;
         R_index = i;
         break;
     end
  end
  
  for i=1:length(wav1);
     if wav1(i) >= 440;
         B_index = i;
         break;
     end
  end
 
 %avarage around these indexes 
 numToAvg = 10; %must be even number
 NIR_sum = d1(:,NIR_index-numToAvg/2);
 for i = NIR_index-numToAvg/2+1:NIR_index + numToAvg/2;
     NIR_sum = NIR_sum + d1(:,i);
 end
  
 R_sum = d1(:,R_index-numToAvg/2);
 for i = R_index-numToAvg/2+1:R_index + numToAvg/2;
     R_sum = R_sum + d1(:,i);
 end
 
  B_sum = d1(:,B_index-numToAvg/2);
 for i = B_index-numToAvg/2+1:B_index + numToAvg/2;
     B_sum = B_sum + d1(:,i);
 end

C1 = 6; %coeff 1
C2 = 7.5; %coeff 2
G = 2.5; %gain factor
L = 1; 

NIR = NIR_sum/numToAvg; 
R = R_sum/numToAvg;
B = B_sum/numToAvg;

NDVI = (NIR - R)./(NIR + R); 
EVI = G*(NIR-R)./(NIR + C1*R - C2*B + L); 

% get new lat/lon values
a = d.data(1:2:end,1);
r = d.data(1:2:end,2);
p = d.data(1:2:end,3);
y = d.data(1:2:end,4);

%convert from degrees to radians
r = r.*pi./180;
p = p.*pi./180;
y = y.*pi./180;
FOV = FOV*pi/180;

lon = d.data(1:2:end,6)/10000000; 
lat = d.data(1:2:end,5)/10000000;

de = sqrt(a.^2.*((tan(p)).^2 + (tan(r)).^2)).*cos(90 - y - atan(tan(r)./tan(p)));
dn = sqrt(a.^2.*((tan(p)).^2 + (tan(r)).^2)).*cos(y+atan(tan(r)./tan(p)));

sampleAreaRadius = a.*tan(FOV/2);
 
file = [sampleNums lat lon dn de a sampleAreaRadius NDVI EVI];
dlmwrite('kmlPackage.csv',file, 'delimiter', ',', 'precision', 9);
 