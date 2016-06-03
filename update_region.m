%update_region.m
%Sam Gallagher
%14 March 2016
%
%Parameters: A list of column structures, a list of cell structures, the
%input data, an N structure, a list of seg structures, and region-config params
%Outputs: List of column structures, list of cell structures, an N
%structure, the active columns list, a list of segment structures, and the region output
%Runs through a time-step of the CLA using a given

%% TODO: Add "active" as a separate part of cell structure, update ALL functions using "state"

function [columns, cells, prediction,n, output,activeColumns] = update_region(columns,cells,segments,data,n,synThreshold,...
    synInc,synDec,minSegOverlap,desiredLocalActivity,boostInc, minActiveDuty, ...
    minOverlapDuty, minOverlap, LearningRadius,segment,t,queue,temporal_memory,spatial_pooler)

    %fprintf('Time = %d \n',t)
    if spatial_pooler == true
        %fprintf('Starting spatial pooler...\n')
        %For each timestep, find overlaps for the columns and reset
        %activity and sums
        %fprintf('Calculating overlaps...\n')
        for c = 1:n.cols
            columns(c).active = 0;
            columns(c).overlap = compute_overlap(data,columns(c),minOverlap);
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
        %fprintf('Selecting active columns...\n')
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
        %fprintf('Updating synapses...\n')
        for c = 1:n.cols
            if columns(c).active
                for i = 1:n.dendrites
                    if columns(c).synCon(i) == 1
                        if data(columns(c).locations(i)) == 1
                            %There were assignment issues here, replacing
                            %synCon
                            [columns(c).perm(i) columns(c).synCon(i)] = update_s(columns(c).perm(i),columns(c).synCon(i), synThreshold,synInc);
                        else
                            [columns(c).perm(i) columns(c).synCon(i)] = update_s(columns(c).perm(i),columns(c).synCon(i), synThreshold,synDec);
                        end
                    end
                end
            end
            %Update the minimum active duty cycle to meet before being
            %boosted. 1% of the max active duty cycle in the neighborhood
            minActiveDuty = 0.01*max( [columns( max(1,(c-n.neighborhood/2)):min(n.cols,(c+n.neighborhood/2)) ).actDuty] );

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
            activeColumns(1:nActive,1) = w;
        end
        n.active = nActive;
        %fprintf('Done.\n\n')
    else
        %If NO spatial pooler
        %fprintf('Spatial pooler is OFF, skipping...\n')
        n.active = 0;
        activeColumns = [];
        for i = 1:n.data
            if data(i) == 1
                activeColumns = [activeColumns, i];
                columns(i).active = true;
                n.active = n.active + 1;
            else
                columns(i).active = false;
            end
        end
        activeColumns = activeColumns';
    end
    %% Now Update our cells for the temporal memory

    %For active columns, check if cells were predictive, set them
    %active
    %If none were predictive, bursting occurs
    
    %Then use the active CELLS to find new predictive cells
    
    %Finally, update synapses
    
    if temporal_memory == true
        
        for i = 1:n.cols
            for j = 1:n.cellpercol
                c_loc = getcell_loc(j,i,n);
                mycell = cells(c_loc);
                mycell.active(t) = 0;
                mycell.state(t) = 0;
                cells(c_loc) = mycell;
            end
        end
        %fprintf('Starting temporal memory...\n')
        %fprintf('Selecting active cells...\n')
        for i = 1:n.cols %for ALL columns, active and inactive
            celloutput = [];
            columns(i).burst = false;
            
            if isempty( find(activeColumns == i) )
                %% Inactive column process
                %Just tie up loose ends, update cells
                columns(i).learning_cell = -1;
                for j = 1:n.cellpercol
                    %for all cells in the inactive column
                    loc = getcell_loc(j,i,n); %j is the cell layer, i is the cell column
                    mycell = cells( loc );
                    mycell.state(t) = 0; %the cell must be inactive
                    mycell.active(t) = 0;
                    
                    
                    %%%%%%%%%%%%%%%   LEARNING CELL
                    mycell.learn(t) = false;
                    %Cells in inactive columns are not learning
                    
                    
                    cells(loc) = mycell;
                    celloutput(j) = mycell.state(t);
                end
            else
                %% Active column process
                %Check for predictive cells, if there are none, set the
                %column to burst
                %Select a learning cell
                
                columns(i).active_cell = -1;
                for j = 1:n.cellpercol
                    loc = getcell_loc(j,i,n);
                    mycell = cells( loc );
                    if t > 1
                        if mycell.state(t-1) == 2 %if cell was predicting, and is now in an active column
                            mycell.state(t) = 1;
                            mycell.active(t) = 1;
                            columns(i).active_cell = j;
                            %fprintf('>Cell %d in column %d is active at time %d.\n',mycell.layer, mycell.col,t)
                            if mycell.learn(t-1) == true
                                columns(i).learning_cell = j;
                            
                            
                                %%%%%%%%%%%%%%%   LEARNING CELL
                                mycell.learn(t) = true;
                                %A cell that was predicting is the learning
                                %cell
                            
                            else
                                mycell.learn(t) = false;
                            end
                        else
                            mycell.learn(t) = false;
                            mycell.state(t) = 0;
                            mycell.active(t) = 0;
                        end
                        
                    end
                    cells( loc ) = mycell;
                end
                if columns(i).active_cell == -1
                    %burst
                    %fprintf('\n>Column %d is bursting.\n',i)
                    for j = 1:n.cellpercol
                        loc = getcell_loc(j,i,n);
                        mycell = cells( loc );
                        mycell.state(t) = 1;
                        mycell.active(t) = 1;
                        mycell.learn(t) = false;
                        cells( loc ) = mycell;
                        columns(i).active_cell = [columns(i).active_cell j];
                        columns(i).burst = true;
                    end
                end
            end
        end
            
        for i = 1:n.cols
            if ~isempty( find(activeColumns == i) )
                if t > 1
                    if columns(i).learning_cell == -1
                        %select most active cell, or one that has the fewest
                        %segments
                        [columns(i).learning_cell, fewestSegs] = getBestMatchingCell(i,cells,n,t);
                        loc = getcell_loc(columns(i).learning_cell, i, n);
                        mycell = cells( loc );
                        %fprintf('Best cell is cell %d for column %d\n',mycell.layer,mycell.col)
                        mycell.mknewseg = fewestSegs; %fewestSegs is a boolean indicating whether or not 
                        % the best cell was found. We only select by fewest
                        % number of segments if no cell had a segment that
                        % matched
                        
                        if numel(mycell.segs) == n.segments
                            mycell.mknewseg = false; %Make sure the cell can only add as many segments as allowed
                        end

                        %%%%%%%%%%%%%%%   LEARNING CELL
                        mycell.learn(t) = true;
                        %This learning cell was selected because it was
                        %next in order, had the fewest segments, or had a
                        %well matched segment

                        %fprintf('>Cell %d in column %d chosen as learning cell.\n',mycell.layer,mycell.col)
                        %mycell.mknewseg = true;
                        
                        if mycell.mknewseg == true
