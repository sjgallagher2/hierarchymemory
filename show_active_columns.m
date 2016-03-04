%show_active_columns.m
%Sam Gallagher
%17 February 2016
%
%This module visualizes the active columns over time, using the left and
%right arrow buttons for control.

function show_active_columns(nCols,active_columns,tMax)
    
    myMap = [[0,0,0];[1,1,0]];
    hActive.n = nCols;
    hActive.a = active_columns;
    hActive.t = 1;
    hActive.tMax = tMax;
    hActive.title = ['t = ' num2str(hActive.t)];

    %% Create the image
    if max(active_columns) ~= 0
        activevisual = ones(1,nCols);
        for iter = transpose(hActive.a(:,hActive.t))
            if iter ~= 0
                activevisual(1,iter) = 2;
            end
        end
    else
        activevisual = ones(1,nCols);
    end
    activevisual = vec2mat(activevisual,ceil( sqrt(nCols ) ) );

    %% Display the image
    h.fig = figure;
    colormap(myMap);
    hold on;
    title(hActive.title);
    h.fig.MenuBar = 'none';

    h.img = image(activevisual);
    setappdata(h.fig,'active_handle',hActive);
    set(h.fig,'KeyPressFcn',@Keypress_callback);
    guidata(h.fig, h);
    
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
    
    hActive.title = ['t = ' num2str(hActive.t)];
    set(h.img, 'CData', activevisual);
    title(hActive.title);
    setappdata(hObject,'active_handle',hActive);
    
    