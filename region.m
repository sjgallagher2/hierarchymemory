%region.m
%Sam Gallagher
%15 February
%
%This function manages a region that is given an input. The input must
%consist of all data to-be-input in columns, with each column representing
%a time step. Random inputs can be generated to test functionality with the
%generate_input.m file. Output is an OR of the active and predictive cells.

function output = region(input)
    %% To begin, run the user_control panel
    [synThreshold,synInc,synDec,nDendrites,minSegOverlap,nCols,desiredLocalActivity,Neighborhood,inputRadius,boostInc,minActiveDuty,minOverlapDuty,nCells,nSegs,LearningRadius] = user_control(size(input));
    
    %Getting our sizes straight.
    data_size = size(input);
    nCols = floor(nCols*data_size(1));
    nDendrites = floor(nDendrites*data_size(1));
    
    %% With all the user-defined variables for this region in place, generate
    %a vector of proximal segments. 
    columns = zeros(nDendrites,3,nCols);
    for iter = 1:nCols
        %How is the column center selected? To select a center, we need to
        %account for the fact that nCols < data_size. We can multiply each
        %column center then, by the inverse of nCols. For
        %example, with 100 input bits and 30 columns, column 1 will have
        %its center at position 1/30th of the way into the input, at
        %100*(1/30), and taking the floor.
        colCenter = floor(data_size(1)*(iter/nCols));
        columns(:,:,iter) = make_proximal_segment(nDendrites,inputRadius, data_size(1), colCenter,synThreshold);
    end
    
    columnOverlaps = zeros(data_size(2), nCols);
    
    numberOfHoods = ceil(nCols/Neighborhood);
    activeColumns = zeros(numberOfHoods*desiredLocalActivity, data_size(2)); %Prepare the active columns, which exist over time
    
    %% Now we'll go into a time-step loop
    for t = 1:data_size(2)
        %For each timestep, find overlaps for the columns
        for c = 1:nCols
            columnOverlaps(t,c) = compute_overlap(input(:,t),columns(:,:,c),0,1);
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
        for iter = 0:numberOfHoods-1
            start = Neighborhood*(iter)+1;
            stop = min(start+(Neighborhood-1),nCols); %make sure it doesn't go over the max ncols
            n = columnOverlaps(t,start:stop);
            tempA = transpose(inhibit_cols(n,desiredLocalActivity)+start-1);
            k = (iter)*desiredLocalActivity+1;
            activeColumns(k:k+desiredLocalActivity-1,t) = tempA;
        end

        %Now, what if the neighborhoods overlapped each other at each
        %point? What change in the total number of active columns selected
        %will we see?
        %activeColumns2 = 0;
        %for colCenter = 1:nCols
        %    start = max(colCenter - Neighborhood/2, 1);
        %    stop = min(colCenter + Neighborhood/2, nCols);
        %    n = columnOverlaps(t,start:stop);
        %    activeColumns2 = [inhibit_cols(n,desiredLocalActivity)+start, activeColumns2];
        %end
        %activeColumns2 = unique(activeColumns2(activeColumns2 ~= 0));
        %sort(activeColumns2);

        %% Use active columns to update synapses
        for c = transpose(activeColumns(:,t))
            %Column structure: columns( index,inputloc/synapseperm/connected, col )
            %This loop checks if a synapse is connected, and updates it
            %based on whether or not it is, for every position in the
            %column c
            for i = 1:nDendrites
                if columns(i,3,c) == 1
                    if columns(i,1,c) == 1
                        columns(i,2:3,c) = update_s(columns(i,2:3,c),synThreshold,synInc);
                    else
                        columns(i,2:3,c) = update_s(columns(i,2:3,c),synThreshold,-synDec);
                    end
                end
            end
        end
    end
    %% Visualize our data
    column_visualizer(input, columns, nCols,1);
    show_active_columns(nCols,activeColumns,data_size(2));
    
end