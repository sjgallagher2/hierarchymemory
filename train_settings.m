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
%
%REMOVE, ADD TO TAB IN OTHER SETTINGS

function [temporal_memory, spatial_pooler, tmdelay, rep] = train_settings(tm,sp,tmd,reps)
    f = figure('Visible','off','Position',[500,300,280,200]);
    
    hTM = uicontrol('style','checkbox','position',[30,170,15,15],'value',tm,'Callback',@tmCB);
    hSP = uicontrol('style','checkbox','position',[30,130,15,15],'value',sp,'Callback',@tmCB);
    hTMdelay = uicontrol('style','edit','position',[24,95,30,20],'String',num2str(tmd));
    hRep = uicontrol('style','edit','position',[24,60,30,20],'String',num2str(reps));
    
    hTMtext = uicontrol('style','text','position',[60,170,150,20],'String','Run temporal memory');
    hSPtext = uicontrol('style','text','position',[60,130,150,20],'String','Run spatial pooler');
    hTMdelay_text = uicontrol('style','text','position',[80,95,150,20],'String','Temporal memory delay (steps)');
    hRepText = uicontrol('style','text','position',[80,60,150,20],'String','Reptitions of data sequence');
    
    hOkayButton = uicontrol('style','pushbutton','String','Okay','position',[90,10,40,20],'Callback',@okayCB);
    hCancelButton = uicontrol('style','pushbutton','String','Cancel','position',[140,10,40,20],'Callback',@cancelCB);
    
    if ~tm
        hTMdelay.Enable = 'off';
    end
    
    f.Name = 'Training settings';
    f.Visible = 'on';
    
    function okayCB(hObject,evt)
        if get(hTM,'value') == 1
            temporal_memory = true;
        else
            temporal_memory = false;
        end
        if get(hSP,'value') == 1
            spatial_pooler = true;
        else
            spatial_pooler = false;
        end
        tmdelay = floor( str2num(get(hTMdelay,'string')) );
        rep = floor( str2num(get(hRep,'string')) );
        
        close();
    end
    function cancelCB(hObject,evt)
        temporal_memory = true;
        spatial_pooler = true;
        tmdelay = 0;
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