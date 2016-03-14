%
%Sam Gallagher
%9 March 2016
%
%This function assigns and returns the region and n structures from an
%input array from a file or passed from a function

function [region n] = set_config(tRegion, tN, inputConfig)

    tRegion.synThreshold = inputConfig(1);
    tRegion.synInc = inputConfig(2);
    tRegion.synDec = inputConfig(3);
    tN.dendrites = inputConfig(4);  % percentage
    tRegion.minSegOverlap = inputConfig(5);
    tN.cols = inputConfig(6);   % percentage
    tRegion.desiredLocalActivity = inputConfig(7);
    tN.neighborhood = inputConfig(8);
    tRegion.inputRadius = inputConfig(9);
    tRegion.boostInc = inputConfig(10);
    tRegion.minActiveDuty = inputConfig(11);
    tRegion.minOverlapDuty = inputConfig(12);
    tN.cells = inputConfig(13);
    tN.segs = inputConfig(14);
    tRegion.LearningRadius = inputConfig(15);
    tRegion.minOverlap = inputConfig(16);
    
    region = tRegion;
    n = tN;
end