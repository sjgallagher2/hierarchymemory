%column_visualizer.m
%Sam Gallagher
%17 Feb 2016
%
%This module visualizes the given column in a grid figure. The column is
%highlighted in yellow, the active connected synapses in red, and inactive
%connected synapses in grey.

function column_visualizer(input, columns, nCols, time)
    %% Define a struct to hold data easily
    columnControl.c = 1;
    columnControl.n = nCols;
    columnControl.in = input;
    columnControl.t = time;
    columnControl.d = columns;
    columnControl.title = ['t = ', num2str(columnControl.t), ',  c = ', num2str(columnControl.c)];
    
    %% Create the image
    visualVec = transpose(input(:,columnControl.t));
    testColumn = columnControl.d(columnControl.c);
    
    visual = create_visual(visualVec,testColumn,input, columnControl.t);
    
    %% Display the image, handle application data
    myMap = [[1,1,1];[0,0,0];[1,0,0];[0.5,0.5,0.5];[1,1,0]];
    
    handle.fig = figure('position',[100, 50, 600,500]);
    colormap(myMap);
    hold on;
    handle.img = image(visual)
    title(columnControl.title);
    
    setappdata(handle.fig,'c',columnControl);
    setappdata(handle.fig,'vec',visualVec);
    
    set(handle.fig,'KeyPressFcn',@Keypress_callback);
    guidata(handle.fig, handle);
    
%% Create an image matrix from the data
 function v = create_visual(visualVec, testColumn, input, time)
    testColumnSize = numel(testColumn.locations);
    data_size = size(input);

    for iter = 1:testColumnSize
        if testColumn.synCon(iter) == 1
            if input(testColumn.locations(iter),time) > 0
                %because of duplicates, changing 1's to 2's changes overlap
                visualVec(testColumn.locations(iter)) = 2;
            elseif input(testColumn.locations(iter)) == 0
                visualVec(testColumn.locations(iter)) = 3;
            end
        end
    end

    v = vec2mat(visualVec,ceil( sqrt(data_size(1) ) ) )+1;
 function Keypress_callback(hObject, evt)
     switch evt.Key
        case 'rightarrow'
            inc = +1 ;
        case 'leftarrow'
            inc = -1 ;
        otherwise
            % do nothing
            return ;
     end
     updateCol(hObject,inc);
     
 function updateCol(hObject, inc, time)
    handle = guidata(hObject);
    columnControl = getappdata(handle.fig, 'c');
    visualVec = getappdata(handle.fig,'vec');
    if columnControl.c+inc > columnControl.n
        columnControl.c = 1;
        
    elseif columnControl.c+inc < 1
        columnControl.c = columnControl.n;
    else
        columnControl.c = columnControl.c + inc;
    end
    
    testColumn = columnControl.d(columnControl.c);
    visual = create_visual(visualVec,testColumn, columnControl.in, columnControl.t);
    columnControl.title = ['t = ', num2str(columnControl.t), ',  c = ', num2str(columnControl.c)];
    title(columnControl.title);
    set(handle.img,'CData',visual);
    setappdata(handle.fig,'c',columnControl);