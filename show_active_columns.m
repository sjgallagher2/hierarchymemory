%show_active_columns.m
%Sam Gallagher
%17 February 2016
%
%This module visualizes the active columns over time, using the left and
%right arrow buttons for control. Input active_columns is a column vector, over time (rows).

function show_active_columns(c,active_columns,pred,t_initial)
    
    myMap = [[0,0,0];[1,1,0];[0,1,0];[0,0,1]];
    hActive.n = c.columns;
    hActive.a = active_columns;
    hActive.pr = pred;
    hActive.t = t_initial; %Start the time at tInitial
    hActive.htmt = c.htm_time;
    hActive.tMax = c.seq_time;
    hActive.delT = hActive.tMax - t_initial;
    hActive.title = ['Column array at t = ' num2str(hActive.htmt-hActive.tMax+hActive.t)];

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
       
        for i = 1:hActive.n
            if hActive.pr(i,hActive.t) == 1
                if activevisual(1,i) == 2
                    activevisual(1,i) = 4;
                else
                    activevisual(1,i) = 3;
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
    activevisual = transpose(activevisual);
    
    
    hActive.title = ['Column array at t = ' num2str(hActive.htmt-hActive.tMax+hActive.t)];
    set(h.img, 'CData', activevisual);
    title(hActive.title);
    setappdata(hObject,'active_handle',hActive);
    
    