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
%The output is a 15 element vector with the above order.
%
%Constraints:
%The input radius must be > nDendrites

function [synThreshold,synInc,synDec,nDendrites,minSegOverlap,nCols,desiredLocalActivity,Neighborhood,inputRadius,boostInc,minActiveDuty,minOverlapDuty,nCells,nSegs,LearningRadius] = user_control(input_size)
    f = figure('Visible','off','color','white','Position',[360,500,600,300]);
    
    input_size = input_size(1);
    
    
    %min and max values for sliders
    minOverlapDutyMin = 0;
    minOverlapDutyMax = 100;
    
    minActiveDutyMin = 0;
    minActiveDutyMax = 100;
    
    boostIncMin = 0.1;
    boostIncMax = 20;
    
    nColsMin = 0.1;
    nColsMax = 100;
    
    nDendritesMin = 1; %Percentage of given space
    nDendritesMax = 99;
    
    threshMin = 0.01;
    threshMax = 0.99;
    
    incMinValue = 0.01;
    incMaxValue = 0.30;
    
    decMinValue = 0.01;
    decMaxValue = 0.30;
    
    %Default initial values
    synThreshold = 0.2;
    synInc = 0.075;
    synDec = 0.05;
    nDendrites = 50; %  50% of the given space
    minSegOverlap = 10;
    nCols = 30; %30% of input space
    desiredLocalActivity = 5;
    Neighborhood = 20;
    inputRadius = 0.01*nDendrites*input_size;
    boostInc = 0.5;
    minActiveDuty = 0.1;
    minOverlapDuty = 0.1;
    nCells = 3;
    nSegs = 12;
    LearningRadius = 40;
    
    %slider handles
    perm_slidehandle = uicontrol('Style','slider','Position',[10,270,100,15],'Min',threshMin,'Max',threshMax,'Callback',@permslidecallback,'Value',synThreshold);
    inc_slidehandle = uicontrol('Style','slider','Position',[10,240,100,15],'Min',incMinValue,'Max',incMaxValue,'Callback',@incslidecallback,'Value',synInc);
    dec_slidehandle = uicontrol('Style','slider','Position',[10,210,100,15],'Min',decMinValue,'Max',decMaxValue,'Callback',@decslidecallback,'Value',synDec);
    nDendrites_slidehandle = uicontrol('Style','slider','Min',nDendritesMin,'Max',nDendritesMax,'Value',nDendrites,'Position',[10,180,100,15],'Callback',@dendriteslidecallback);
    nCols_slidehandle = uicontrol('Style','slider','Min',nColsMin,'Max',nColsMax,'Value',nCols,'Position',[10,150,100,15],'Callback',@ncolslidecallback);
    boostInc_slidehandle = uicontrol('Style','slider','Min',boostIncMin,'Max',boostIncMax,'Value',boostInc,'Position',[10,120,100,15],'Callback',@boostincslidecallback);
    minActiveDuty_slidehandle = uicontrol('Style','slider','Min',minActiveDutyMin,'Max',minActiveDutyMax,'Value',minActiveDuty,'Position',[10,90,100,15],'Callback',@minactiveslidecallback);
    minOverlapDuty_slidehandle = uicontrol('Style','slider','Min',minOverlapDutyMin,'Max',minOverlapDutyMax,'Value',minOverlapDuty,'Position',[10,60,100,15],'Callback',@minoverslidecallback);
    
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
    handlepermcurrentvalue = uicontrol('Style','edit','BackgroundColor','white','Position',[120,270,50,15],'Visible','on','String',num2str(synThreshold),'Callback',@permeditcallback);
    handleinccurrentvalue = uicontrol('Style','edit','BackgroundColor','white','Position',[120,240,50,15],'Visible','on','String',num2str(synInc),'Callback',@inceditcallback);
    handledeccurrentvalue = uicontrol('Style','edit','BackgroundColor','white','Position',[120,210,50,15],'Visible','on','String',num2str(synDec),'Callback',@deceditcallback);
    handledendritecurrentvalue = uicontrol('Style','edit','BackgroundColor','white','Position',[120,180,50,15],'Visible','on','String',num2str(nDendrites),'Callback',@dendriteeditcallback);
    handlecolcurrentvalue = uicontrol('Style','edit','BackgroundColor','white','Position',[120,150,50,15],'Visible','on','String',num2str(nCols),'Callback',@ncolseditcallback);
    handleboostinccurrentvalue = uicontrol('Style','edit','BackgroundColor','white','Position',[120,120,50,15],'Visible','on','String',num2str(boostInc),'Callback',@boostinceditcallback);
    handleminactivecurrentvalue = uicontrol('Style','edit','BackgroundColor','white','Position',[120,90,50,15],'Visible','on','String',num2str(minActiveDuty),'Callback',@minactiveeditcallback);
    handleminoverlapcurrentvalue = uicontrol('Style','edit','BackgroundColor','white','Position',[120,60,50,15],'Visible','on','String',num2str(minOverlapDuty),'Callback',@minoverlapeditcallback);
    handleminsegcurrentvalue = uicontrol('Style','edit','BackgroundColor','white','Position',[120,30,50,15],'Visible','on','String',num2str(minSegOverlap));
    handledesiredlocalcurrentvalue = uicontrol('Style','edit','BackgroundColor','white','Position',[320,270,50,15],'Visible','on','String',num2str(desiredLocalActivity),'Callback',@desiredlocaleditcallback);
    handleneighborhoodcurrentvalue = uicontrol('Style','edit','BackgroundColor','white','Position',[320,240,50,15],'Visible','on','String',num2str(Neighborhood),'Callback',@neighborhoodeditcallback);
    handleinputradiuscurrentvalue = uicontrol('Style','edit','BackgroundColor','white','Position',[320,210,50,15],'Visible','on','String',num2str(inputRadius), 'Callback',@inputradiuseditcallback);
    handlecellscurrentvalue = uicontrol('Style','edit','BackgroundColor','white','Position',[320,180,50,15],'Visible','on','String',num2str(nCells));
    handlesegscurrentvalue = uicontrol('Style','edit','BackgroundColor','white','Position',[320,150,50,15],'Visible','on','String',num2str(nSegs));
    handlelearningradiuscurrentvalue = uicontrol('Style','edit','BackgroundColor','white','Position',[320,120,50,15],'Visible','on','String',num2str(LearningRadius));
    
    
    %Label box handles
    handlepermLabel = uicontrol('Style','text','BackgroundColor','white','Position',[170,270,100,15],'String','Synapse Threshold');
    handleIncLabel = uicontrol('Style','text','BackgroundColor','white','Position',[170,240,100,15],'String','Synapse Inc');
    handleDecLabel = uicontrol('Style','text','BackgroundColor','white','Position',[170,210,100,15],'String','Synapse Dec');
    handlenDendriteLabel = uicontrol('Style','text','BackgroundColor','white','Position',[170,180,100,15],'String','N of Dendrites(%)');
    handlenColsLabel = uicontrol('Style','text','BackgroundColor','white','Position',[170,150,100,15],'String','N of Cols (%)');
    handleboostIncLabel = uicontrol('Style','text','BackgroundColor','white','Position',[170,120,100,15],'String','Boost Inc');
    handleminActiveLabel = uicontrol('Style','text','BackgroundColor','white','Position',[170,90,100,15],'String','Min Active Duty(%)');
    handleminOverlapLabel = uicontrol('Style','text','BackgroundColor','white','Position',[170,60,100,15],'String','Min Overlap Duty(%)');
    handleminSegLabel = uicontrol('Style','text','BackgroundColor','white','Position',[170,30,120,15],'String','Minimum Seg Overlap');
    handledesiredLocalLabel = uicontrol('Style','text','BackgroundColor','white','Position',[370,270,130,15],'String','Desired Local Activity');
    handleNeighbordhoodLabel = uicontrol('Style','text','BackgroundColor','white','Position',[370,240,100,15],'String','Neighborhood');
    handleinputRadiusLabel = uicontrol('Style','text','BackgroundColor','white','Position',[380,210,150,15],'String','Input Radius (col to input map)');
    handlenCellsLabel = uicontrol('Style','text','BackgroundColor','white','Position',[385,180,50,15],'String','N of Cells');
    handlenSegsLabel = uicontrol('Style','text','BackgroundColor','white','Position',[380,150,100,15],'String','N of Segs per Cell');
    handleLearningRadiusLabel = uicontrol('Style','text','BackgroundColor','white','Position',[385,120,140,15],'String','Learning Radius (cell to cols)');
    
    %make an APPLY button
    handleapply = uicontrol('Style','pushbutton','String','Apply','Position',[420,20,70,20],'Callback',@applycallback);
    
    %Finalize the box on display
    set(f,'Name','Properties')
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
        nDendrites = input_size*num*0.01;
        inputRadius = str2double(get(handleinputradiuscurrentvalue,'String'));
        if inputRadius < nDendrites
            %error: the column must be able to find enough potential
            %connections to the input, so either the number of dendrites or the
            %input radius must increase
            error = msgbox('Error: Not enough dendrite space. The column must be able to find enough potential synapses to the input. Either the number of dendrites or the input radius must increase. A minimum input radius has been selected, but this is not recommended.','Error','warn');
            waitfor(error);
            inputRadius = nDendrites;
            set(handleinputradiuscurrentvalue,'String',num2str(nDendrites) );
        end
    end
    function dendriteeditcallback(hObject,eventdata)
        %set the slider value to the editbox
        num = get(handledendritecurrentvalue,'String');
        set(nDendrites_slidehandle,'Value',str2double(num));
        nDendrites = input_size*num*0.01;
        inputRadius = str2double(get(handleinputradiuscurrentvalue,'String'));
        if inputRadius < nDendrites
            %error: the column must be able to find enough potential
            %connections to the input, so either the number of dendrites or the
            %input radius must increase
            error = msgbox('Error: Not enough dendrite space. The column must be able to find enough potential synapses to the input. Either the number of dendrites or the input radius must increase. A minimum input radius has been selected, but this is not recommended.','Error','warn');
            waitfor(error);
            inputRadius = nDendrites;
            set(handleinputradiuscurrentvalue,'String',num2str(nDendrites) );
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
            desiredLocalActivity = Neighborhood;
        end
    end

    function neighborhoodeditcallback(hObject,eventdata)
        Neighborhood = str2double( get(handleneighborhoodcurrentvalue,'String') );
    end

    function inputradiuseditcallback(hObject,eventdata)
        num = get(handledendritecurrentvalue,'String');
        nDendrites = input_size*str2double(num)*0.01;
        inputRadius = str2double(get(handleinputradiuscurrentvalue,'String'));
        if inputRadius < nDendrites
            %error: the column must be able to find enough potential
            %connections to the input, so either the number of dendrites or the
            %input radius must increase
            error = msgbox('Error: Not enough dendrite space. The column must be able to find enough potential synapses to the input. Either the number of dendrites or the input radius must increase. A minimum input radius has been selected, but this is not recommended.','Error','warn');
            waitfor(error);
            inputRadius = nDendrites;
            set(handleinputradiuscurrentvalue,'String',num2str(nDendrites) );
        end
    end
    
    %Callback for the apply button
    function applycallback(hObject,eventdata)
        synThreshold = str2double(get(handlepermcurrentvalue,'String'));
        synInc = str2double(get(handleinccurrentvalue,'String'));
        synDec = str2double(get(handledeccurrentvalue,'String'));
        nDendrites = 0.01*str2double(get(handledendritecurrentvalue,'String'));
        nCols = 0.01*str2double(get(handlecolcurrentvalue,'String'));
        boostInc = str2double(get(handleboostinccurrentvalue,'String'));
        minActiveDuty = 0.01*str2double(get(handleminactivecurrentvalue,'String'));
        minOverlapDuty = 0.01*str2double(get(handleminoverlapcurrentvalue,'String'));
        minSegOverlap = str2double(get(handleminsegcurrentvalue,'String'));
        desiredLocalActivity = str2double(get(handledesiredlocalcurrentvalue,'String'));
        Neighborhood = str2double(get(handleneighborhoodcurrentvalue,'String'));
        inputRadius = str2double(get(handleinputradiuscurrentvalue,'String'));
        nCells = str2double(get(handlecellscurrentvalue,'String'));
        nSegs = str2double(get(handlesegscurrentvalue,'String'));
        LearningRadius = str2double(get(handlelearningradiuscurrentvalue,'String'));
        
        delete(f);
    end
    
    waitfor(f);
end