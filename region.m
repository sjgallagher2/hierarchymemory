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

function [columns,activeColumns,cells,prediction,output,columns2,cells2,prediction2,activecolumns2,output2] = region(data,id,columns,cells,nRegions,c, dbg)
    %% To begin, get our data straight.
    c(id).seq_time = size(data,2); %the time this is going to take
    
    if id == 1
        columns2 = [];
        cells2 = [];
        prediction2 = [];
        activecolumns2 = [];
        output2 = [];
    end
    
    segment.locations = [];
    segment.perm = [];
    segment.synCon = [];
    segment.overlap = 0;
    segment.active = 0;
    segment.sequence = false;
    segment.cell = -1;
    segment.index = -1;
    
    queue = []; %segment queue
    %The queue is FIFO
    
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
    col.learning_cell = -1;
    col.active_cell = -1;
    
    hoods = ceil(c(id).columns/c(id).Neighborhood);
    
    if isempty(cells)
        cell.col = 0;     %cell column
        cell.layer = 0;   %cell layer
        cell.segs = [];   %This holds the segments
        cell.nseg = 0;
        cell.state = [];  %The cell state is an array of states over time
                %cell states: 0 is inactive, 1 is active, 2 is predicting
        cell.tempFlag = false; %This is true when the changes are temporary, false when they are permanent
        cell.learn = [];
        cell.mknewseg = false;
        cell.active = [];
    end
    %% Generate columns and proximal segments on the first run
    if c(1).spatial_pooler
        if isempty(columns) %if you did not receive columns from a previous round
            
            columns = [];
            waitbox = waitbar(0,'Initializing columns...');
            for iter = 1:c(id).columns
                waitbar(iter/c(id).columns);
                %To select a center, we need to
                %account for the fact that n.cols < data_size. We can multiply each
                %column center then, by the inverse of n.cols. For
                %example, with 100 input bits and 30 columns, column 1 will have
                %its center at position 1/30th of the way into the input, at
                %100*(1/30), and taking the floor.

                col.center = floor(c(id).data_size*(iter/c(id).columns));
                [col.locations col.perm col.synCon] = make_proximal_segment(c(id), col.center);

                columns = [columns col];
            end
            close(waitbox);
        end
    else
        if isempty(columns)
            for iter = 1:c(id).columns
                columns = [columns col];
            end
        end
    end
    
    %% Generate cells if [cells] is empty
    if isempty(cells)   %Conditional based on temporal memory?
        cells = [];

        for i = 1:c(id).columns
            for j = 1:c(id).cellsPerCol
                cell.col = i;
                cell.layer = j;
                cell.state(1) = 0; %We know all cells are inactive

                cells = [cells cell];
            end
        end
    end
    
    activeColumns = zeros(c(id).desiredLocalActivity*hoods,c(id).seq_time);
    
    %Main loop
    if id == 1
        waitbox = waitbar(0,'Running HTM...');
    end
    for R = 1:c(id).reps
        for t = 1:c(id).seq_time
            if id == 1
                waitbar((t+c(id).seq_time*(R-1))/(c(id).seq_time*c(id).reps));
            end
            if c(id).TM_delay > 0
                %If there is a delay on the temporal memory, run it without
                %the TM
                c(id).temporal_memory = false;
                [columns,cells,tempPrediction,nActive,output,tempActiveColumns] = ...
                    update_region(columns, cells, segment,data(:,t),c(id),t,hoods,dbg); 
                
                activeColumns(1:nActive,t) = tempActiveColumns;
                prediction(1:c(id).columns,t) = tempPrediction;
                c(id).TM_delay = c(id).TM_delay-1;
                if c(id).TM_delay == 0
                    c(id).temporal_memory = true;
                end
            else
                %Otherwise run like normal
                [columns,cells,tempPrediction,nActive,output,tempActiveColumns] = ...
                    update_region(columns, cells, segment,data(:,t),c(id),t,hoods,dbg); 
                %update active columns and the prediction
                activeColumns(1:nActive,t) = tempActiveColumns;
                prediction(1:c(id).columns,t) = tempPrediction;
                
                %run the next region
                %TODO: how to store the next columns, cells, prediction,
                %etc? 
                if nRegions > id 
                    [columns2,activecolumns2,cells2,prediction2,output2] = ...
                        region(transpose(output),id+1,columns2,cells2,nRegions,c,dbg);
                end
            end
        end
    end
    if id == 1
        close(waitbox);
    end
end