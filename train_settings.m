%training_settings.m
%Sam Gallagher
%30 May 2016
%
%Module for changing various machine training settings
%Parameters are:
%   -Temporal memory (checkbox/togglebutton) and text
%   -Spatial pooler (checkbox/togglebutton) and text
%   -Temporal memory delay (edit/slider) and text
%   -Apply (pushbutton)
%   -Cancel (pushbutton)


function c = train_settings(c)
    f = figure('Visible','off','Position',[500,300,280,200]);
    
    tm_init = c.temporal_memory;
    sp_init = c.spatial_pooler;
    tmdelay_init = c.TM_delay;
    reps_init = c.reps;
    
    hTM = uicontrol('style','checkbox','position',[30,170,15,15],'value',c.temporal_memory,'Callback',@tmCB);
    hSP = uicontrol('style','checkbox','position',[30,130,15,15],'value',c.spatial_pooler,'Callback',@tmCB);
    hTMdelay = uicontrol('style','edit','position',[24,95,30,20],'String',num2str(c.TM_delay));
    hRep = uicontrol('style','edit','position',[24,60,30,20],'String',num2str(c.reps));
    
    hTMtext = uicontrol('style','text','position',[60,170,150,20],'String','Run temporal memory');
    hSPtext = uicontrol('style','text','position',[60,130,150,20],'String','Run spatial pooler');
    hTMdelay_text = uicontrol('style','text','position',[80,95,150,20],'String','Temporal memory delay (steps)');
    hRepText = uicontrol('style','text','position',[80,60,150,20],'String','Reptitions of data sequence');
    
    hOkayButton = uicontrol('style','pushbutton','String','Okay','position',[90,10,40,20],'Callback',@okayCB);
    hCancelButton = uicontrol('style','pushbutton','String','Cancel','position',[140,10,40,20],'Callback',@cancelCB);
    
    if ~c.temporal_memory
        hTMdelay.Enable = 'off';
    end
    
    f.Name = 'Training settings';
    f.Visible = 'on';
    
    function okayCB(hObject,evt)
        if get(hTM,'value') == 1
            c.temporal_memory = true;
        else
            c.temporal_memory = false;
        end
        if get(hSP,'value') == 1
            c.spatial_pooler = true;
        else
            c.spatial_pooler = false;
        end
        c.TM_delay = floor( str2num(get(hTMdelay,'string')) );
        c.reps = floor( str2num(get(hRep,'string')) );
        
        close();
    end
    function cancelCB(hObject,evt)
        c.temporal_memory = tm_init;
        c.spatial_pooler= sp_init;
        c.TM_delay = tmdelay_init;
        c.reps = reps_init;
        
        close();
    end
    function tmCB(hObject,evt)
        i = get(hTM,'Value');
        j = get(hSP,'Value');
        if i == 0
            hTMdelay.Enable = 'off';
        end
        if j == 1 && i ==1
            hTMdelay.Enable = 'on';
        end
    end
    waitfor(f);
end