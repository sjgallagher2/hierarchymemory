%generate_input.m
%Sam Gallager
%12 Feb 2016
%
%This function generates a random input to work with an HTM CLA learning
%algorithm designed either in matlab or elsewhere. The output is saved in a
%file with the extension .htm

function in = generate_input()
    f = figure('Visible','off','Position',[500,300,280,180]);
    
    hInputSzEdit = uicontrol('style','edit','String','12','position',[180,100,30,20]);
    hTimeSzEdit = uicontrol('style','edit','String','1','position',[180,140,30,20]);
    hInputSzText = uicontrol('style','text','String','What size image will you be making? (n x n)' ...
        ,'position',[10,100,140,26]);
    hTimeSzText = uicontrol('style','text','String','How many time frames?','position',[20,140,140,20]);
    hSeqText = uicontrol('style','text','String','Sequence?','position',[90,65,60,20]);
    hSeqCheck = uicontrol('style','checkbox','Value',0,'position',[180,70,15,15],'Callback',@seqCB);
    hSeqText = uicontrol('style','text','String','Sequence repetitions:               1','position',[10,40,200,20]);
    hSeqNum = uicontrol('style','edit','String','1','position',[180,40,30,20],'Visible','off');
    hOkayButton = uicontrol('style','pushbutton','String','Okay','position',[90,10,40,20],'Callback',@okayCB);
    hCancelButton = uicontrol('style','pushbutton','String','Cancel','position',[140,10,40,20],'Callback',@cancelCB);
    
    f.Name = 'Generate input';
    f.Visible = 'on';
    
    function okayCB(hObject,evt)
        inputSz = str2num(get(hInputSzEdit,'String'));
        timeSz = str2num(get(hTimeSzEdit,'String'));
        rep = str2num(get(hSeqNum,'String'));
        close();
        in = blackandwhiteimage(inputSz,timeSz);
        
        if rep > 1
            s = in;
            for i = 1:rep-1
                in = [s in];
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

    waitfor(f);
end
