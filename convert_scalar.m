%convert_scalar.m
%Sam Gallagher
%19 June 2016
%
%Encodes scalar value into a square sz x 1 array , SDR

function out = convert_scalar(decin,sz,min,max,neighborhood_size)
    %the method here is to convert the input number into a square array, and encode it
    %in such a way that it is represented as a square array. So the first
    %thing to do is create a blank sz x 1 array.
    
    out = zeros(sz,1);
    maxElements = sz - neighborhood_size;
    range = max - min;
    %Now we need to normalize the input value
    decin = decin-min;
    %the method behind the start location is this: dividing the maximum
    %number of elements by the range of values we need to represent will
    %give the increment we need for every corresponsing number. We multiply
    %this increment by the input number and take the floor. 
    start_loc = floor(decin*(maxElements/range));
    if start_loc == 0
        start_loc = 1;
    end
    for i = start_loc:start_loc+neighborhood_size
        out(i) = 1;
    end
    out = out';
end
