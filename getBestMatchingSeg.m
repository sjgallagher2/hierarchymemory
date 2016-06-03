%getBestMatchingSeg.m
%Sam Gallagher
%31 May 2016
%
%Takes cells as input, computes segment overlap regardless of synapse
%connection
%Used for strengthening segments that aren't connected yet (important!)

function bestSegs = getBestMatchingSeg(mycell, cells, t)
    bestSegs = [];
    bCount = 1;
    if isempty(mycell.segs)
        
    else
        nSegs = numel(mycell.segs);
        
        for i = 1:nSegs
            %cycle through the segments
            nSyn = numel(mycell.segs(i).synCon);
            for j = 1:nSyn
                %check if synapses are connected to an active cell
                if cells( mycell.segs(i).locations(j) ).active(t-mycell.segs(i).index) == 1
                    mycell.segs(i).overlap = mycell.segs(i).overlap+1;
                end
            end
            %compute active segment
            if mycell.segs(i).overlap > 0
                bestSegs(bCount) = i;
                bCount = bCount+1;
                %fprintf('One good segment is: %d\n',bestSegs)
            end
            
%             if bestSegs == []
%                 if mycell.segs(i).overlap > 0
%                     bestSegs = i;
%                     fprintf('One best segment is: %d\n',bestSegs)
%                 end
%             elseif mycell.segs(i).overlap >= mycell.segs(bestSegs).overlap
%                 bestSegs = i;
%                 fprintf('Another segment is: %d\n',bestSegs)
%             end
        end
    end
end