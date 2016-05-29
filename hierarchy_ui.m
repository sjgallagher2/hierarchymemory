%hierarchy_ui.m
%Sam Gallagher
%9 March 2016
%
%This is the user interface for controlling the hierarchy

function [hierarchy,inputConfig] = hierarchy_ui(nRegions,send,inputConfig, en)
    f = figure();
    f.Visible = 'off';
    f.MenuBar = 'none';
    
    hierarchy = nRegions;
    
    data_size = size(send);
    data_size = data_size(1);
    
    hHierarchyLayers = uicontrol('style','popup','String',{'1','2','3','4','5'}, 'Position',[80,350,100,50],'Callback',@cbHLay);
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
    
    if en == false
        hLayerOne.Enable = 'off';
        hLayerTwo.Enable = 'off';
        hLayerThree.Enable = 'off';
        hLayerFour.Enable = 'off';
        hLayerFive.Enable = 'off';
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
        [synThreshold,synInc,synDec,nDendrites,minSegOverlap,nCols,desiredLocalActivity,...
        Neighborhood,inputRadius,boostInc,minActiveDuty,minOverlapDuty,nCells,...
        nSegs,LearningRadius,minOverlap] = user_control(size(send),1);
        
    %Create a user config vector to store all 'settings'-related stuff
        userConfig = [synThreshold;synInc;synDec;nDendrites;minSegOverlap;nCols;desiredLocalActivity;...
        Neighborhood;inputRadius;boostInc;minActiveDuty;minOverlapDuty;nCells;...
        nSegs;LearningRadius;minOverlap];
        
        inputConfig(:,1) = userConfig;
        
    end
    function cbTwo(hObject, evt)
        [synThreshold,synInc,synDec,nDendrites,minSegOverlap,nCols,desiredLocalActivity,...
        Neighborhood,inputRadius,boostInc,minActiveDuty,minOverlapDuty,nCells,...
        nSegs,LearningRadius,minOverlap] = user_control(size(send),2);
        
    %Create a user config vector to store all 'settings'-related stuff
        userConfig = [synThreshold;synInc;synDec;nDendrites;minSegOverlap;nCols;desiredLocalActivity;...
        Neighborhood;inputRadius;boostInc;minActiveDuty;minOverlapDuty;nCells;...
        nSegs;LearningRadius;minOverlap];
        
        inputConfig(:,2) = userConfig;
    end
    function cbThree(hObject, evt)
        [synThreshold,synInc,synDec,nDendrites,minSegOverlap,nCols,desiredLocalActivity,...
        Neighborhood,inputRadius,boostInc,minActiveDuty,minOverlapDuty,nCells,...
        nSegs,LearningRadius,minOverlap] = user_control(size(send),3);
        
    %Create a user config vector to store all 'settings'-related stuff
        userConfig = [synThreshold;synInc;synDec;nDendrites;minSegOverlap;nCols;desiredLocalActivity;...
        Neighborhood;inputRadius;boostInc;minActiveDuty;minOverlapDuty;nCells;...
        nSegs;LearningRadius;minOverlap];
        
        inputConfig(:,3) = userConfig;
        
    end
    function cbFour(hObject, evt)
        [synThreshold,synInc,synDec,nDendrites,minSegOverlap,nCols,desiredLocalActivity,...
        Neighborhood,inputRadius,boostInc,minActiveDuty,minOverlapDuty,nCells,...
        nSegs,LearningRadius,minOverlap] = user_control(size(send),4);
        
    %Create a user config vector to store all 'settings'-related stuff
        userConfig = [synThreshold;synInc;synDec;nDendrites;minSegOverlap;nCols;desiredLocalActivity;...
        Neighborhood;inputRadius;boostInc;minActiveDuty;minOverlapDuty;nCells;...
        nSegs;LearningRadius;minOverlap];
        
        inputConfig(:,4) = userConfig;
    end
    function cbFive(hObject, evt)
        [synThreshold,synInc,synDec,nDendrites,minSegOverlap,nCols,desiredLocalActivity,...
        Neighborhood,inputRadius,boostInc,minActiveDuty,minOverlapDuty,nCells,...
        nSegs,LearningRadius,minOverlap] = user_control(size(send),5);
        
    %Create a user config vector to store all 'settings'-related stuff
        userConfig = [synThreshold;synInc;synDec;nDendrites;minSegOverlap;nCols;desiredLocalActivity;...
        Neighborhood;inputRadius;boostInc;minActiveDuty;minOverlapDuty;nCells;...
        nSegs;LearningRadius;minOverlap]; 
        
        inputConfig(:,5) = userConfig;
    end

    function cbCancel(hObject,evt)
        hierarchy = nRegions;
        inputConfig = [];
        delete(f);
    end
    function cbOkay(hObject,evt)
        delete(f);
        hierarchy = nRegions;
        save config/config.htm inputConfig -ascii;
    end

waitfor(f);
end