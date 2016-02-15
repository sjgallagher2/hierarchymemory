%make_distal_segment.m
%Sam Gallagher
%12 Feb 2016
%
%This function makes a distal dendrite segment which connects a given cell
%to cells in the surrounding area. The segment has an activity parameter,
%so it can be active or inactive, depending on the overlap of the segment,
%but this will be implemented elsewhere. 

function [seg,act] = make_distal_segment(learning_radius, syn_thresh, dendrite_ratio, n_cols, n_cells,cell_col, c)
    %learning_radius is the max distance a cell can connect to, in terms of
    %columns. 
    %dendrite_ratio is the ratio of the number of columsn to the number of
    %dendrite connection.
    %n_cols is the number of columns in the region
    %n_cells is the number of cell layers per column
    %cell_col is the column of the current cell
    %c is the cell number of the current cell
    
    maxLoc = min(cell_col+learning_radius, n_cols);
    minLoc = max(cell_col-learning_radius, 1);
    n_dendrites = floor(dendrite_ratio*n_cols); %how many dendrites we can have.
    
    seg = zeros(n_dendrites,4); %the segment has locations, synapses perm, and synapse connection (0 or 1)
    act = false;
    
    if n_dendrites <= (maxLoc-minLoc)*n_cells
        for iter = 1:n_dendrites %Make a dendrite seg(iter) for all dendrites
            %first select a random col, then a random cell in that col
            seg(iter, 1) = randi([minLoc, maxLoc],1);
            
            %then select a cell in that column
            seg(iter, 2) = randi([1,n_cells],1);
            
            %then update synapses for each
            seg(iter,3:4) = update_s([0,0], syn_thresh, mod(rand(),0.05)+syn_thresh-0.03);
            
            %chances are very slim that we'll double up, but check code can
            %go here.
        end
    else
        fprintf('Error: There are not enough cells in this radius to connect to.');
    end
end
