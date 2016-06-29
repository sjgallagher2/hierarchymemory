%getActiveSeg.m
%Sam Gallagher
%26 Feb 2016
%
%This module computes an active distal dendrite segment from a list of
%segments. 

function activeSegment = getActiveSeg(mycell, cells,t,pred)
    %pred is a boolean that indicates whether or not to include
    %predictions from predictions.
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
                    %check if synapses are connected to an active cell
                    if pred
                        if cells( mycell.segs(i).locations(j) ).state(t) == 2
                            pos = mycell.segs(i).locations(j);
                            for s = 1:numel(cells(pos).segs)
                                if any(cells( pos ).segs(s).correct == true)
                                    mycell.segs(i).overlap = mycell.segs(i).overlap + 1;
                                end
                            end
                        end
                    else
                        if cells( mycell.segs(i).locations(j) ).active(t) == 1
                            mycell.segs(i).overlap = mycell.segs(i).overlap+1;
                        end
                    end
                end
            end
            %compute active segment
            if activeSegment == -1
                if mycell.segs(i).overlap > 0
                    activeSegment = i;
                end
            elseif mycell.segs(i).overlap > mycell.segs(activeSegment).overlap
                activeSegment = i;
            end
        end
    end
end