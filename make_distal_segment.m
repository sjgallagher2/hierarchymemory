%make_distal_segment.m
%Sam Gallagher
%12 Feb 2016
%
%This function makes a distal dendrite segment which connects a given cell
%to cells in the surrounding area. The segment has an activity parameter,
%so it can be active or inactive, depending on the overlap of the segment,
%but this will be implemented elsewhere. 

function [segLocations, segPerms, segCons] = make_distal_segment(c, cell_col, cells, ncells,t)
    %learning_radius is the max distance a cell can connect to, in terms of
    %columns. 
    %dendrite_ratio is the ratio of the number of columns to the number of
    %dendrite connection.
    %ncells is the number of cell layers per column
    %cell_col is the column of the current cell
    %c is the cell number of the current cell
    
    %Seed the random generator (in case we use it later)
    rng('shuffle');
    
    %Set locations bounds
    maxLoc = min(cell_col+c.LearningRadius, c.columns);
    minLoc = max(cell_col-c.LearningRadius, 1);
    
    %the segment has locations, synapses perm, and synapse connection (0 or 1)
    segLocations = [];
    segPerms = [];
    segCons = [];
    
    if c.nDendrites <= (maxLoc-minLoc)*ncells
        for i = 1:ncells
            if (cells(i).active(t) == 1) || (cells(i).state(t) == 2)
                %Add cells that were previously active to the segment as long as they're
                %within the location bounds
                if cells(i).col >= minLoc
                    if cells(i).col <= maxLoc
                        segLocations = [segLocations i];

                        %Initial permanence will be 0.15 for all (for now)
                        segPerms = [segPerms 0.15];                                   %TODO: Set this back
                        segCons = [segCons 0];

                        %It might be better or worse to start all at different
                        %segment permanences. Again, a range of values around
                        %the threshold
                    end
                end
                
            end
        end
    else
        fprintf('Error: There are not enough cells in this radius to connect to.\n');
    end
end
