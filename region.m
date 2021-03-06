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
%
%Notes on region structure: Originally, the region() method was designed to
%run all the timesteps for a sequence of one region. It has since been
%updated to run all the regions (as defined by nRegions). 

function rdata = region(data,rdata,nRegions,c, dbg, pauseTime)
    %% To begin, get our data straight.
    c(1).seq_time = size(data,2); %the time this is going to take
    
    hoods = [];
    
    segment.locations = [];
    segment.perm = [];
    segment.synCon = [];
    segment.overlap = 0;
    segment.active = 0;
    segment.sequence = false;
    segment.cell = -1;
    segment.index = -1;
    segment.correct = []; % a vector of booleans showing if the segment predicted correctly
    
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
    
    for i = 1:nRegions
        hoods(i) = ceil(c(i).columns/c(i).Neighborhood);
    end
    
    if isempty(rdata(1).cells)
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
        for i = 1:nRegions
            if isempty(rdata(i).columns) %if you did not receive columns from a previous round
                waitbox = waitbar(0,['Initializing columns... (region ',num2str(i),')']);
                for iter = 1:c(i).columns
                    waitbar(iter/c(i).columns);
                    %To select a center, we need to
                    %account for the fact that n.cols < data_size. We can multiply each
                    %column center then, by the inverse of n.cols. For
                    %example, with 100 input bits and 30 columns, column 1 will have
                    %its center at position 1/30th of the way into the input, at
                    %100*(1/30), and taking the floor.

                    col.center = floor(c(i).data_size*(iter/c(i).columns));
                    [col.locations col.perm col.synCon] = make_proximal_segment(c(i), col.center);

                    rdata(i).columns = [rdata(i).columns col];
                end
                close(waitbox);
            end
        end
    else
        for i = 1:nRegions
            if isempty(rdata(i).columns)
                for iter = 1:c(i).columns
                    rdata(i).columns = [rdata(i).columns col];
                end
            end
        end
    end
    
    %% Generate cells if [cells] is empty
    if isempty(rdata(1).cells)   %Conditional based on temporal memory?
        for reg = 1:nRegions
            for i = 1:c(reg).columns
                for j = 1:c(reg).cellsPerCol
                    cell.col = i;
                    cell.layer = j;
                    cell.state(1) = 0; %We know all cells are inactive

                    rdata(reg).cells = [rdata(reg).cells cell];
                end
            end
        end
    end
    for i = 1:nRegions
        rdata(i).activeColumns = zeros(c(i).desiredLocalActivity*hoods(i),c(i).seq_time);
    end
    %Main loop
    waitbox = waitbar(0,'Running HTM...');
    for R = 1:c(1).reps
        for t = 1:c(1).seq_time
            for regid = 1:nRegions
                if regid == 1
                    waitbar((t+c(1).seq_time*(R-1))/(c(1).seq_time*c(1).reps));
                end
                
                if regid == 1
                    bottomup_in = data(:,t);
                else
                    bottomup_in = rdata(regid-1).output;
                    bottomup_in = transpose(bottomup_in);
                end
                if t == pauseTime
                    d = msgbox('Stopped...','Debugging message','warn');
                    dbg(['Stopped at t = ',num2str(t)]);
                    dbg('');
                    waitfor(d);
                end
                if c(regid).TM_delay == 0
                    %Run like normal
                    [rdata(regid).columns,rdata(regid).cells,tempPrediction,nActive,rdata(regid).output,tempActiveColumns, rdata(regid).queue,rdata(regid).correctPredictions(t+c(1).htm_time)] = ...
                        update_region(rdata(regid).columns, rdata(regid).cells, segment,bottomup_in,c(regid),t,hoods(regid),rdata(regid).queue,dbg);
                    %update active columns and the prediction
                    rdata(regid).activeColumns(1:nActive,t) = tempActiveColumns;
                    rdata(regid).prediction(1:c(regid).columns,t) = tempPrediction;
                    
                else
                    %If there is a delay on the temporal memory, run it without
                    %the TM
                    c(regid).temporal_memory = false;
                    [rdata(regid).columns,rdata(regid).cells,tempPrediction,nActive,rdata(regid).output,tempActiveColumns, rdata(regid).queue, rdata(regid).correctPredictions(t+c(1).htm_time)] = ...
                        update_region(rdata(regid).columns, rdata(regid).cells, segment,bottomup_in,c(regid),t,hoods(regid),rdata(regid).queue,dbg); 
                    rdata(regid).activeColumns(1:nActive,t) = tempActiveColumns;
                    rdata(regid).prediction(1:c(regid).columns,t) = tempPrediction;
                    c(regid).TM_delay = c(regid).TM_delay-1;
                    if c(regid).TM_delay == 0
                        c(regid).temporal_memory = true;
                    end
                end
            end
        end
    end
    close(waitbox);
end