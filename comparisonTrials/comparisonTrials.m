close all;
%% read the data
fileName = 'comp-whiteWall_medLight.txt';
d = dlmread(fileName, ' ', 5, 0); 
d = medfilt1(d,15);

fileName1 = 'comp-bareGround_inShadow.txt';
d1 = dlmread(fileName1, ' ', 5, 0); 
d1 = medfilt1(d1,15);

%% plot the data
figure(1);
title('Intensity vs Wavelength');
xlabel('Wavelength (nm)');
ylabel('Intensity');
hold all;

plot(d(:,1),d(:,2),'Linewidth',2);
plot(d1(:,1),d1(:,2),'Linewidth',2);

legend('white wall in low light','Bare ground in low light')
