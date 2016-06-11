%show_input_sequence.m
%Sam Gallagher
%17 February 2016
%
%This module visualizes the active columns over time, using the left and
%right arrow buttons for control. Input active_columns is a column vector, over time (rows).

function show_input_sequence(input_data)
    if numel(input_data) > 0
        active_input = zeros(size(input_data,1),size(input_data,2));
        for j = 1:size(input_data,2)
            slot = 1;
            for i = 1:size(input_data,1)
                if input_data(i,j) == 1
                    active_input(slot,j) = i;
                    slot = slot+1;
                end
            end
        end

        myMap = [[0,0,0];[1,1,0];[0,1,0];[0,0,1]];
        hActive.n = size(input_data,1);
        hActive.a = active_input; %active locations for input
        hActive.t = 1; %Start the time at tInitial
        hActive.tMax = size(active_input,2);
        hActive.delT = hActive.tMax - 1;
        hActive.title = ['Input array at t = 1'];

        %% Create the image
        if max(hActive.a) ~= 0
            activevisual = ones(1,hActive.n);
            for i = 1:numel(hActive.a(:,hActive.t))
                if hActive.a(i,hActive.t) ~= 0
                    if activevisual( 1,hActive.a(i,hActive.t) ) == 3
                        activevisual( 1,hActive.a(i,hActive.t) ) = 4;
                    else
                        activevisual( 1,hActive.a(i,hActive.t) ) = 2;
                    end
                end
            end
        else
            activevisual = ones(1,hActive.n);
        end

        activevisual = vec2mat(activevisual,ceil( sqrt(hActive.n) ) );
        activevisual = transpose(activevisual);
        %% Display the image
        h.fig = figure('DefaultFigureWindowStyle','docked');
        colormap(myMap);
        hold on;
        title(hActive.title);
        h.fig.MenuBar = 'none';

        h.img = image(activevisual);
        hold on;
        h.plot = subplot(1,1,1);
        h.plot.XTick = (0:ceil(sqrt(hActive.n) )) + 0.5;
        h.plot.YTick = (0:ceil(sqrt(hActive.n) )) + 0.5;
        h.plot.XTickLabel = [];
        h.plot.YTickLabel = [];
        h.plot.XGrid = 'on';
        h.plot.YGrid = 'on';

        setappdata(h.fig,'active_handle',hActive);
        set(h.fig,'KeyPressFcn',@Keypress_callback);
        guidata(h.fig, h);
    else
        msgbox('No input data to show.');
    end
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
     updateActive(hObject,inc);
     
function updateActive(hObject, inc)
    h = guidata(hObject);
    hActive = getappdata(hObject,'active_handle');
    
    if hActive.t + inc > hActive.tMax
        hActive.t = 1;
    elseif hActive.t + inc < 1
        hActive.t = hActive.tMax;
    else
        hActive.t = hActive.t+inc;
    end
    
    if max(hActive.a) ~= 0
        activevisual = ones(1,hActive.n);
        for iter = transpose(hActive.a(:,hActive.t))
            if iter ~= 0
                activevisual(1,iter) = 2;
            end
        end
    else
        activevisual = ones(1,hActive.n);
    end
    
    activevisual = vec2mat(activevisual,ceil( sqrt( hActive.n ) ) );
    activevisual = transpose(activevisual);
    
    
    hActive.title = ['Input array at t = ' num2str(hActive.t)];
    set(h.img, 'CData', activevisual);
    title(hActive.title);
    setappdata(hObject,'active_handle',hActive);
    