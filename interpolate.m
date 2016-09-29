d1 = csvread('device-0.csv');
d2 = csvread('device-1.csv');

%%
%Interpolate d2's values onto d1's values 

%get the sample points of d1 that we want d2's value's to be interpolated
%onto
d1_points = d1(:,1);

%get the sample points of d2
d2_points = d2(:,1);

%get the corresponding values of d2
d2_values = d2(:,2);

%Interpolate:
d2_interpolated = interp1(d2_points,d2_values,d1_points);
disp(d2_interpolated);

%%
%save to csv: 
m = horzcat(d1,d2_interpolated);
disp(m);
csvwrite('interpolated.csv',m);