%                         fprintf('Adding a new segment to cell %d in column %d to time t-%d\n',mycell.layer,mycell.col,(mycell.nseg+1));
                            mycell.segs = [mycell.segs, segment]; %add a blank segment
                            %label its index and cell
                            mycell.nseg = mycell.nseg + 1;
                            mycell.segs( mycell.nseg ).cell = loc;
                            mycell.segs( mycell.nseg ).index = mycell.nseg;
                            %give that cell a segment with the active cells from
                            %the previous timestep.
                            [mycell.segs( mycell.nseg ).locations mycell.segs( mycell.nseg ).perm mycell.segs( mycell.nseg ).synCon] = make_distal_segment(LearningRadius,synThreshold,n,i,columns(i).learning_cell, cells, t - mycell.nseg);
                            mycell.mknewseg = false;
                            
                            %A new segment will reach back more time steps
                            %when the current segment has made successful
                            %connections
                        end
                        cells(loc) = mycell;
                    end
                end
            end
                %Now that the learning cell and active cell(s) are
                %selected, we can move forward. 
                %We will now select cells who must predict the next time
                %step. 
        end
        
        %A cell will check any segment it has to see if one has an
        %overlap > 0, and then it will compare the segment overlaps
        %it has. If it has enough, the segment is active, and if it
        %has an active segment, it becomes predicting. 
        
        %In the spatial pooler we updated synapses for columns which were
        %connected and active, and connected but not active. Now we must handle
        %segments individually. 
        %These changes occur for:
        %   a) a segment which is active
        %   b) a segment which had enough connections in the previous time
        %   step and could have predicted if it had strong enough synapses.
        
        %Check cells segments, set active segment
