%show_active_columns.m
%Sam Gallagher
%17 February 2016
%
%This module visualizes the active columns over time, using the left and
%right arrow buttons for control.

function show_active_columns(n,active_columns,pred,tInitial,htm_time)
    
    myMap = [[0,0,0];[1,1,0];[0,1,0];[0,0,1]];
    hActive.n = n.cols;
    hActive.a = active_columns;
    hActive.pr = pred;
    hActive.t = tInitial; %Start the time at tInitial
    hActive.htmt = htm_time;
    hActive.tMax = n.time;
    hActive.delT = hActive.tMax - tInitial;
    hActive.title = ['Column array at t = ' num2str(hActive.htmt-hActive.tMax+hActive.t)];

    %% Create the image
    if max(active_columns) ~= 0
        activevisual = ones(1,hActive.n);
        for iter = transpose(hActive.a(:,hActive.t))
            if iter ~= 0
                if activevisual(1,iter) == 3
                    activevisual(1,iter) = 4;
                else
                    activevisual(1,iter) = 2;
                end
            end
        end
        for iter = 1:hActive.n
            if hActive.pr(iter,hActive.t) == 1
                if activevisual(1,iter) == 2
                    activevisual(1,iter) = 4;
                else
                    activevisual(1,iter) = 3;
                end
            end
        end
    else
        activevisual = ones(1,hActive.n);
    end
    activevisual = vec2mat(activevisual,ceil( sqrt(hActive.n) ) );

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
        for iter = 1:hActive.n
            if hActive.pr(iter,hActive.t) == 1
                if activevisual(1,iter) == 2
                    activevisual(1,iter) = 4;
                else
                    activevisual(1,iter) = 3;
                end
            end
        end
    else
        activevisual = ones(1,hActive.n);
    end
    activevisual = vec2mat(activevisual,ceil( sqrt( hActive.n ) ) );
    
    hActive.title = ['Column array at t = ' num2str(hActive.htmt-hActive.tMax+hActive.t)];
    set(h.img, 'CData', activevisual);
    title(hActive.title);
    setappdata(hObject,'active_handle',hActive);
    
    