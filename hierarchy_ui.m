%hierarchy_ui.m
%Sam Gallagher
%9 March 2016
%
%This is the user interface for controlling the hierarchy
%Input is the number of active regions, the array of region configs, and an
%enable

function [hierarchy,c] = hierarchy_ui(nRegions,c, en)
    f = figure();
    f.Visible = 'off';
    f.MenuBar = 'none';
    if c(1).inputRadius == 0 && en
        c(1).inputRadius = c(1).data_size;
    end
    if c(1).LearningRadius == 0 && en
        c(1).LearningRadius = c(1).data_size;
    end
    if ~c(1).spatial_pooler
        c(1).columnPercent = 1;
    end
    if ~c(1).temporal_memory
        
    end
    hierarchy = nRegions; %hierarchy is the output number of regions,
    %nRegions is the number of regions we started with
    
    hHierarchyLayers = uicontrol('style','popup','String',{'1','2','3','4','5'}, 'Position',[80,350,100,50],'Callback',@cbHLay,'Value',nRegions);
    hHierarchyLabel = uicontrol('style','text','String','Hierarchy Layers ','Position',[20,353,50,50]);
    hLayerOne = uicontrol('style','pushbutton','String','Layer 1','Position',[50,30,450,40],'Callback',@cbOne);
    hLayerTwo = uicontrol('style','pushbutton','String','Layer 2','Position',[100,100,350,40],'Visible','off','Callback',@cbTwo);
    hLayerThree = uicontrol('style','pushbutton','String','Layer 3','Position',[150,170,250,40],'Visible','off','Callback',@cbThree);
    hLayerFour = uicontrol('style','pushbutton','String','Layer 4','Position',[200,240,150,40],'Visible','off','Callback',@cbFour);
    hLayerFive = uicontrol('style','pushbutton','String','Layer 5','Position',[250,310,50,40],'Visible','off','Callback',@cbFive);
    hCancel = uicontrol('style','pushbutton','String','Cancel','Position',[400,10,50,20],'Callback',@cbCancel);
    hOkay = uicontrol('style','pushbutton','String','Okay','Position',[450,10,50,20],'Callback',@cbOkay);
    
    if nRegions == 2
        hLayerTwo.Visible = 'on';
        hLayerThree.Visible = 'off';
        hLayerFour.Visible = 'off';
        hLayerFive.Visible = 'off';
    elseif nRegions == 3
        hLayerTwo.Visible = 'on';
        hLayerThree.Visible = 'on';
        hLayerFour.Visible = 'off';
        hLayerFive.Visible = 'off';
    elseif nRegions == 4
        hLayerTwo.Visible = 'on';
        hLayerThree.Visible = 'on';
        hLayerFour.Visible = 'on';
        hLayerFive.Visible = 'off';
    elseif nRegions == 5
        hLayerTwo.Visible = 'on';
        hLayerThree.Visible = 'on';
        hLayerFour.Visible = 'on';
        hLayerFive.Visible = 'on';
    end
    
    hLayerTwo.Enable = 'off';
    hLayerThree.Enable = 'off'; %these turn on once you set the others
    hLayerFour.Enable = 'off';
    hLayerFive.Enable = 'off';
    
    if en == false
        hLayerOne.Enable = 'off';
    else
        hLayerOne.Enable = 'on';
    end
    f.Visible = 'on';
    set(f,'CloseRequestFcn',@cbCancel);
    
    function cbHLay(hObject, evt)
        if hHierarchyLayers.Value == 1
            hLayerTwo.Visible = 'off';
            hLayerThree.Visible = 'off';
            hLayerFour.Visible = 'off';
            hLayerFive.Visible = 'off';
            
            hierarchy = 1;
        elseif hHierarchyLayers.Value == 2
            hLayerTwo.Visible = 'on';
            hLayerThree.Visible = 'off';
            hLayerFour.Visible = 'off';
            hLayerFive.Visible = 'off';
            
            hierarchy = 2;
            
        elseif hHierarchyLayers.Value == 3
            hLayerTwo.Visible = 'on';
            hLayerThree.Visible = 'on';
            hLayerFour.Visible = 'off';
            hLayerFive.Visible = 'off';
            
            hierarchy = 3;
            
        elseif hHierarchyLayers.Value == 4
            hLayerTwo.Visible = 'on';
            hLayerThree.Visible = 'on';
            hLayerFour.Visible = 'on';
            hLayerFive.Visible = 'off';
            
            hierarchy = 4;
            
        elseif hHierarchyLayers.Value == 5
            hLayerTwo.Visible = 'on';
            hLayerThree.Visible = 'on';
            hLayerFour.Visible = 'on';
            hLayerFive.Visible = 'on';
            
            hierarchy = 5;
        end
    end
    function cbOne(hObject, evt)
        c(1) = user_control(c(1));
        c(1) = updateConfigPercentages(c(1));
        c(2).data_size = c(1).columns;
        hLayerTwo.Enable = 'on';
    end
    function cbTwo(hObject, evt)
        c(2) = user_control(c(2));
        c(2) = updateConfigPercentages(c(2));
        c(3).data_size = c(2).columns;
        hLayerThree.Enable = 'on';
    
    end
    function cbThree(hObject, evt)
        c(3) = user_control(c(3));
        c(3) = updateConfigPercentages(c(3));
        c(4).data_size = c(3).columns;
        hLayerFour.Enable = 'on';
        
    end
    function cbFour(hObject, evt)
        c(4) = user_control(c(4));
        c(4) = updateConfigPercentages(c(4));
        c(5).data_size = c(4).columns;
        hLayerFive.Enable = 'on';
    end
    function cbFive(hObject, evt)
        c(5) = user_control(c(5));
        c(5) = updateConfigPercentages(c(5));
    end

    function cbCancel(hObject,evt)
        hierarchy = nRegions;
        c = [];
        delete(f);
    end
    function cbOkay(hObject,evt)
        delete(f);
        %Save the config updates to the XML file    TODO
    end

waitfor(f);
end