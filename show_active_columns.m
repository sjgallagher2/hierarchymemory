%show_active_columns.m
%Sam Gallagher
%17 February 2016
%
%This module visualizes the active columns over time, using the left and
%right arrow buttons for control. Input active_columns is a column vector, over time (rows).

function show_active_columns(c,active_columns,pred,t_initial)
    
    
    myMap = [[0,0,0];[1,1,0];[0,1,0];[0,0,1];[0.3,0.3,0.3];[0,0.3,0.2]];
    hActive.n = c.columns;
    hActive.a = active_columns;
    hActive.pr = pred;
    hActive.t = t_initial; %Start the time at tInitial
    hActive.htmt = c.htm_time;
    hActive.tMax = c.seq_time;
    hActive.delT = hActive.tMax - t_initial;
    hActive.title = ['Column array at t = ' num2str(hActive.htmt-hActive.tMax+hActive.t)];
    hActive.show_in = true;
    hActive.show_pr = true;
    hActive.previous = false;

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
    h.fig = figure('DefaultFigureWindowStyle','docked','Position',[300,200,800,500]);
    colormap(myMap);
    hold on;
    h.fig.MenuBar = 'none';
    
    h.img_space = subplot(1,4,[1:3]);
    h.img = image(activevisual); %,'Parent',h.img_space
    hold on;
    h.plot = subplot(1,4,[1:3]);
    title(hActive.title);
    h.plot.XTick = (0:ceil(sqrt(hActive.n) )) + 0.5;
    h.plot.YTick = (0:ceil(sqrt(hActive.n) )) + 0.5;
    h.plot.XTickLabel = [];
    h.plot.YTickLabel = [];
    h.plot.XGrid = 'on';
    h.plot.YGrid = 'on';
    hold on;
    
    h.check_space = subplot(1,4,4);
    h.check_space.XAxis.Visible = 'off';
    h.check_space.YAxis.Visible = 'off';
    hcheck_in = uicontrol(h.fig,'Style','checkbox','position',[605,410,15,15],'Value',1,'Callback',{@in_callback,hActive,h});
    hcheck_pr = uicontrol(h.fig,'Style','checkbox','position',[605,375,15,15],'Value',1,'Callback',{@pr_callback,hActive,h});
    hcheck_back = uicontrol(h.fig,'Style','checkbox','position',[605,340,15,15],'Value',0,'Callback',{@back_callback,hActive,h});
    hin_text = uicontrol(h.fig,'Style','text','position',[620,410,70,15],'String','Show input','BackgroundColor','White');
    hpr_text = uicontrol(h.fig,'Style','text','String','Show prediction(s)','position',[620,375,100,15],'BackgroundColor','White');
    hback_text = uicontrol(h.fig,'Style','text','String','Show previous timestep','position',[620,330,100,30],'BackgroundColor','White');
    
    set(h.fig,'KeyPressFcn',{@Keypress_callback,hActive,h});
    guidata(h.fig,hActive);
end

function in_callback(hObj, evt, hActive,h)
    hActive = guidata(h.fig);
    if get(hObj,'Value') == 1
        hActive.show_in = true;
    else
        hActive.show_in = false;
    end
    guidata(h.fig,hActive);
    updateActive(hObj,0,hActive,h);
end
function pr_callback(hObj,evt,hActive,h)
    hActive = guidata(h.fig);
    if get(hObj,'Value') == 1
        hActive.show_pr = true;
    else
        hActive.show_pr = false;
    end
    guidata(h.fig,hActive);
    updateActive(hObj,0,hActive,h);
end
function back_callback(hObj,evt,hActive,h)
    hActive = guidata(h.fig);
    if get(hObj,'Value') == 1
        hActive.previous = true;
    else
        hActive.previous = false;
    end
    guidata(h.fig,hActive);
    updateActive(hObj,0,hActive,h);
end
function Keypress_callback(hObject, evt,hActive,h)
     switch evt.Key
        case 'rightarrow'
            inc = +1 ;
        case 'leftarrow'
            inc = -1 ;
        otherwise
            % do nothing
            return ;
     end
     updateActive(hObject,inc,hActive,h);
end
     
function updateActive(hObject, inc, hActive,h)
    hActive = guidata(h.fig);
    if hActive.t + inc > hActive.tMax
        hActive.t = 1;
    elseif hActive.t + inc < 1
        hActive.t = hActive.tMax;
    else
        hActive.t = hActive.t+inc;
    end

    if max(hActive.a) ~= 0
        activevisual = ones(1,hActive.n);
        if hActive.show_in == true
            %Take care of the previous timestep first so it can be
            %overriden
            if hActive.previous && hActive.t > 1
                for iter = transpose(hActive.a(:,hActive.t-1))
                    if iter ~= 0
                        activevisual(1,iter) = 5;
                    end
                end
            end
            %Now do current timestep
            for iter = transpose(hActive.a(:,hActive.t))
                if iter ~= 0
                    activevisual(1,iter) = 2;
                end
            end
        end
        %Now do predictions, checking if something is active already
        for iter = 1:hActive.n
            if hActive.show_pr == true
                if hActive.pr(iter,hActive.t) == 1
                    if activevisual(1,iter) == 2
                        activevisual(1,iter) = 4;
                    elseif activevisual(1,iter) == 5
                        activevisual(1,iter) = 6;
                    else
                        activevisual(1,iter) = 3;
                    end
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
    title(h.plot,hActive.title);
    guidata(h.fig,hActive);
end