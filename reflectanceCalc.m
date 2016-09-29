s = csvread('red_40mm_noLight_@500ms-iter-00001-step-01-acq-00001.csv',1);

%%get wavelenghts, live data, black and white reference values
w = s(:,1);
data = s(:,2);
dark = s(:,3);
white = s(:,4);

refl = zeros(length(data),1);
disp(refl);

%%reflection= (data-dark) / (white - spectrum)
for i = 1:length(data)
    
    if white(i) > data(i) && data(i) > dark(i)
        ref = (data(i) - dark(i)) / (white(i) - data(i));
    else 
        ref = 0;
    end 
    refl(i) = ref;
end

%%The function medfilt1 replaces every point of a signal by the 
%   median of that point and a specified number of neighboring points. 
%   Accordingly, median filtering discards points that differ considerably 
%   from their surroundings. 
filtered = medfilt1(refl,3);
figure(1);
plot(refl);
figure(2);
plot(filtered);