%update_region.m
%Sam Gallagher
%14 March 2016
%
%Parameters: A list of column structures, a list of cell structures, the
%input data, an N structure, a list of seg structures, and region-config params
%Outputs: List of column structures, list of cell structures, an N
%structure, the active columns list, a list of segment structures, and the region output
%Runs through a time-step of the CLA using a given

function [columns, cells, prediction,nActive, output,activeColumns, queue,cPreds] = update_region(columns,cells,segment,data,c,t,hoods,queue,dbg)
    activeColumns = [];
    cPreds = 0;
    if c.region == 1
        dbg(['Time = ',num2str(t)]);
    end
    dbg(['Region: ',num2str(c.region)]);
    if c.spatial_pooler == true
        dbg('Starting spatial pooler...');
        %For each timestep, find overlaps for the columns and reset
        %activity and sums
        dbg('Calculating overlaps...');
        for n = 1:c.columns
            columns(n).active = 0;
            columns(n).overlap = compute_overlap(data,columns(n),c.minOverlap);
            if columns(n).overlap > 0
                columns(n).overlapSum = columns(n).overlapSum + 1; %update rolling sum
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
        dbg('Selecting active columns...');
        for iter = 0:hoods-1
            start = c.Neighborhood*(iter)+1;
            stop = min(start+(c.Neighborhood-1),c.columns); %make sure it doesn't go over the max ncols
            o = [ columns(start:stop).overlap ];

            w = inhibit_cols(o,c.desiredLocalActivity);
            if w == -1
                tempA = -1;
            else
                tempA = transpose(w+start-1);
            end

            for n = 1:c.columns
                if(any( n == tempA ))
                    columns(n).active = 1;
                    columns(n).activeSum = columns(n).activeSum+1;%update rolling sum
                end
            end
        end

        %Now, what if the neighborhoods overlapped each other at each
        %point? What change in the total number of active columns selected
        %will we see?
        %activeColumns2 = 0;
        %for colCenter = 1:c.columns
        %    start = max(colCenter - Neighborhood/2, 1);
        %    stop = min(colCenter + Neighborhood/2, c.columns);
        %    n = columnOverlaps(t,start:stop);
        %    activeColumns2 = [inhibit_cols(n,desiredLocalActivity)+start, activeColumns2];
        %end
        %activeColumns2 = unique(activeColumns2(activeColumns2 ~= 0));
        %sort(activeColumns2);

        %% Use active columns to update synapses

        %This loop checks if a synapse is connected, and updates it
        %based on whether or not it is, for every position in the
        %column c
        dbg('Updating synapses...');
        for n = 1:c.columns
            if columns(n).active
                for i = 1:c.nDendrites
                    if columns(n).synCon(i) == 1
                        if data(columns(n).locations(i)) == 1
                            %There were assignment issues here, replacing
                            %synCon
                            [columns(n).perm(i) columns(n).synCon(i)] = update_s(columns(n).perm(i),columns(n).synCon(i), c.synThreshold,c.synInc);
                        else
                            [columns(n).perm(i) columns(n).synCon(i)] = update_s(columns(n).perm(i),columns(n).synCon(i), c.synThreshold,c.synDec);
                        end
                    end
                end
            end
            %Update the minimum active duty cycle to meet before being
            %boosted. 1% of the max active duty cycle in the neighborhood
            minActiveDuty = 0.01*max( [columns( max(1,(n-c.Neighborhood/2)):min(c.columns,(n+c.Neighborhood/2)) ).actDuty] );

            %update the duty cycles for activity and overlaps-above-minimum
            columns(n).actDuty = columns(n).activeSum / t;
            columns(n).oDuty = columns(n).overlapSum / t;

            if columns(n).actDuty < c.minActiveDuty
                columns(n).boost = columns(n).boost + c.boostInc;
            end

            if columns(n).oDuty < c.minOverlapDuty
                %increase all synapse permanences by 0.1*synapse threshold
                for i = 1:c.nDendrites
                    columns(n).perm(i) = columns(n).perm(i)+0.1*c.synThreshold;
                end
            end
        end
        w = find_active_columns(columns,c.columns);
        nActive = size(w);
        nActive = nActive(2);
        if ~(isempty(w))
            activeColumns(1:nActive,1) = w;
        end
        if ~isempty(activeColumns)
            dbg('Active columns: ');
            dbg(activeColumns(:,1));
            dbg('Done.');
        end
    else
        %If NO spatial pooler
        dbg('Spatial pooler is OFF, skipping...');
        nActive = 0;
        activeColumns = [];
        for i = 1:c.data_size
            if data(i) == 1
                activeColumns = [activeColumns, i];
                columns(i).active = true;
                nActive = nActive + 1;
            else
                columns(i).active = false;
            end
        end
        activeColumns = activeColumns';
        dbg('Active columns: ');
        for j = 1:nActive
            dbg(num2str(activeColumns(j)));
        end
        dbg('Done.');
    end
    %% Now Update our cells for the temporal memory

    %For active columns, check if cells were predictive, set them
    %active
    %If none were predictive, bursting occurs
    
    %Then use the active CELLS to find new predictive cells
    
    %Finally, update synapses
    
    if c.temporal_memory == true
        dbg('Starting temporal memory...');
        
        for i = 1:c.columns
            for j = 1:c.cellsPerCol
                c_loc = getcell_loc(j,i,c);
                mycell = cells(c_loc);
                mycell.active(t) = 0;
                mycell.state(t) = 0;
                cells(c_loc) = mycell;
            end
        end
        dbg('Selecting active cells...');
        for i = 1:c.columns %for ALL columns, active and inactive
            celloutput = [];
            ncells = c.cellsPerCol*c.columns;
            columns(i).burst = false;
            
            if isempty( find(activeColumns == i) )
                %% Inactive column process
                %Just tie up loose ends, update cells
                columns(i).learning_cell = -1;
                for j = 1:c.cellsPerCol
                    %for all cells in the inactive column
                    loc = getcell_loc(j,i,c); %j is the cell layer, i is the cell column
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
                for j = 1:c.cellsPerCol
                    loc = getcell_loc(j,i,c);
                    mycell = cells( loc );
                    if t > 1
                        if mycell.state(t-1) == 2 %if cell was predicting, and is now in an active column
                            mycell.state(t) = 1;
                            mycell.active(t) = 1;
                            
                            %record accurate predictions
                            for s = 1:numel(mycell.segs)
                                if mycell.segs(s).active(t-1) == true
                                    cPreds = cPreds+1;
                                    mycell.segs(s).correct(t) = true;
                                    dbg(['Cell ',num2str(mycell.layer),' in column ',num2str(mycell.col),' made an accurate prediction.']);
                                end
                            end
                            
                            columns(i).active_cell = j;
                            dbg(['Cell ',num2str(mycell.layer),' in column ',num2str(mycell.col),' is active.']);
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
                    dbg(['Column ',num2str(i),' is bursting.']);
                    for j = 1:c.cellsPerCol
                        loc = getcell_loc(j,i,c);
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
            
        for i = 1:c.columns
            if ~isempty( find(activeColumns == i) )
                if t > 1
                    if columns(i).learning_cell == -1
                        %select most active cell, or one that has the fewest
                        %segments
                        [columns(i).learning_cell, fewestSegs] = getBestMatchingCell(i,cells,c,t); 
                        loc = getcell_loc(columns(i).learning_cell, i, c);
                        mycell = cells( loc );
                        dbg(['Best cell is cell ',num2str(mycell.layer),' for column ',num2str(mycell.col),'. It is the learning cell.']);
                        mycell.mknewseg = fewestSegs; %fewestSegs is a boolean indicating whether or not 
                        % the best cell was found. We only select by fewest
                        % number of segments if no cell had a segment that
                        % matched
                        
                        if numel(mycell.segs) == c.maxSegs
                            mycell.mknewseg = false; %Make sure the cell can only add as many segments as allowed
                        end

                        %%%%%%%%%%%%%%%   LEARNING CELL
                        mycell.learn(t) = true;
                        %This learning cell was selected because it was
                        %next in order, had the fewest segments, or had a
                        %well matched segment
                        
                        if mycell.mknewseg == true
                            dbg(['Adding a new segment to cell ', num2str(mycell.layer),' in column ', num2str(mycell.col),' to time t-', num2str(mycell.nseg+1)]);
                            mycell.segs = [mycell.segs, segment]; %add a blank segment
                            %label its index and cell
                            mycell.nseg = mycell.nseg + 1;
                            
                            mycell.segs( mycell.nseg ).cell = loc;
                            mycell.segs( mycell.nseg ).index = mycell.nseg;
                            %give that cell a segment with the active cells from
                            %the previous timestep.
                            [mycell.segs( mycell.nseg ).locations mycell.segs( mycell.nseg ).perm mycell.segs( mycell.nseg ).synCon]...
                                = make_distal_segment(c,i,cells, ncells,t - 1);
                            
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
        dbg('Finding predictive cells...');
        for i = 1:ncells
            activeSeg = getActiveSeg(cells(i), cells,t,false);
            if activeSeg > 0
                cells(i).segs(activeSeg).active(t) = 1;
                
                %uncomment these lines if you want to ONLY see predictions
                %a certain number of time steps ahead, while still making
                %segments for other predictions
                
                %if cells(i).segs(activeSeg).index == 1
                    %cells(i).state(t) = 2;
                %end
                cells(i).state(t) = 2;
                
                dbg(['    Segment ',num2str(activeSeg),' is active on cell ', num2str(cells(i).layer),' in column ', num2str(cells(i).col)]);
                queue = [queue, cells(i).segs(activeSeg)];
            end
            %add the best match from last time step too for this cell
            if cells(i).active(t) == true
                bestSeg = getBestMatchingSeg(cells(i),cells,t);
                if numel(bestSeg) > 0
                    dbg(['Best matching segment(s) for cell ',num2str(cells(i).layer), ' in column ',num2str(cells(i).col), ' could have been: ']);
                    dbg(bestSeg);
                    queue = [queue, cells(i).segs(bestSeg)];
                end
            end
        end
        %Predictions from predictions
        %This part uses the calculated predictions to attempt to calculate
        %many steps ahead. This can get confusing when some connections are
        %changing or flipping back and forth while others are strong,
        %because you may see some cells predicting very far into the
        %future, and others not even predicting the next time step.
        for i = 1:ncells
            if false
                activeSeg = getActiveSeg(cells(i),cells,t,true);
                if activeSeg > 0
                    cells(i).segs(activeSeg).active(t) = 1;
                    cells(i).state(t) = 2;
                    dbg(['    Segment ',num2str(activeSeg),' is active on cell ', num2str(cells(i).layer),' in column ', num2str(cells(i).col)]);
                    queue = [queue, cells(i).segs(activeSeg)];
                    %update the segment in the queue
                    for j = 1:numel(queue)
                        if queue(j).cell == i
                            queue(j) = cells(i).segs(activeSeg);
                        end
                    end
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
        
        %This is not working at the moment. The queue must last multiple
        %time steps, and the 'remove the first' concept is not working
        %properly. Fix to come. 
        if t > 1
            dbg('Updating synapses...');
            if ~( isempty(queue) )
                for i = 1:ncells
                    if cells(i).learn(t) == true
                        %update this location in the queue
                        for j = 1:numel(queue)
                            if j <= numel(queue)
                                if queue(j).cell == i
                                    for s = 1:numel(queue(j).synCon)
                                        if cells(queue(j).locations(s)).active(t-1) == true
                                            %if cell is active, update +
                                            [queue(j).perm(s), queue(j).synCon(s)] = update_s( queue(j).perm(s), queue(j).synCon(s), c.synThreshold, c.synInc );
                                        %else
                                            %[queue(j).perm(s), queue(j).synCon(s)] = update_s( queue(j).perm(s), queue(j).synCon(s), c.synThreshold, c.synDec );
                                        end
                                    end
                                    cells(queue(j).cell).segs(queue(j).index).perm = queue(j).perm;
                                    cells(queue(j).cell).segs(queue(j).index).synCon = queue(j).synCon;
                                    %delete the segment from the queue
                                    queue(j) = [];
                                end
                            end
                        end
                    elseif cells(i).state(t) == 0 && cells(i).state(t-1) == 2
                        %negatively reinforce the synapses for this loc in queue
                        for j = 1:numel(queue)
                            if j <= numel(queue)
                                if queue(j).cell == i
                                    for s = 1:numel(queue(j).synCon)
                                        [queue(j).perm(s), queue(j).synCon(s)] = update_s( queue(j).perm(s), queue(j).synCon(s), c.synThreshold, c.synDec );
                                    end
                                   %adapt the old segment
                                    cells(queue(j).cell).segs(queue(j).index).perm = queue(j).perm;
                                    cells(queue(j).cell).segs(queue(j).index).synCon = queue(j).synCon;
                                    %delete the segment from the queue
                                    queue(j) = [];
                                end
                            end
                        end
                    end
                end
            end
        end
        dbg('Finished.');
    else
        %If NO temporal memory
        dbg('Temporal memory is OFF, skipping...');
    end
    %% Create output
    dbg('Creating output...');
    if c.columns > 0   %If columns were created
        %Make output, make sure to OR with the cells predicting
        output = [];
        for i = 1:c.columns
            if columns(i).active == true
                output = [output 1];
            else
                output = [output 0];
            end
        end
        
        prediction_loc = [];
        prediction = [];
        
        for i = 1:c.columns*c.cellsPerCol
            if c.temporal_memory
                if cells(i).state(t) == 2 %if the cell is predicting
                        prediction_loc = [prediction_loc,cells(i).col];
                end
            end
        end
        for i = 1:c.columns
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
    segment = [];
    if c.region == 2
        dbg('Time step complete.');
        dbg('');
    end
end