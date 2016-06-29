%show_cells.m
%Sam Gallagher
%25 June 2016
%
%A program to show the cell states over time

function show_cells(c, cells, t_initial)
    myMap = [[0,0,0];[1,1,0];[0,1,0];[0,0,1]];
    H.n = c.cellsPerCol*c.columns;
    H.cells = cells;
    H.t = t_initial;
    H.htmt = c.htm_time;
    H.tMax = c.seq_time;
    H.delT = H.tMax - H.t;
    H.title = ['Cells at t = ' num2str(H.htmt - H.tMax + H.t) ];
    H.show_active = true;
    H.show_pr = true;
    H.previous = false;
    
    vis = ones(1,H.n);
    for i = 1:H.n
        if cells(i).active(H.t) == true
            vis(1,i) = 2;
        end
    end
    vis = vec2mat(vis,ceil( sqrt(H.n) ));
    vis = transpose(vis);
    
    S.fig = figure('DefaultFigureWindowStyle','docked','Position',[300,200,800,500]);
    colormap(myMap);
    hold on;
    S.fig.MenuBar = 'none';
    
    S.img_space = subplot(1,4,[1:3]);
    S.img = image(vis);
    hold on;
    S.plot = subplot(1,4,[1:3]);
    title(H.title);
    S.plot.XTick = (0:ceil(sqrt(H.n) )) + 0.5;
    S.plot.YTick = (0:ceil(sqrt(H.n) )) + 0.5;
    S.plot.XTickLabel = [];
    S.plot.YTickLabel = [];
    S.plot.XGrid = 'on';
    S.plot.YGrid = 'on';
    hold on;
    
    S.check_space = subplot(1,4,4);
    S.check_space.XAxis.Visible = 'off';
    S.check_space.YAxis.Visible = 'off';
    hcheck_a = uicontrol(S.fig,'Style','checkbox','position',[605,410,15,15],'Value',1,'Callback',{@a_callback,H,S});
    hcheck_pr = uicontrol(S.fig,'Style','checkbox','position',[605,375,15,15],'Value',1,'Callback',{@pr_callback,H,S});
    hcheck_back = uicontrol(S.fig,'Style','checkbox','position',[605,340,15,15],'Value',0,'Callback',{@back_callback,H,S});
    hin_text = uicontrol(S.fig,'Style','text','position',[620,410,70,15],'String','Show activity','BackgroundColor','White');
    hpr_text = uicontrol(S.fig,'Style','text','String','Show prediction(s)','position',[620,375,100,15],'BackgroundColor','White');
    hback_text = uicontrol(S.fig,'Style','text','String','Show previous timestep','position',[620,330,100,30],'BackgroundColor','White');
    
    set(S.fig,'KeyPressFcn',{@Keypress_callback,H,S});
    set(S.fig,'WindowButtonDownFcn',@Mouseclick_callback);
    guidata(S.fig,{H,S});
end

function Mouseclick_callback(hObj, evt)
    handle = guidata(hObj);
    H = handle{1};
    cells =H.cells;
    handle = handle{2};
    t = H.htmt-H.tMax+H.t;
    
    %Get mouse position
    clickPoint = get(handle.img_space, 'CurrentPoint');
    xLim = get(handle.img,'XData');
    xLim = xLim(2);
    yLim = get(handle.img,'YData');
    yLim = yLim(2);
    
    cpy = ceil( clickPoint(1,1) - 0.5);
    cpx = ceil( clickPoint(1,2) - 0.5);
    
    %Highlight the cell
    if cpy > 0 && cpx > 0 && cpy <= yLim && cpx <= xLim
        %Set the colors
        myMap = [[0,0,0];[1.0,1,0];[0,1.0,0];[0,0,1];[0,0.5,0.5];[0.2,0.2,0.2];[0.6,0.6,0.1];[0.7,0,0]];
        colormap(myMap);
        %get data
        vis = get(handle.img,'CData');
        %If they've already selected something, erase it
        [prevSelX,prevSelY] = find(vis == 5);
        if numel(prevSelX > 0)
            cellPos = (prevSelY-1)*yLim+prevSelX;
            if cells(cellPos).active(t) == 1
                vis(prevSelX,prevSelY) = 2;
            else
                vis(prevSelX,prevSelY) = 1;
            end
        end
        
        vis(find(vis == 7)) = 1;
        vis(find(vis == 8)) = 1;
        
        %Highlight this cell (conditional)
        if numel(prevSelX) > 0
            %if there's something selected
            if ~( (cpx == prevSelX) && (cpy == prevSelY) )
                %if something new was selected, highlight
                vis(cpx,cpy) = 5;
                cellPos = (cpy-1)*yLim+cpx;
                highlightCell(H, handle,cells,cells(cellPos),t);
            end
        else
            %if this is the first thing to be selected, highlight
            vis(cpx,cpy) = 5;
            cellPos = (cpy-1)*yLim+cpx;
            highlightCell(H, handle, cells,cells(cellPos),t);
        end
        
        set(handle.img,'CData',vis);
    end
