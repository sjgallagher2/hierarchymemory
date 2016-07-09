%generate_input.m
%Sam Gallager
%12 Feb 2016
%
%This UI module prompts the user for drawing details

function in = generate_input(dataSz,type)
    f = figure('Visible','off','Position',[500,300,300,240]);
    
    sparsity = 0.9;
    in = [];
    
    hInputSzEdit = uicontrol('style','edit','String','12','position',[180,160,30,20]);
    hTimeSzEdit = uicontrol('style','edit','String','1','position',[180,200,30,20]);
    hInputSzText = uicontrol('style','text','String','What size image will you be making? (n x n)' ...
        ,'position',[10,160,140,26]);
    hTimeSzText = uicontrol('style','text','String','How many time frames?','position',[20,200,140,20]);
    hSeqText = uicontrol('style','text','String','Sequence?','position',[90,125,60,20]);
    hSeqCheck = uicontrol('style','checkbox','Value',0,'position',[180,130,15,15],'Callback',@seqCB);
    hSeqText = uicontrol('style','text','String','Sequence repetitions:               1','position',[10,100,200,20]);
    hSeqNum = uicontrol('style','edit','String','1','position',[180,100,30,20],'Visible','off');
    hOkayButton = uicontrol('style','pushbutton','String','Okay','position',[90,10,40,20],'Callback',@okayCB);
    hCancelButton = uicontrol('style','pushbutton','String','Cancel','position',[140,10,40,20],'Callback',@cancelCB);
    
    if strcmp(type,'rand') == true
        hSparsityText = uicontrol('style','text','String','Sparisty (recommended >0.9)','position',[10,70,140,20]);
        hSparsitySlide = uicontrol('style','slider','Min',0.01,'Max',1.0,'position',[150,70,100,20],'value',0.95,'Callback',@sparseCB);
        hSparsityShow = uicontrol('style','text','String',' = 0.95','position',[250,60,40,30]);
    end
    
    f.Name = 'Generate input';
    f.Visible = 'on';
    
    function okayCB(hObject,evt)
        inputSz = str2num(get(hInputSzEdit,'String'));
        timeSz = str2num(get(hTimeSzEdit,'String'));
        rep = str2num(get(hSeqNum,'String'));
        close();
        if dataSz > 0
            if (inputSz^2) == dataSz
                if strcmp(type,'draw') == true
                    in = blackandwhiteimage(inputSz,timeSz);
                elseif strcmp(type,'rand') == true
                    in = randomdata(sparsity,inputSz,timeSz);
                end
                if rep > 1
                    s = in;
                    for i = 1:rep-1
                        in = [s in];
                    end
                end
            else
                msgbox('Error: Data size has to stay consistent in order for the columns to be properly assigned.','warn','Error');
                in = [];
            end
        else
            if strcmp(type,'draw') == true
                in = blackandwhiteimage(inputSz,timeSz);
            elseif strcmp(type,'rand') == true
                in = randomdata(sparsity,inputSz,timeSz);
            end
            if rep > 1
                s = in;
                for i = 1:rep-1
                    in = [s in];
                end
            end
        end
    end
    function cancelCB(hOBject,evt)
        in = 0;
        close();
    end
    function seqCB(hObject,evt)
        %change edit box visibility
        b = get(hSeqCheck,'Value');
        if b == 0
            hSeqNum.Visible = 'off';
        elseif b == 1
            hSeqNum.Visible = 'on';
        end
    end
    function sparseCB(hObject,evt)
        sparsity = get(hObject, 'Value');
        hSparsityShow.String = [' = ',num2str(sparsity)];
    end

    waitfor(f);
end
