%AccelToPos.m
%Sam Gallagher
%30 June 2016
%
%A method which takes discrete acceleration data, and converts it into
%position data

%get data from a csv file
datapath = 'examples\\csvfiles\\walking1.old.csv';
accel_data = csvread(datapath);

%integrate, with filtering to reduce offset
dc_filter = fir1(200,0.014,'high');%create a FIR filter, filter the data w/ very high order highpass
accel_data = accel_data - mean(accel_data);
accel_data = filter(dc_filter,1,accel_data);
vel_data = cumtrapz(accel_data);
vel_data = filter(dc_filter,1,vel_data);
pos_data = cumtrapz(vel_data);
pos_data = pos_data/100;
pos_data = filter(dc_filter,1,pos_data);
%plot filtered data
% figure
% plot(accel_data);
% hold on;
% plot(vel_data);
%plot(pos_data);

%save back to csv
datapath = 'examples\\csvfiles\\walking1.csv';
csvwrite(datapath,pos_data);