end

function a_callback(hObj,evt,H,S)
    disp('');
end

function pr_callback(hObj,evt,H,S)
    disp('');
end

function back_callback(hObj,evt,H,S)
    disp('');
end

function Keypress_callback(hObj,evt,H,S)

    switch evt.Key
        case 'rightarrow'
            inc = +1;
        case 'leftarrow'
            inc = -1;
        otherwise
            return;
    end
    updateImage(hObj,inc,H,S);
end

function updateImage(hObj,inc,H,S)
    H = guidata(S.fig);
    H = H{1};
    if H.t + inc > H.tMax
        H.t = 1;
    elseif H.t + inc < 1
        H.t = H.tMax;
    else
        H.t = H.t + inc;
    end
    
    vis = ones(1,H.n);
    for i = 1:H.n
        if H.cells(i).active(H.t) == true
            vis(1,i) = 2;
        end
    end
    vis = vec2mat(vis,ceil( sqrt(H.n) ));
    vis = transpose(vis);
    H.title = ['Cells at t = ' num2str(H.htmt-H.tMax+H.t)];
    set(S.img,'CData',vis);
    title(S.plot,H.title);
    guidata(S.fig,{H,S});
end

function clearInfo(hText)
    %clear all the text (set to invisible) for the elements of hText
    
end

function highlightCell(H,S,cells,myCell,t)
    %add UI elements describing cell to the check_space axes
    %cell information to show:
    %   Cell layer
    %   Cell column
    %   Number of segments in the cell
    %   Activity
    %   Prediction
    %   segment select dropdown
    %   highlight connections to cell segment synapses
    hCLText = uicontrol(S.fig,'Style','text','String',['Cell layer: ',num2str(myCell.layer)],'position',[620,250,100,30],'BackgroundColor',[0.8,0.8,0.8]);
    hCCText = uicontrol(S.fig,'Style','text','String',['Cell column: ',num2str(myCell.col)],'position',[620,230,100,30],'BackgroundColor',[0.8,0.8,0.8]);
    hNSegText = uicontrol(S.fig,'Style','text','String',['Segments in cell: ',num2str(numel(myCell.segs))],'position',[620,210,100,30],'BackgroundColor',[0.8,0.8,0.8]);
    hActiveText = uicontrol(S.fig,'Style','text','String',['Active: ',num2str(myCell.active(t))],'position',[620,190,100,30],'BackgroundColor',[0.8,0.8,0.8]);
    hPredictingText = uicontrol(S.fig,'Style','text','String',['Predicting: ',num2str(myCell.state(t) == 2)],'position',[620,170,100,30],'BackgroundColor',[0.8,0.8,0.8]);
    hSegSelectDropdown =uicontrol(S.fig,'Style','popupmenu','String',{'Select a segment',num2str(1:numel(myCell.segs))},'Position',[600,160,120,15],'Callback',@segCB);
    
    function segCB(hObj,evt)
        vis = get(S.img,'CData');
        vSz = size(vis,1);
        
        if hObj.Value > 1
            seg = hObj.Value-1;
            seg = myCell.segs(seg);
            for i = 1:numel(seg.locations)
                highlightLoc = [ceil(seg.locations(i)/vSz), mod(seg.locations(i),vSz)];
                if highlightLoc(2) == 0
                    %not sure why this is happening!
                    highlightLoc(2) = 21;
                end
                
                if seg.synCon(i) == 0
                    if cells(seg.locations(i)).active(t) == 1
                        vis(highlightLoc(2),highlightLoc(1)) = 8;
                    else
                        vis(highlightLoc(2),highlightLoc(1)) = 6;
                    end
                else
                    if cells(seg.locations(i)).active(t) == 1
                        vis(highlightLoc(2),highlightLoc(1)) = 8;
                    else
                        vis(highlightLoc(2),highlightLoc(1)) = 7;
                    end
                end
            end
        else
            %repair image
            updateImage(0,0,H,S);
            return;
        end
        set(S.img,'CData',vis);
        guidata(S.fig,{H,S});
    end
end