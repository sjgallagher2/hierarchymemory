%region.m
%Sam Gallagher
%15 February
%
%This function manages a region that is given an input. The input must
%consist of all data to-be-input in columns, with each column representing
%a time step. Random inputs can be generated to test functionality with the
%generate_input.m file. 
%
%Output is an OR of the active and predictive cells,
%and the n structure (number of columns, cells, etc), the columns
%structure, and the cells structure

function [columns,activeColumns,cells,output] = region(dInput,inputConfig,id)
    %% To begin, get our data straight.
    synThreshold = inputConfig(1);
    synInc = inputConfig(2);
    synDec = inputConfig(3);
    nDendrites = inputConfig(4); % percentage
    minSegOverlap = inputConfig(5);
    n.cols = inputConfig(6); % percentage
    desiredLocalActivity = inputConfig(7);
    Neighborhood = inputConfig(8);
    inputRadius = inputConfig(9);
    boostInc = inputConfig(10);
    minActiveDuty = inputConfig(11); % percentage
    minOverlapDuty = inputConfig(12); % percentage
    nCells = inputConfig(13);
    nSegs = inputConfig(14);
    LearningRadius = inputConfig(15);
    minOverlap = inputConfig(16);
    
    data_size = size(dInput);
    
    segment.locations = [];
    segment.perm = [];
    segment.synCon = [];
    segment.overlap = 0;
    segment.active = 0;
    segment.sequence = false;
    
    col.center = 0;
    col.perm = [];
    col.synCon = [];
    col.overlap = 0;
    col.overlapSum = 0; %used for rolling avg
    col.active = 0;
    col.activeSum = 0; %used for rolling avg
    col.locations = [];
    col.boost = 1;
    col.actDuty = 1.0;
    col.oDuty = 1.0;
    col.burst = false;
    
    n.data = data_size(1);
    n.time = data_size(2);
    n.dendrites = floor(nDendrites*n.data);
    n.cols = floor(n.cols*data_size(1));
    n.cellpercol = nCells;
    n.cells = nCells*n.cols;
    n.segments = nSegs;
    n.neighborhood = Neighborhood;
    n.hoods = ceil(n.cols/n.neighborhood);
    
    cell.col = 0;     %cell column
    cell.layer = 0;   %cell layer
    cell.segs = [];   %This holds the segments
    cell.state = [];  %The cell state is an array of states over time
            %cell states: 0 is inactive, 1 is active, 2 is predicting
    cell.tempFlag = false; %This is true when the changes are temporary, false when they are permanent
    
    temporal_memory_on = false;
    
    %% Generate columns and proximal segments 
    columns = [];
    
    for iter = 1:n.cols
        %To select a center, we need to
        %account for the fact that n.cols < data_size. We can multiply each
        %column center then, by the inverse of n.cols. For
        %example, with 100 input bits and 30 columns, column 1 will have
        %its center at position 1/30th of the way into the input, at
        %100*(1/30), and taking the floor.
        
        col.center = floor(n.data*(iter/n.cols));
        [col.locations col.perm col.synCon] = make_proximal_segment(n.dendrites,inputRadius, n.data, col.center,synThreshold);
        
        columns = [columns col];
    end
    
    %% Generate cells
    cells = [];
    
    for i = 1:n.cols
        for j = 1:n.cellpercol
            cell.col = i;
            cell.layer = j;
            cell.state(1) = 0; %We know all cells are inactive
            
            cells = [cells cell];
        end
    end
    
    activeColumns = zeros(desiredLocalActivity*n.hoods,n.time);
    
    %% Now we'll go into a time-step loop
    for t = 1:data_size(2)
        %For each timestep, find overlaps for the columns and reset
        %activity and sums
        for c = 1:n.cols
            columns(c).active = 0;
            columns(c).overlap = compute_overlap(dInput(:,t),columns(c),minOverlap);
            if columns(c).overlap > 0
                columns(c).overlapSum = columns(c).overlapSum + 1; %update rolling sum
            end
        end
        
        %% Select Active Columns
        %Send each neighborhood to the inhibitor, store the result as the
        %active column list. 

        %There are a few ways to handle this neighborhoods part. The first
        %is to split the columns into neighborhoods like 1-10, 11-20, etc.
        %The other option would be to observe the radius for each column,
        %so 1-5, 1-6 (for col 2) ... 20-30 for col 25, and so on. This
        %causes columns to be evaluated more than once, but this may not be
        %a bad thing, as long as a column is not selected to 'win' more
        %than once.
        for iter = 0:n.hoods-1
            start = n.neighborhood*(iter)+1;
            stop = min(start+(n.neighborhood-1),n.cols); %make sure it doesn't go over the max ncols
            o = [ columns(start:stop).overlap ];
            
            w = inhibit_cols(o,desiredLocalActivity);
            if w == -1
                tempA = -1;
            else
                tempA = transpose(w+start-1);
            end
            
            for c = 1:n.cols
                if(any( c == tempA ))
                    columns(c).active = 1;
                    columns(c).activeSum = columns(c).activeSum+1;%update rolling sum
                end
            end
        end

        %Now, what if the neighborhoods overlapped each other at each
        %point? What change in the total number of active columns selected
        %will we see?
        %activeColumns2 = 0;
        %for colCenter = 1:n.cols
        %    start = max(colCenter - Neighborhood/2, 1);
        %    stop = min(colCenter + Neighborhood/2, n.cols);
        %    n = columnOverlaps(t,start:stop);
        %    activeColumns2 = [inhibit_cols(n,desiredLocalActivity)+start, activeColumns2];
        %end
        %activeColumns2 = unique(activeColumns2(activeColumns2 ~= 0));
        %sort(activeColumns2);

        %% Use active columns to update synapses
        
        %This loop checks if a synapse is connected, and updates it
        %based on whether or not it is, for every position in the
        %column c
        for c = 1:n.cols
            if columns(c).active
                for i = 1:n.dendrites
                    if columns(c).synCon(i) == 1
                        if dInput(columns(c).locations(i)) == 1
                            %There are assignment issues here, replacing
                            %synCon
                            [columns(c).perm(i) columns(c).synCon(i)] = update_s(columns(c).perm(i),columns(c).synCon(i), synThreshold,synInc);
                        else
                            [columns(c).perm(i) columns(c).synCon(i)] = update_s(columns(c).perm(i),columns(c).synCon(i), synThreshold,synDec);
                        end
                    end
                end
                
                %Let's update the cells now, with the active columns. 
                %We need to see what cells were expected to be active at
                %this time step, i.e. what cells were predicting the
                %previous time step. 
            end
        
            
            %Update the minimum active duty cycle to meet before being
            %boosted. 1% of the max active duty cycle in the neighborhood
            minActiveDuty = 0.01*max( [columns( max(1,(c-Neighborhood/2)):min(n.cols,(c+Neighborhood/2)) ).actDuty] );
            
            %update the duty cycles for activity and overlaps-above-minimum
            columns(c).actDuty = columns(c).activeSum / t;
            columns(c).oDuty = columns(c).overlapSum / t;
            
            if columns(c).actDuty < minActiveDuty
                columns(c).boost = columns(c).boost + boostInc;
            end
            
            if columns(c).oDuty < minOverlapDuty
                %increase all synapse permanences by 0.1*synapse threshold
                for i = 1:n.dendrites
                    columns(c).perm(i) = columns(c).perm(i)+0.1*synThreshold;
                end
            end
        end
        w = find_active_columns(columns,n.cols);
        nActive = size(w);
        nActive = nActive(2);
        if ~(isempty(w))
            activeColumns(1:nActive,t) = w;
        end
        n.active = nActive;
        %% Now Update our cells for the temporal memory
        
        %For active columns, check if cells were predictive, set them
        %active
        %If none were predictive, bursting occurs
        if temporal_memory_on == true
            
            for i = 1:n.active
                columns(i).burst = true;

                if t == 1
                    for j = 1:n.cellpercol
                        loc = getcell_loc(j,activeColumns(i),n);
                        mycell = cells( loc );
                        mycell.state = 1;
                        cells(loc) = mycell;
                    end

                else
                    for j = 1:n.cellpercol
                        loc = getcell_loc(j,activeColumns(i),n);
                        mycell = cells( loc );
                        t
                        if mycell.state(t-1) == 2
                            mycell.state(t) = 1;
                            columns(i).burst = true;
                        end
                        cells( loc ) = mycell;
                    end
                    if columns(i).burst == true
                        for j = 1:n.cellpercol
                            loc = getcell_loc(j,activeColumns(i),n);
                            mycell = cells( loc );
                            mycell.state(t) = 1;
                            cells( loc ) = mycell;
                        end
                    end
                end
                %select learning cell

            end
        end
        
    end
    
    %% Create output
    
    if n.cols > 0   %If columns were created
        %Make output
        output = [];
        for i = 1:n.cols
            if columns(i).active == true
                output = [output 1];
            else
                output = [output 0];
            end
        end
        output = fliplr(output);
        output = output';
    else
        %if there are no columns, the output is a -1
        output = -1;
    end
end