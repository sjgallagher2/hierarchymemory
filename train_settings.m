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

function [temporal_memory, spatial_pooler, tmdelay] = train_settings(tm,sp,tmd)
    f = figure('Visible','off','Position',[500,300,280,180]);
    
    hTM = uicontrol('style','checkbox','position',[30,140,15,15],'value',tm,'Callback',@tmCB);
    hSP = uicontrol('style','checkbox','position',[30,100,15,15],'value',sp);
    hTMdelay = uicontrol('style','edit','position',[24,65,30,20],'String',num2str(tmd));
    
    hTMtext = uicontrol('style','text','position',[60,140,150,20],'String','Run temporal memory');
    hSPtext = uicontrol('style','text','position',[60,100,150,20],'String','Run spatial pooler');
    hTMdelay_text = uicontrol('style','text','position',[80,65,150,20],'String','Temporal memory delay (steps)');
    
    hOkayButton = uicontrol('style','pushbutton','String','Okay','position',[90,10,40,20],'Callback',@okayCB);
    hCancelButton = uicontrol('style','pushbutton','String','Cancel','position',[140,10,40,20],'Callback',@cancelCB);
    
    if ~tm
        hTMdelay.Visible = 'off';
        hTMdelay_text.Visible = 'off';
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
        if i == 0
            hTMdelay_text.Visible = 'off';
            hTMdelay.Visible = 'off';
        else
            hTMdelay_text.Visible = 'on';
            hTMdelay.Visible = 'on';
        end
    end
    waitfor(f);
end