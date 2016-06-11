%user_control.m
%Sam Gallagher
%13 Feb 2016
%
%This function will be the home-base point for all user-controlled
%variables, and as such it may be somewhat involved. A GUI is used for the
%user to manage many settings at once. Options are:
%synThreshold               slider
%synInc                     slider
%synDec                     slider
%nDendrites                 slider, percentage
%minSegOverlap              edit box
%nCols                      slider, percentage
%desiredLocalActivity       edit box
%Neighborhood               edit box
%inputRadius                edit box
%boostInc                   slider
%minActiveDuty              slider, percentage
%minOverlapDuty             slider, percentage
%nCells                     edit box
%nSegs                      edit box
%LearningRadius             edit box
%
%Constraints:
%The input radius must be > nDendrites
%The variable c is a SINGLE config object, for only this region.

function c = user_control(c)
    f = figure('Visible','off','color','white','Position',[360,500,600,300]);
    
    %min and max values for sliders
    minOverlapDutyMin = 0;
    minOverlapDutyMax = 100;
    
    minActiveDutyMin = 0;
    minActiveDutyMax = 100;
    
    boostIncMin = 0.01;
    boostIncMax = 20;
    
    nColsMin = 0;
    nColsMax = 100;
    
    nDendritesMin = 0; %Percentage of given space
    nDendritesMax = 99;
    
    threshMin = 0.01;
    threshMax = 0.99;
    
    incMinValue = 0.01;
    incMaxValue = 0.30;
    
    decMinValue = 0.01;
    decMaxValue = 0.30;
    
    %slider handles
    perm_slidehandle = uicontrol('Style','slider','Position',[10,270,100,15],'Min',threshMin,'Max',threshMax,'Callback',@permslidecallback,'Value',c.synThreshold);
    inc_slidehandle = uicontrol('Style','slider','Position',[10,240,100,15],'Min',incMinValue,'Max',incMaxValue,'Callback',@incslidecallback,'Value',c.synInc);
    dec_slidehandle = uicontrol('Style','slider','Position',[10,210,100,15],'Min',decMinValue,'Max',decMaxValue,'Callback',@decslidecallback,'Value',-c.synDec);
    nDendrites_slidehandle = uicontrol('Style','slider','Min',nDendritesMin,'Max',nDendritesMax,'Value',c.dendritePercent*100,'Position',[10,180,100,15],'Callback',@dendriteslidecallback);
    nCols_slidehandle = uicontrol('Style','slider','Min',nColsMin,'Max',nColsMax,'Value',c.columnPercent*100,'Position',[10,150,100,15],'Callback',@ncolslidecallback);
    boostInc_slidehandle = uicontrol('Style','slider','Min',boostIncMin,'Max',boostIncMax,'Value',c.boostInc,'Position',[10,120,100,15],'Callback',@boostincslidecallback);
    minActiveDuty_slidehandle = uicontrol('Style','slider','Min',minActiveDutyMin,'Max',minActiveDutyMax*100,'Value',c.minActiveDuty,'Position',[10,90,100,15],'Callback',@minactiveslidecallback);
    minOverlapDuty_slidehandle = uicontrol('Style','slider','Min',minOverlapDutyMin,'Max',minOverlapDutyMax*100,'Value',c.minOverlapDuty,'Position',[10,60,100,15],'Callback',@minoverslidecallback);
    
    %Min and max text handles
    handlepermmintext = uicontrol('Style','text','BackgroundColor','white','Position',[1,285,30,15],'String',num2str(threshMin));
    handlepermmaxtext = uicontrol('Style','text','BackgroundColor','white','Position',[100,285,30,15],'String',num2str(threshMax)); 
    
    handleincmintext = uicontrol('Style','text','BackgroundColor','white','Position',[1,255,30,15],'String',num2str(incMinValue));
    handleincmaxtext = uicontrol('Style','text','BackgroundColor','white','Position',[100,255,30,15],'String',num2str(incMaxValue)); 
    
    handledecmintext = uicontrol('Style','text','BackgroundColor','white','Position',[1,225,30,15],'String',num2str(decMinValue));
    handledecmaxtext = uicontrol('Style','text','BackgroundColor','white','Position',[100,225,30,15],'String',num2str(decMaxValue)); 
    
    handlenDendritemintext = uicontrol('Style','text','BackgroundColor','white','Position',[1,195,30,15],'String',num2str(nDendritesMin));
    handlenDendritemaxtext = uicontrol('Style','text','BackgroundColor','white','Position',[100,195,30,15],'String',num2str(nDendritesMax));
    
    handlenColsmintext = uicontrol('Style','text','BackgroundColor','white','Position',[1,165,30,15],'String',num2str(nColsMin));
    handlenColsmaxtext = uicontrol('Style','text','BackgroundColor','white','Position',[100,165,30,15],'String',num2str(nColsMax));
    
    handleboostIncmintext = uicontrol('Style','text','BackgroundColor','white','Position',[1,135,30,15],'String',num2str(boostIncMin));
    handleboostIncmaxtext = uicontrol('Style','text','BackgroundColor','white','Position',[100,135,30,15],'String',num2str(boostIncMax));
     
    handleminActivemintext = uicontrol('Style','text','BackgroundColor','white','Position',[1,105,30,15],'String',num2str(minActiveDutyMin));
    handleminActivemaxtext = uicontrol('Style','text','BackgroundColor','white','Position',[100,105,30,15],'String',num2str(minActiveDutyMax));
    
    handleminOverlapmintext = uicontrol('Style','text','BackgroundColor','white','Position',[1,75,30,15],'String',num2str(minOverlapDutyMin));
    handleminOverlapmaxtext = uicontrol('Style','text','BackgroundColor','white','Position',[100,75,30,15],'String',num2str(minOverlapDutyMax));
    
    %Edit box handles
    handlepermcurrentvalue = uicontrol('Style','edit','BackgroundColor','white','Position',[120,270,50,15],'Visible','on','String',num2str(c.synThreshold),'Callback',@permeditcallback);
    handleinccurrentvalue = uicontrol('Style','edit','BackgroundColor','white','Position',[120,240,50,15],'Visible','on','String',num2str(c.synInc),'Callback',@inceditcallback);
    handledeccurrentvalue = uicontrol('Style','edit','BackgroundColor','white','Position',[120,210,50,15],'Visible','on','String',num2str(-c.synDec),'Callback',@deceditcallback);
    handledendritecurrentvalue = uicontrol('Style','edit','BackgroundColor','white','Position',[120,180,50,15],'Visible','on','String',num2str(c.dendritePercent*100),'Callback',@dendriteeditcallback);
    handlecolcurrentvalue = uicontrol('Style','edit','BackgroundColor','white','Position',[120,150,50,15],'Visible','on','String',num2str(c.columnPercent*100),'Callback',@ncolseditcallback);
    handleboostinccurrentvalue = uicontrol('Style','edit','BackgroundColor','white','Position',[120,120,50,15],'Visible','on','String',num2str(c.boostInc),'Callback',@boostinceditcallback);
    handleminactivecurrentvalue = uicontrol('Style','edit','BackgroundColor','white','Position',[120,90,50,15],'Visible','on','String',num2str(c.minActiveDuty*100),'Callback',@minactiveeditcallback);
    handleminoverlapcurrentvalue = uicontrol('Style','edit','BackgroundColor','white','Position',[120,60,50,15],'Visible','on','String',num2str(c.minOverlapDuty*100),'Callback',@minoverlapeditcallback);
    handleminsegcurrentvalue = uicontrol('Style','edit','BackgroundColor','white','Position',[120,30,50,15],'Visible','on','String',num2str(c.minSegOverlap));
    handledesiredlocalcurrentvalue = uicontrol('Style','edit','BackgroundColor','white','Position',[320,270,50,15],'Visible','on','String',num2str(c.desiredLocalActivity),'Callback',@desiredlocaleditcallback);
    handleneighborhoodcurrentvalue = uicontrol('Style','edit','BackgroundColor','white','Position',[320,240,50,15],'Visible','on','String',num2str(c.Neighborhood),'Callback',@neighborhoodeditcallback);
    handleinputradiuscurrentvalue = uicontrol('Style','edit','BackgroundColor','white','Position',[320,210,50,15],'Visible','on','String',num2str(c.inputRadius), 'Callback',@inputradiuseditcallback);
    handlecellscurrentvalue = uicontrol('Style','edit','BackgroundColor','white','Position',[320,180,50,15],'Visible','on','String',num2str(c.cellsPerCol),'Callback',@ncellseditcallback);
    handlesegscurrentvalue = uicontrol('Style','edit','BackgroundColor','white','Position',[320,150,50,15],'Visible','on','String',num2str(c.maxSegs));
    handlelearningradiuscurrentvalue = uicontrol('Style','edit','BackgroundColor','white','Position',[320,120,50,15],'Visible','on','String',num2str(c.LearningRadius),'Callback',@learningradiuseditcallback);
    handleminocurrentvalue = uicontrol('Style','edit','BackgroundColor','white','Position',...
        [320,90,50,15],'String',num2str(c.minOverlap));
    
    %Label box handles
    handlepermLabel = uicontrol('Style','text','BackgroundColor','white',...
        'Position',[170,270,100,15],'String','Synapse Threshold');
    handleIncLabel = uicontrol('Style','text','BackgroundColor','white',...
        'Position',[170,240,100,15],'String','Synapse Inc');
    handleDecLabel = uicontrol('Style','text','BackgroundColor','white',...
        'Position',[170,210,100,15],'String','Synapse Dec');
    handlenDendriteLabel = uicontrol('Style','text','BackgroundColor','white',...
        'Position',[170,180,100,15],'String','N of Dendrites(%)');
    handlenColsLabel = uicontrol('Style','text','BackgroundColor','white',...
        'Position',[170,150,100,15],'String','N of Cols (%)');
    handleboostIncLabel = uicontrol('Style','text','BackgroundColor','white',...
        'Position',[170,120,100,15],'String','Boost Inc');
    handleminActiveLabel = uicontrol('Style','text','BackgroundColor','white',...
        'Position',[170,90,100,15],'String','Min Active Duty(%)');
    handleminOverlapLabel = uicontrol('Style','text','BackgroundColor','white',...
        'Position',[170,60,100,15],'String','Min Overlap Duty(%)');
    handleminSegLabel = uicontrol('Style','text','BackgroundColor','white',...
        'Position',[170,30,120,15],'String','Minimum Seg Overlap');
    handledesiredLocalLabel = uicontrol('Style','text','BackgroundColor','white',...
        'Position',[370,270,130,15],'String','Desired Local Activity');
    handleNeighbordhoodLabel = uicontrol('Style','text','BackgroundColor','white',...
        'Position',[370,240,100,15],'String','Neighborhood');
    handleinputRadiusLabel = uicontrol('Style','text','BackgroundColor','white',...
        'Position',[380,210,150,15],'String','Input Radius (col to input map)');
    handlenCellsLabel = uicontrol('Style','text','BackgroundColor','white',...
        'Position',[385,180,50,15],'String','N of Cells');
    handlenSegsLabel = uicontrol('Style','text','BackgroundColor','white',...
        'Position',[380,150,100,15],'String','N of Segs per Cell');
    handleLearningRadiusLabel = uicontrol('Style','text','BackgroundColor','white',...
        'Position',[385,120,140,15],'String','Learning Radius (cell to cols)');
    handleMinoLabel = uicontrol('Style','text','BackgroundColor','white',...
        'Position',[385,90,140,15],'String','Minimum Overlap for Columns');
    
    %make an APPLY button
    handleapply = uicontrol('Style','pushbutton','String','Apply','Position',...
        [420,20,70,20],'Callback',@applycallback);
    
    %If spatial pooling is off, disable these parameters
    if c.spatial_pooler == false
        nCols_slidehandle.Enable = 'off';
        nCols_slidehandle.String = '100';
        boostInc_slidehandle.Enable = 'off';
        minActiveDuty_slidehandle.Enable = 'off';
        minOverlapDuty_slidehandle.Enable = 'off';
        handlecolcurrentvalue.Enable = 'off';
        handlecolcurrentvalue.String = '100';
        handleboostinccurrentvalue.Enable = 'off';
        handleminactivecurrentvalue.Enable = 'off';
        handleminoverlapcurrentvalue.Enable = 'off';
        handledesiredlocalcurrentvalue.Enable = 'off';
        handleminocurrentvalue.Enable = 'off';
    end
    %If temporal memory is off, disable these parameters
    if c.temporal_memory == false
        handleinputradiuscurrentvalue.Enable = 'off';
        handlecellscurrentvalue.Enable = 'off';
        handlesegscurrentvalue.Enable = 'off';
        handlelearningradiuscurrentvalue.Enable = 'off';
        handleminsegcurrentvalue.Enable = 'off';
    end
    
    %Finalize the box on display
    set(f,'Name','Properties')
    set(f,'CloseRequestFcn',@cancelcallback);
    movegui(f,'center')
    set(f,'Visible','on')
    
    %Callbacks for Synapse Permanence
    function permslidecallback(hObject,eventdata)
        %set the editbox to the slider value
        num = get(perm_slidehandle,'Value');
        set(handlepermcurrentvalue,'String',num2str(num));
    end
    function permeditcallback(hObject,eventdata)
        %set the slider value to the editbox
        num = get(handlepermcurrentvalue,'String');
        set(perm_slidehandle,'Value',str2double(num));
    end

    %Callbacks for synapseInc
    function incslidecallback(hObject,eventdata)
        %set the editbox to the slider value
        num = get(inc_slidehandle,'Value');
        set(handleinccurrentvalue,'String',num2str(num));
    end
    function inceditcallback(hObject,eventdata)
        %set the slider value to the editbox
        num = get(handleinccurrentvalue,'String');
        set(inc_slidehandle,'Value',str2double(num));
    end

    %Callbacks for synapseDec
    function decslidecallback(hObject,eventdata)
        %set the editbox to the slider value
        num = get(dec_slidehandle,'Value');
        set(handledeccurrentvalue,'String',num2str(num));
    end
    function deceditcallback(hObject,eventdata)
        %set the slider value to the editbox
        num = get(handledeccurrentvalue,'String');
        set(dec_slidehandle,'Value',str2double(num));
    end

    %Callbacks for nDendrites
    function dendriteslidecallback(hObject,eventdata)
        %set the editbox to the slider value
        num = get(nDendrites_slidehandle,'Value');
        set(handledendritecurrentvalue,'String',num2str(num));
        
        num = str2num( get(handledendritecurrentvalue,'String') );
        c.nDendrites = c.data_size*num*0.01;
        c.inputRadius = str2double(get(handleinputradiuscurrentvalue,'String'));
        if c.inputRadius < c.nDendrites
            %error: the column must be able to find enough potential
            %connections to the input, so either the number of dendrites or the
            %input radius must increase
            error = msgbox('Error: Not enough dendrite space. The column must be able to find enough potential synapses to the input. Either the number of dendrites or the input radius must increase. A minimum input radius has been selected, but this is not recommended.','Error','warn');
            waitfor(error);
            c.inputRadius = c.nDendrites;
            set(handleinputradiuscurrentvalue,'String',num2str(c.nDendrites) );
        end
    end
    function dendriteeditcallback(hObject,eventdata)
        %set the slider value to the editbox
        num = get(handledendritecurrentvalue,'String');
        set(c.nDendrites_slidehandle,'Value',str2double(num));
        c.nDendrites = c.data_size*num*0.01;
        c.inputRadius = str2double(get(handleinputradiuscurrentvalue,'String'));
        if c.inputRadius < c.nDendrites
            %error: the column must be able to find enough potential
            %connections to the input, so either the number of dendrites or the
            %input radius must increase
            error = msgbox('Error: Not enough dendrite space. The column must be able to find enough potential synapses to the input. Either the number of dendrites or the input radius must increase. A minimum input radius has been selected, but this is not recommended.','Error','warn');
            waitfor(error);
            c.inputRadius = c.nDendrites;
            set(handleinputradiuscurrentvalue,'String',num2str(c.nDendrites) );
        end
    end

    %Callbacks for nCols
    function ncolslidecallback(hObject,eventdata)
        %set the editbox to the slider value
        num = get(nCols_slidehandle,'Value');
        set(handlecolcurrentvalue,'String',num2str(num));
    end
    function ncolseditcallback(hObject,eventdata)
        %set the slider value to the editbox
        num = get(handlecolcurrentvalue,'String');
        set(nCols_slidehandle,'Value',str2double(num));
    end

    %Callbacks for boostInc
    function boostincslidecallback(hObject,eventdata)
        %set the editbox to the slider value
        num = get(boostInc_slidehandle,'Value');
        set(handleboostinccurrentvalue,'String',num2str(num));
    end
    function boostinceditcallback(hObject,eventdata)
        %set the slider value to the editbox
        num = get(handleboostinccurrentvalue,'String');
        set(boostInc_slidehandle,'Value',str2double(num));
    end
        

    %Callbacks for minActiveDutyCycle
    function minactiveslidecallback(hObject,eventdata)
        %set the editbox to the slider value
        num = get(minActiveDuty_slidehandle,'Value');
        set(handleminactivecurrentvalue,'String',num2str(num));
    end
    function minactiveeditcallback(hObject,eventdata)
        %set the slider value to the editbox
        num = get(handleminactivecurrentvalue,'String');
        set(minActiveDuty_slidehandle,'Value',str2double(num));
    end

    %Callbacks for minOverlapDutyCycle
    function minoverslidecallback(hObject,eventdata)
        %set the editbox to the slider value
        num = get(minOverlapDuty_slidehandle,'Value');
        set(handleminoverlapcurrentvalue,'String',num2str(num));
    end
    function minoverlapeditcallback(hObject,eventdata)
        %set the slider value to the editbox
        num = get(handleminoverlapcurrentvalue,'String');
        set(minOverlapDuty_slidehandle,'Value',str2double(num));
    end

    function desiredlocaleditcallback(hObject,eventdata)
        desiredLocalActivity = str2double( get(handledesiredlocalcurrentvalue, 'String') );
        if desiredLocalActivity > Neighborhood
            error = msgbox('Error: Desired local activity is too large. The desired local activity should be less than the size of the neighborhood. A maximum desired local activity equal to the neighborhood size has been selected. This is not recommended.','Error','warn');
            waitfor(error);
            c.desiredLocalActivity = c.Neighborhood;
        end
    end

    function neighborhoodeditcallback(hObject,eventdata)
        c.Neighborhood = str2double( get(handleneighborhoodcurrentvalue,'String') );
    end

    function inputradiuseditcallback(hObject,eventdata)
        c.nDendrites = 0.01*str2double(get(handledendritecurrentvalue,'String'));
        c.inputRadius = str2double(get(handleinputradiuscurrentvalue,'String'));
        if c.inputRadius < c.nDendrites
            %error: the column must be able to find enough potential
            %connections to the input, so either the number of dendrites or the
            %input radius must increase
            error = msgbox('Error: Not enough dendrite space. The column must be able to find enough potential synapses to the input. Either the number of dendrites or the input radius must increase. A minimum input radius has been selected, but this is not recommended.','Error','warn');
            waitfor(error);
            c.inputRadius = c.nDendrites;
            set( handleinputradiuscurrentvalue,'String',num2str(c.nDendrites) );
        end
    end
    
    %Callback for LearningRadius
    function learningradiuseditcallback(hObject,eventdata)
        c.nDendrites = 0.01*str2double(get(handledendritecurrentvalue,'String'));
        c.LearningRadius = str2double( get(handlelearningradiuscurrentvalue,'String') );
        c.cellsPerCol = str2double( get(handlecellscurrentvalue,'String') );
        
        if c.LearningRadius*c.cellsPerCol < c.nDendrites*c.data_size;
            error = msgbox('Error: Not enough dendrite space. The column must be able to find enough potential synapses to the input. Either the number of dendrites or the learning radius must increase. A minimum input radius has been selected, but this is not recommended.','Error','warn');
            waitfor(error);
            c.LearningRadius = ceil(c.nDendrites*c.data_size/c.cellsPerCol);
            set( handlelearningradiuscurrentvalue,'String',num2str(c.LearningRadius) );
        end
    end

    function ncellseditcallback(hObject,eventdata)
        c.nDendrites = 0.01*str2double(get(handledendritecurrentvalue,'String'));
        c.LearningRadius = str2double( get(handlelearningradiuscurrentvalue,'String') );
        c.cellsPerCol = str2double( get(handlecellscurrentvalue,'String') );
        
        if c.LearningRadius*c.cellsPerCol < c.nDendrites*c.data_size
            error = msgbox('Error: Not enough dendrite space. The column must be able to find enough potential synapses to the input. Either the number of dendrites or the learning radius must increase. A minimum input radius has been selected, but this is not recommended.','Error','warn');
            waitfor(error);
            c.LearningRadius = ceil(c.nDendrites*c.data_size/c.cellsPerCol);
            set( handlelearningradiuscurrentvalue,'String',num2str(c.LearningRadius) );
        end
    end
    
    function cancelcallback(hObject,eventdata)
        delete(f);
    end
    %Callback for the apply button
    function applycallback(hObject,eventdata)
        c.synThreshold = str2double(get(handlepermcurrentvalue,'String'));
        c.synInc = str2double(get(handleinccurrentvalue,'String'));
        c.synDec = -1*str2double(get(handledeccurrentvalue,'String')); %Reverse compensation
        c.dendritePercent = 0.01*str2double(get(handledendritecurrentvalue,'String')); %Reverse compensation
        c.columnPercent = 0.01*str2double(get(handlecolcurrentvalue,'String'));   %Reverse compensations
        c.boostInc = str2double(get(handleboostinccurrentvalue,'String'));
        c.minActiveDuty = str2double(get(handleminactivecurrentvalue,'String'));
        c.minOverlapDuty = 0.01*str2double(get(handleminoverlapcurrentvalue,'String'));
        c.minSegOverlap = 0.01*str2double(get(handleminsegcurrentvalue,'String'));
        c.desiredLocalActivity = str2double(get(handledesiredlocalcurrentvalue,'String'));
        c.Neighborhood = str2double(get(handleneighborhoodcurrentvalue,'String'));
        c.inputRadius = str2double(get(handleinputradiuscurrentvalue,'String'));
        c.cellsPerCol = str2double(get(handlecellscurrentvalue,'String'));
        c.maxSegs = str2double(get(handlesegscurrentvalue,'String'));
        c.LearningRadius = str2double(get(handlelearningradiuscurrentvalue,'String'));
        c.minOverlap = str2double(get(handleminocurrentvalue,'String'));
        
        delete(f);
    end
    
    waitfor(f);
end