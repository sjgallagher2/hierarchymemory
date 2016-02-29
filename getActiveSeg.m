%getActiveSeg.m
%Sam Gallagher
%26 Feb 2016
%
%This module computes an active distal dendrite segment from a list of
%segments. 

function activeSegment = getActiveSeg(segs, nSegs, totalCellCount, allCells, minOverlap,t)
    segsize = size(segs(1).locations);
    segsize = segsize(1);
    if segsize == 0
        %add a new segment?
        activeSegment = -1;
    else
        cellBinaryArray = [];
        for i = 1:totalCellCount
            if allCells(i).state(t) == 'Active'
                cellBinaryArray = [cellBinaryArray 1];
            else
                cellBinaryArray = [cellBinaryArray 0];
            end
        end


        %iterate through the segments, computing the overlap for each
        for i = 1:nSegs
            overlap = computer_overlap(cellBinaryArray,segs(i),minOverlap);
        end
        
        %find the segment with the maximum overlap
        activeSegment = -1;
    end
    
end