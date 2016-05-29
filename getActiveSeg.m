%getActiveSeg.m
%Sam Gallagher
%26 Feb 2016
%
%This module computes an active distal dendrite segment from a list of
%segments. 

function activeSegment = getActiveSeg(mycell, cells,t)
    activeSegment = -1;
    if isempty(mycell.segs)
        %if there are no segments for this cell
    else
        nSegs = numel(mycell.segs);
        
        for i = 1:nSegs
            %cycle through the segments
            nSyn = numel(mycell.segs(i).synCon);
            for j = 1:nSyn
                %check if the synapses are connected
                if mycell.segs(i).synCon(j) == 1
                    %check if synapses is connected to an active cell
                    if cells( mycell.segs(i).locations(j) ).state(t) == 1
                        mycell.segs(i).overlap = mycell.segs(i).overlap+1;
                    end
                end
            end
            %compute active segment
            if activeSegment == -1
                activeSegment = i;
            elseif mycell.segs(i).overlap > mycell.segs(activeSegment).overlap
                activeSegment = i;
            end
        end
    end
end