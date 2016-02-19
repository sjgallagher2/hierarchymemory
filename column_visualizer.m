%column_visualizer.m
%Sam Gallagher
%17 Feb 2016
%
%This module visualizes the given column in a grid figure. The column is
%highlighted in yellow, the active connected synapses in red, and inactive
%connected synapses in grey.

function column_visualizer(input, columns, nCols)
    columnControl.c = 1;
    columnControl.data = columns;
    columnControl.n = nCols;
    columnControl.in = input;
    visualVec = transpose(input(:,1));
    testColumn = columns(:,:,columnControl.c);
    fprintf('C: %d \n',columnControl.c)
    
    visual = create_visual(visualVec,testColumn,input);

    myMap = [[1,1,1];[0,0,0];[1,0,0];[0.5,0.5,0.5];[1,1,0]];
    
    handle.fig = figure;
    colormap(myMap);
    hold on;
    handle.img = image(visual)
    
    setappdata(handle.fig,'c',columnControl);
    setappdata(handle.fig,'vec',visualVec);
    
    set(handle.fig,'KeyPressFcn',@Keypress_callback);
    guidata(handle.fig, handle);
    
    
 function v = create_visual(visualVec, testColumn, input)
    testColumnSize = size(testColumn);
    data_size = size(input);

    for iter = 1:testColumnSize(1)
        if testColumn(iter,3) == 1
            if input(testColumn(iter,1),1) > 0
                %because of duplicates, changing 1's to 2's changes overlap
                visualVec(testColumn(iter,1)) = 2;
            elseif input(testColumn(iter,1),1) == 0
                visualVec(testColumn(iter,1)) = 3;
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
     
 function updateCol(hObject, inc)
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
    
    fprintf('C: %d \n',columnControl.c)
    
    testColumn = columnControl.data(:,:,columnControl.c);
    visual = create_visual(visualVec,testColumn, columnControl.in);
    set(handle.img,'CData',visual);
    setappdata(handle.fig,'c',columnControl);