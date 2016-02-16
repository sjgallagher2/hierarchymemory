%region.m
%Sam Gallagher
%15 February
%
%This function manages a region that is given an input. The input must
%consist of all data to-be-input in columns, with each column representing
%a time step. Random inputs can be generated to test functionality with the
%generate_input.m file. Output is an OR of the active and predictive cells.

function output = region(input)
    %To begin, run the user_control panel
    [synThreshold,synInc,synDec,nDendrites,minSegOverlap,nCols,desiredLocalActivity,Neighborhood,inputRadius,boostInc,minActiveDuty,minOverlapDuty,nCells,nSegs,LearningRadius] = user_control();
    
    %Getting our sizes straight.
    data_size = size(input);
    nCols = floor(nCols*data_size(1));
    nDendrites = floor(nDendrites*data_size(1));
    
    %With all the user-defined variables for this region in place, generate
    %a vector of proximal segments. 
    columns = zeros(nDendrites,3,nCols);
    for iter = 1:nCols
        columns(:,:,iter) = make_proximal_segment(nDendrites,inputRadius, data_size(1), iter,synThreshold);
    end
    
    columnOverlaps = zeros(data_size(2), nCols);
    %Now we'll go into a time-step loop
    for t = 1:data_size(2)
        
        %For each timestep, compute the overlap for each column.
        for c = 1:nCols
            columnOverlaps(t,c) = compute_overlap(input(:,t),columns(:,:,c),0,1);
        end
    end
    
    %Now I'll visualize the goings-on with image() using black, white, and
    %red squares to represent the data in 10x10 grids
    visual = transpose(input(:,1));
    testColumn = columns(:,:,1);
    testColumnSize = size(testColumn);
    testColumnOverlap = 0;
    myMap = [[1,1,1];[0,0,0];[1,0,0];[0.5,0.5,0.5]];
    
    figure 
    hold on
    colormap(myMap);
    image(vec2mat(visual,10)+1)
    
    for iter = 1:testColumnSize(1)
        if testColumn(iter,3) == 1
            if input(testColumn(iter,1),1) > 0
                %because of duplicates, changing 1's to 2's changes overlap
                testColumnOverlap = testColumnOverlap+1;
                visual(testColumn(iter,1)) = 2;
            elseif input(testColumn(iter,1),1) == 0
                visual(testColumn(iter,1)) = 3;
            end
        end
    end
    visual = vec2mat(visual,10)+1;
    
    figure;
    colormap(myMap);
    hold on;
    image(visual)
    
    
end