%      fprintf('\nFinding predictive cells (t=%d)...\n',t)
        for i = 1:n.cells
            activeSeg = getActiveSeg(cells(i), cells,t);
            if activeSeg > 0
                cells(i).segs(activeSeg).active = 1;
                cells(i).state(t) = 2;
%              fprintf('>Segment %d is active on cell %d in column %d.\n',activeSeg,cells(i).layer,cells(i).col)
%              fprintf('>Cell %d in column %d is predicting itself to be active next...\n',cells(i).layer,cells(i).col)
                if cells(i).learn(t) == true
                    %if the cell is learning, copy it to the queue
                    queue = [queue, cells(i).segs(activeSeg)];
                end
            end
            %add the best match from last time step too for this cell
            if cells(i).active(t) == true
                bestSeg = getBestMatchingSeg(cells(i),cells,t);
                if numel(bestSeg) > 0
 %                 g = sprintf('%d, ',bestSeg);
%                  fprintf('>Best matching segments could have been segments %s for cell %d in col %d \n',g,cells(i).layer,cells(i).col)
                    queue = [queue, cells(i).segs(bestSeg)];
                end
            end
        end
        %Now comes the final stage of temporal memory
        %Update synapses
        %Many options for creating changes:
        %   - Copy segment, change, add to queue
        %   - Copy synapses perm., add to queue
        %   - Flag permanences that must be changed with a negative
        %First two options are memory intensive, last option is
        %computationally expensive.
        %This uses the queue of segments
        if t > 1
            %fprintf('Updating synapses...\n')
            if ~( isempty(queue) )
                for i = 1:n.cells
                    if cells(i).learn(t) == true
                        %update this location in the queue
                        if numel(queue(1).synCon) > 0
                            for j = 1:numel(queue(1).synCon)
                                if cells(queue(1).locations(j)).active(t-queue(1).index) == true
                                    [queue(1).perm(j), queue(1).synCon(j)] = update_s( queue(1).perm(j), queue(1).synCon(j), synThreshold, synInc );
                                else
                                    [queue(1).perm(j), queue(1).synCon(j)] = update_s( queue(1).perm(j), queue(1).synCon(j), synThreshold, synDec );
                                end
                            end
                           %adapt the old segment
                            cells(queue(1).cell).segs(queue(1).index).perm = queue(1).perm;
                            cells(queue(1).cell).segs(queue(1).index).synCon = queue(1).synCon;
                            %delete the segment from the queue
                            queue(1) = [];
                        elseif cells(i).state(t) == 0 && cells(i).state(t-1) == 2
                            %negatively reinforce the synapses for this loc in queue
                            [queue(1).perm, queue(1).synCon] = update_s( queue(1).perm, queue(1).synCon, synThreshold, synDec );
                           %adapt the old segment
                            cells(queue(1).cell).segs(queue(1).index).perm = queue(1).perm;
                            cells(queue(1).cell).segs(queue(1).index).synCon = queue(1).synCon;
                            %delete the segment from the queue
                            queue(1) = [];
                        end
                    end
                end
            end
        end
        %fprintf('Finished. \n\n')
    else
        %If NO temporal memory
        %fprintf('Temporal memory is OFF, skipping...\n')
    end
    %% Create output
    %fprintf('Creating output...\n')
    if n.cols > 0   %If columns were created
        %Make output, make sure to OR with the cells predicting
        output = [];
        for i = 1:n.cols
            if columns(i).active == true
                output = [output 1];
            else
                output = [output 0];
            end
        end
        
        prediction_loc = [];
        prediction = [];
        
        for i = 1:n.cells
            if temporal_memory
                if cells(i).state(t) == 2 %if the cell is predicting
                        prediction_loc = [prediction_loc,cells(i).col];
                end
            end
        end
        for i = 1:n.cols
            if any(prediction_loc == i) == 1
                prediction(i) = 1;
            else
                prediction(i) = 0;
            end
        end
    else
        %if there are no columns, the output is a -1
        output = -1;
    end
    segments = [];
    %fprintf('Complete.\n\n')
end