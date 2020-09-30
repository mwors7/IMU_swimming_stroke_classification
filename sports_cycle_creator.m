function [SC,Signal_SC,num_events_interval] = sports_cycle_creator(num_intervals,peak_locs,Signal_channel,sample_rate)
%This function uses the sample numbers output using a peak detection
%algorithm to create cyclic windows in sports data.
%The input variables are:
%num_intervals is a row vector containing the number of (for example) swimming lengths, running laps etc.

%peak_locs is a cell variable containing the peak sample number of events (e.g.
%swimming strokes), each cell contains the peak sample number for a
%different interval.

%Signal_channel is a column vector containing the signal data for a sensor
%channel (e.g. Acceleration x, y or z)

%sample_rate is a single variable containing the sample rate (in Hz) for
%the sensor.

%The output variables are:
%SC is a cell variable containing the index ranges of sport cycles for each
%interval, each stored as separate cells as well.

%Signal_SC is a cell variable containing the sensor signal of interest split into sport cycles.
%The first set of cells divides the intervals, the second set of cells divides the sport cycles.

%num_events_interval (Updated num_events_interval after removing sports
%cycles longer than a specified time threshold). 

%This function can be used to create cyclic data windows for motions in IMU
%sports analysis such as swimming stroke cycles, running stride cycles and
%rowing stroke cycles etc. 
%Use the locations of the peaks to create cyclic windows in sports data

%By Matthew Worsey (30/09/2020)

%Finds the number of action events (e.g. swimming strokes) in each
%interval (e.g. swimming length or full swim).
for j = 1:num_intervals
    num_events_interval(j) = length(peak_locs{j});
end

%Make empty cell for sport cycles (cycles have different vector lengths)
SC = {};
%Make empty cell for sensor channel signal cycle input
Signal_SC = {};

%Make stroke cycles
for i = 1:num_intervals %Loop through all intervals (e.g. swimming lengths)
    for ii = 1:num_events_interval(i)-1 %loop through each event in each interval (e.g. all swimming strokes in length)
        SC{i}{ii} = peak_locs{i}(ii):peak_locs{i}(ii+1);
        %Put channel into sport cycles
        Signal_SC{i}{ii} = Signal_channel(SC{i}{ii});
        
        %Remove sport cycle signals that are over 3 seconds  long (length
        %interval), signal cycles longer than 3 seconds are typically
        %tumble turns or change in direction at the end of each length.
        if length(Signal_SC{i}{ii})>sample_rate*3
            SC{i}{ii} = [];
            Signal_SC{i}(ii) = []; %Removes stroke cycles longer than typical stroke
        end
    end
    
    %Remove the empty cells from the cell variable
    SC{i}(cellfun('isempty',SC{i})) = [];
    Signal_SC{i}(cellfun('isempty',Signal_SC{i})) = []; %Delete the empty cells 
    
    %Update the number of cycles in each interval after the longer ones
    %haev been removed.
    for ii = 1:length(Signal_SC)
        num_events_interval(ii) = length(Signal_SC{ii});
    end
    
end

end

