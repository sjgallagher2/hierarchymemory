%convert_image.m
%Sam Gallagher
%6 June 2016
%
%Converts an MxNx3 image into binary data that the algorithm can use

function bData = convert_image(imData)
    %Convert all numbers into 8 bit binary
    %arrange in order (first second third)
    %lay binary numbers out
    
    imSize = size(imData);
    imHeight = imSize(1);
    imLength = imSize(2);
    
    imData = permute(imData, [1,3,2] );
    imData = reshape(imData,[],size(imData,2)*size(imData,1),1);
    bData = dec2bin(imData);
    bData = permute(bData,[2,1]);
    bData = reshape(bData,[],1);
    bData = str2num(bData);
end