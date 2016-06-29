%run_sp.m
%Sam Gallagher
%8 March 2016
%
%This program will run the HTM and manage most UI with file IO, settings,
%and output. LOTS of work to be done here, and algorithm isn't finished
%yet, so it is a work in progress. The following menu is an ideal
%functionality.
%
%The algorithm will hold the state of the cells and columns in a file so
%that the algorithm continues to learn even when the program closes and
%reopens with new data. This is more flexible than just learning single
%sequences, though much more data is required for proper functionality. 
%
%The user can clear the column and cell states by going to edit ->
%clear memory. To view the current state, the user must go to view ->
%column states or view -> cell states or view->output.
%
%There is a help section which must outline the functionality of the
%algorithm (from OneNote notes), and can link to the white paper.
%
%The color scheme of the output can be controlled, for fun.
%
%The main display of the program is the input-to-be-sent, in a black and
%white image format subplot of sorts.

%% TODO: fix debugger
%% Main Program
function run_htm()
%% Initialize window and variables
    %The program will need to store the numbers of everything for the
    %different regions, time, as well as the data currently being sent in, and
    %the output of each region, as a minimum. 
    
    send = []; %This is the data to-be-sent
    
    %initialize region data objects, which contain columns, cells, etc
    region_data = [regobj regobj regobj regobj regobj];
    for i = 1:5
        region_data(i) = reg_init(region_data(i),i);
    end
    
   %Create config files
    region_config = [config, config, config, config, config];
    hierarchy_regions = 1;
    for r = 1:numel(region_config)
        region_config(r) = readXMLConfig(region_config(r), 'config\\config.xml',r);
    end
    
    %Declarations
    %Reserving space for a debug window
    dbg_f = [];
    db_lines = 0;
    db_str = [];
    commandline = [];
    textspace = [];
    update_dbg = @updateDebugger;
    pauseTime = 0;
    
    %Create a window and menu
    h.fig = figure();
    h.fig.MenuBar = 'none';
    h.fig.Position = [400,100,700,700];
    
    h.toolBar = subplot(4,4,[1:4]);%This just takes up space
    h.toolBar.Visible = 'off';
    %Now create a text showing the time, which will be updated
    for i = 1:5
        region_config(i).seq_time = 0;
    end
    timeString = ['total time = ' num2str(region_config(1).htm_time) ',   seq length = ' num2str(region_config(1).seq_time)];
    hTimeText = uicontrol(h.fig, 'Style','text','String',timeString,'Position',[20,600,350,40],'FontSize',20);
    
    %Show the current input
    h.mainWindow = subplot(4,4,[5:16]);
    h.mainWindow.XTickLabel = [];
    h.mainWindow.YTickLabel = [];
    h.mainWindow.XGrid = 'on';
    h.mainWindow.YGrid = 'on';
    
    colors = [[1,1,1];[0,0,0]];
    colormap(colors);
    
    hFileMenu = uimenu(h.fig,'Label','File');
        hNewFile = uimenu(hFileMenu,'Label','New...');
            hData = uimenu(hNewFile,'Label','Data');
                uimenu(hData,'Label','Import data file','Callback',@cbFNFDIDF);
                uimenu(hData,'Label','Create random data','Callback',@cbFNFDCRD);
            uimenu(hNewFile,'Label','Drawing','Callback',@cbFNFDr);
        uimenu(hFileMenu,'Label','Save HTM','Callback',@cbFSM);
        hFileSaveDataSeq = uimenu(hFileMenu,'Label','Save current data sequence','Callback',@cbSC,'Enable','off');%Can't save without data
        uimenu(hFileMenu,'Label','Open HTM','Callback',@cbFO);
        uimenu(hFileMenu,'Label','Close','Callback',@cbFC); 
    hEditMenu = uimenu(h.fig,'Label','Edit');
        hClearMem = uimenu(hEditMenu,'Label','Clear Memory','Callback',@cbECM,'Enable','off'); %Can't clear until started
        uimenu(hEditMenu,'Label','Chart predictions over time','Callback',@cbECPOT);
        uimenu(hEditMenu,'Label','Debug','Callback',@cbED);
    hDataMenu = uimenu(h.fig,'Label','Data');
        uimenu(hDataMenu,'Label','Import data file','Callback',@cbFNFDIDF);
        uimenu(hDataMenu,'Label','Import data as next frame','Callback',@cbDIDANF);
        uimenu(hDataMenu,'Label','Clear current data sequence','Callback',@cbDCCDS);
        hDataSaveDataSeq = uimenu(hDataMenu,'Label','Save current data sequence','Callback',@cbSC, 'Enable','off');%Can't save without data
        uimenu(hDataMenu,'Label','View data frames','Callback',@cbVD);
    hPropMenu = uimenu(h.fig,'Label','Properties');
        uimenu(hPropMenu,'Label','Edit hierarchy','Callback',@cbPEH);
        uimenu(hPropMenu,'Label','Files...','Callback',@cbPF);
        uimenu(hPropMenu,'Label','Training settings','Callback',@cbPTS);
    hRunMenu = uimenu(h.fig,'Label','Run');
        hRunItem = uimenu(hRunMenu,'Label','Run...','Callback',@cbRR,'Enable','off'); %Can't run without data
    hViewMenu = uimenu(h.fig,'Label','View');
        uimenu(hViewMenu,'Label','Color scheme','Callback',@cbVCoSc);
        uimenu(hViewMenu,'Label','View data frames','Callback',@cbVD);
        hColStates = uimenu(hViewMenu,'Label','Display column states','Callback',@cbVCoSt,'Enable','off'); %Can't show outputs until
        hCellStates = uimenu(hViewMenu,'Label','Display cell states','Callback',@cbVCeSt,'Enable','off');   %CLA has begun
        hRegionOut = uimenu(hViewMenu,'Label','Show region output','Callback',@cbVRO,'Enable','off');
    hHelpMenu = uimenu(h.fig,'Label','Help');
        uimenu(hHelpMenu,'Label','HTM White Paper (web)','Callback',@cbHHTMWP);
        uimenu(hHelpMenu,'Label','CLA Theory Tutorial','Callback',@cbHCLATT);
        uimenu(hHelpMenu,'Label','CLA Program Tutorial','Callback',@cbHCLAPT);
        uimenu(hHelpMenu,'Label','About','Callback',@cbHA);
        
    %Every one of these will need a callback, so this will
    %get pretty hairy, as tends to happen. To keep things easy,
    %a system of naming will be put in place: 'cb'+first letter of parent
    %menu, and label words. Ex. View -> Column states = cbVCS
    %Exceptions are where there are multiple that fit that, in which case
    %it'll contain the first TWO letters of the words. e.g. View
    %-> Column States = cbVCoSt

%% Menu callback functions
%FILE MENU CALLBACKS
    %NEW FILE CALLBACKS
        function cbFNFDr(hObject,evt)
            %New drawing
            send = generate_input(region_config(1).data_size);
            
            hClearMem.Enable = 'on';
            
            data_size = size(send,1);
            send_img = vec2mat( send(:,1)+1, floor( sqrt(size(send,1)) ) );
            send_img = rot90(send_img);
            h.img = image(send_img,'Parent',h.mainWindow);
            hold on;
            h.mainWindow.XTick = (0:floor(sqrt( size(send,1) )) )+0.5;
            h.mainWindow.YTick = (0:floor(sqrt( size(send,1) )) )+0.5;
            h.mainWindow.XTickLabel = [];
            h.mainWindow.YTickLabel = [];
            h.mainWindow.XGrid = 'on';
            h.mainWindow.YGrid = 'on';
            
            if ~isempty(send)
                %Update percentage in configuration
                if region_config(1).data_size == 0
                    region_config(1).data_size = data_size;
                    %udpate other regions
                end
                region_config(1) = updateConfigPercentages(region_config(1));
                for i = 2:5
                        region_config(i).data_size = region_config(i-1).columns;
                        region_config(i) = updateConfigPercentages(region_config(i));
                    end
                %
                
                %run the settings windows
                cbPTS(hObject,evt);
                cbPEH(hObject,evt);
            end
        end
        %DATA CALLBACKS
            function cbFNFDIDF(hObject,evt)
                %Import data file
                
                [dFileName dFileLoc] = uigetfile('*.*','Select data file',region_config(1).lastDir); 
                dataFilePath = [dFileLoc dFileName];
                input_config(1).lastDir = dataFilePath; %While perhaps I SHOULD write lastDir for all 5 config files, since it is
                %shared... out of spite for MATLAB not having a 'static'
                %feature, I will only use the first config file.
                
                %Determine what type of file it is
                %Run the proper function
                %Acceptable files:
                %   jpg
                if strcmp(dFileName(find(dFileName == '.'):end),'.jpg')
                    waitbox = waitbar(0,'Formatting image.. (this could take a while)');
                    imData = imread(dataFilePath);
                    send = convert_image(imData);
                    close(waitbox);
                    
                    data_size = size(send,1);
                    send_img = vec2mat( send(:,1)+1,floor(sqrt(data_size)) );
                    send_img = rot90(send_img);
                    h.img = image(send_img,'Parent',h.mainWindow);
                    hold on;
                elseif strcmp(dFileName(find(dFileName == '.'):end),'.csv')
                    csvdata = csvread(dataFilePath);
                    maxD = max(csvdata);
                    minD = min(csvdata);
                    if maxD == 1 && minD == 0
                        %binary data, convert to a single frame
                    else
                        %we'll need to know what size to encode the data
                        
                        %then go about encoding each bit of data into a
                        %time frame
                        for iter = 1:size(csvdata,1)
                            %temporarily use a constant size of 144 and
                            %neighborhood of 5
                                                                                                %TODO
                            if csvdata(iter) < 0
                                send(:,iter) = convert_scalar(0,144,minD,maxD,5);
                            else
                                send(:,iter) = convert_scalar(csvdata(iter),144,minD,maxD,5);
                            end
                        end
                    end
                    data_size = size(send,1);
                    send_img = vec2mat(send(:,1)+1,floor(sqrt(data_size)) );
                    send_img = rot90(send_img);
                    h.img = image(send_img,'Parent',h.mainWindow);
                    hold on;
                else
                    
                    %   png
                    %   txt
                    %   mpg?
                    %   mp3
                    %   xml

                    %If not jpg, this will open text files and store them as a
                    %vector
                    if (dataFilePath(2) ~= 0)
                        send = load(dataFilePath);
                        
                        data_size = size(send,1);
                        if region_config(1).data_size > 0
                            if data_size ~= region_config(1).data_size
                                send = [];
                                data_size = 0;
                                msgbox('Error. The data file selected does not share the same size as previous data. ','warn','Error');
                            end
                        else
                            region_config(1).data_size = data_size;
                        end
                        send_img = vec2mat( send(:,1)+1, floor( sqrt(data_size) ) );
                        send_img = rot90(send_img);
                        h.img = image(send_img,'Parent',h.mainWindow);
                        hold on;
                        h.mainWindow.XTick = (0:floor(sqrt( data_size )) )+0.5;
                        h.mainWindow.YTick = (0:floor(sqrt( data_size )) )+0.5;
                        h.mainWindow.XTickLabel = [];
                        h.mainWindow.YTickLabel = [];
                        h.mainWindow.XGrid = 'on';
                        h.mainWindow.YGrid = 'on';
                    end
                end
                if ~isempty(send)
                    hClearMem.Enable = 'on';
                    hRunItem.Enable = 'off';
                    data_size = size(send,1);
                    region_config(1).data_size = data_size;
                    region_config(1) = updateConfigPercentages(region_config(1));
                    for i = 2:5
                        region_config(i).data_size = region_config(i-1).columns;
                        region_config(i) = updateConfigPercentages(region_config(i));
                    end
                    cbPTS(hObject,evt);
                    cbPEH(hObject,evt);
                end
            end
            function cbFNFDCRD(hObject,evt)
                %Create random data
                %Not implemented yet
                if ~isempty(send)
                    hRunItem.Enable = 'off';
                    hClearMem.Enable = 'on';
                    if region_config(1).data_size == 0
                        region_config.data_size = size(send,1);
                        %
                    end
                    %update percentages in currentConfig (NOT config file)
                    region_config(1) = updateConfigPercentages(region_config(1));
                    for i = 2:5
                        region_config(i).data_size = region_config(i-1).columns;
                        region_config(i) = updateConfigPercentages(region_config(i));
                    end
                    %
                    cbPTS(hObject,evt);
                    cbPEH(hObject,evt);
                end
            end
    function cbFO(hObject,evt)
        %Open
        dProjLoc= uigetdir(region_config(1).lastDir); 
        hClearMem.Enable = 'on';
        %Open the relevant project data; region_data, region_config and
        %send
                                                                                                                %TODO
        
    end
    function cbFSM(hObject,evt)
        %Save memory
        dProjLoc = uigetdir(region_config(1).lastDir); 
        
        %Save region_data and region_config in a readable format
                                                                                                                %TODO
        
        all_out = 0;
        save([dProjLoc, '\out.htm'],'all_out','-ascii');
        save([dProjLoc, '\in.htm'],'send','-ascii');
        for r = 1:5
            %update the config XML file. 
            %Note that this happens every time the hierarchy is changed
            %right now, and it saves five times over due to lack of access.
            %A fix is in order, once problems become apparent.
            
            %Also, the save function does NOT write to an XML file yet. See
            %notes.
            saveXML(region_config(r),region_config(1).configFile,r);
        end
        
    end
    function cbFC(hObject,evt)
        %Close
        close(); %This is temporary
        %prompt a "quit without saving?"
                                                                                                                %TODO
    end
%EDIT MENU CALLBACKS
    function cbECM(hObject,evt)
        %Clear memory
        %Are you sure?
        cl_bool = questdlg('Are you sure?','Clear current data.');
        if strcmp(cl_bool,'Yes')
            
            send = [];
            for i = 1:5
                region_data(i).columns = [];
                region_data(i).cells = [];
                region_data(i).activeColumns = [];
                region_data(i).prediction = [];
                region_data(i).output = [];
            end
            
            for i =1:5
                region_config(i) = setToDefault(region_config(i));
            end
            hRunItem.Enable = 'off';
            hClearMem.Enable = 'off';
            hRegionOut.Enable = 'off';
            hCellStates.Enable = 'off';
            hColStates.Enable = 'off';
            h.img = image(ones(12),'Parent',h.mainWindow);
            hold on;
            %quickly update the 't=' text
            timeString = ['total time = 0,   seq time = 0'];
            hTimeText.String = timeString;
        end
    end
    function cbECPOT(hObject,evt)
        %Chart predictions over time
        
    end
    function cbED(hObject,evt)
        %Debug
        %TODO: debugger does not like it when the window is closed by the
        %user
        nextline = 'Starting debugger...';
        dbg_f = figure('color','white','Position',[30,200,600,300],'MenuBar','none');
        dbg_f.SizeChangedFcn = @cbSizeChange;
        db_str = {nextline,'Ready.'};
        db_lines = 2;
        textspace = uicontrol('Style','edit','BackgroundColor','white','Position',[0,30,600,300-31],'String',db_str,'Enable','inactive','HorizontalAlignment','left','Max',100,'Min',1);
        commandline = uicontrol('Style','edit','BackgroundColor','white','Position',[0,0,600,30],'HorizontalAlignment','left','Callback',@cbCommandLine);
        
        function cbCommandLine(hObject,evt)
            %parse
            command = commandline.String;
            spaces = find(command == ' ');
            instruct = [];
            val = [];
            if numel(spaces) == 1
                if spaces(1) > 0
                    instruct = command(1:spaces(1)-1);
                    val = command( (spaces(1)+1):end );
                end
            elseif numel(spaces) == 0
                %skip val
                instruct = command(1:end);
            else
                %invalid command
            end
            
            %display
            db_lines = db_lines+1;
            db_str{db_lines} = ['> ', command];
            textspace.String = db_str;
            commandline.String = '';
            
            %perform function
            if strcmp(instruct,'clear')
                %reset the variables
                db_str = {};
                db_lines = 0;
                textspace.String = '';
            elseif strcmp(instruct,'watch')
                %watch the variable if it exists
            elseif strcmp(instruct,'config')
                if length(val) == 1
                    regionid = str2num(val);
                    if regionid > 0 && regionid < 5
                        %display the configuration of the regions with labels
                        nextline = ['Synapse threshold: ', num2str(region_config(regionid).synThreshold)];
                        updateDebugger(nextline);

                        nextline = ['Synapse increment: ', num2str(region_config(regionid).synInc)];
                        updateDebugger(nextline);

                        nextline = ['Synapse decrement: ', num2str(region_config(regionid).synDec)];
                        updateDebugger(nextline);

                        nextline = ['Dendrites per column: ', num2str(region_config(regionid).nDendrites)];
                        updateDebugger(nextline);

                        nextline = ['Minimum segment overlap: ', num2str(region_config(regionid).minSegOverlap)];
                        updateDebugger(nextline);

                        nextline = ['Number of columns in the region: ', num2str(region_config(regionid).columns)];
                        updateDebugger(nextline);

                        nextline = ['Desired local activity: ', num2str(region_config(regionid).desiredLocalActivity)];
                        updateDebugger(nextline);

                        nextline = ['Neighborhood size: ', num2str(region_config(regionid).Neighborhood)];
                        updateDebugger(nextline);

                        nextline = ['Input radius: ', num2str(region_config(regionid).inputRadius)];
                        updateDebugger(nextline);

                        nextline = ['Boost increment: ', num2str(region_config(regionid).boostInc)];
                        updateDebugger(nextline);

                        nextline = ['Minimum active duty cycle: ', num2str(region_config(regionid).minActiveDuty)];
                        updateDebugger(nextline);

                        nextline = ['Minimum overlap duty cycle: ', num2str(region_config(regionid).minOverlapDuty)];
                        updateDebugger(nextline);

                        nextline = ['Number of cells per column: ', num2str(region_config(regionid).cellsPerCol)];
                        updateDebugger(nextline);

                        nextline = ['Max number of segments per cell: ', num2str(region_config(regionid).maxSegs)];
                        updateDebugger(nextline);

                        nextline = ['Cell learning radius: ', num2str(region_config(regionid).LearningRadius)];
                        updateDebugger(nextline);

                        nextline = ['Minimum overlap: ', num2str(region_config(regionid).minOverlap)];
                        updateDebugger(nextline);
                    end
                end
            elseif strcmp(instruct,'save')
                dProjLoc = uigetdir(region_config(1).lastDir);
                updateDebugger('Saving to file log.txt ...');
                if exist([dProjLoc,'\log.txt']) > 0
                    fid = fopen([dProjLoc,'\log.txt'],'wt');
                    fprintf(fid,'');
                    fclose(fid);
                end
                savefile = fopen([dProjLoc,'\log.txt'],'a');
                for i = 1:db_lines
                    fprintf(savefile,[db_str{i},'\n']);
                end
                
                fclose(savefile);
                updateDebugger('Done.');
                
            elseif strcmp(instruct,'pause')
                if length(val) > 0
                    pauseTime = str2num(val);
                end
                updateDebugger(['Pause set for t = ',val]);
            elseif exist(instruct) == 1
                %if this is a variable, print its value
                
                updateDebugger([instruct ' = ']);
                updateDebugger( eval(instruct) );
            else
                %invalid command
            end
            jhTextspace = findjobj(textspace);
            jEditTextspace = jhTextspace.getComponent(0).getComponent(0);
            jEditTextspace.setCaretPosition(jEditTextspace.getDocument.getLength);
        end
        function cbSizeChange(hObject,evt)
            len = dbg_f.Position(3);
            height = dbg_f.Position(4);
            textspace.Position = [0,30,len,height-31];
            commandline.Position = [0,0,len,30];
            jhTextspace = findjobj(textspace);
            jEditTextspace = jhTextspace.getComponent(0).getComponent(0);
            jEditTextspace.setCaretPosition(jEditTextspace.getDocument.getLength);
        end
    end
%DATA MENU CALLBACKS
    function cbDIDANF(hObject, evt)
        
        %Import data file as next frame
                
            
    end
    function cbSC(hObject,evt)
        %Save current data sequence
        [dFileName dFileLoc] = uiputfile('*.*',region_config(1).lastDir); 
        dataFilePath = [dFileLoc dFileName];
        region_config(1).lastDir = dataFileLoc;
        
        save(dataFilePath,'send','-ascii');
    end
    function cbDCCDS(hObject,evt)
        %Clear current data sequence
        %Are you sure? dialog
        cl_bool = questdlg('Are you sure?','Clear current data.');
        if strcmp(cl_bool,'Yes')
            send = []; %delete the input-to-be-sent
            hRunItem.Enable = 'off';
            h.img = image(ones(12),'Parent',h.mainWindow);
            hold on;
            %quickly update the 't=' text
            timeString = ['total time = ' num2str(region_config(1).htm_time) ',   seq time = 0'];
            hTimeText.String = timeString;
        end
    end
        
    function cbVD(hObject,evt)
        %View data frames
        show_input_sequence(send); 
    end
%PROPERTIES MENU CALLBACKS
    function cbPEH(hObject,evt)
        %Edit hierarchy
        
        if isempty(send)
            error = msgbox('Warning: No input data. Deciding on parameters for regions will not be able to set data appropriately.');
            waitfor(error);
            [hierarchy_regions, c] = hierarchy_ui(hierarchy_regions,region_config, false);
            %The c being returned is ALL FIVE region configuration objects
            if ~isempty(c)
                region_config = c;
                for i = 1:hierarchy_regions
                    if region_config(i).data_size > 0
                        region_config(i) = updateConfigPercentages(region_config(i));
                    end
                end
            end
        else
            [hierarchy_regions, c] = hierarchy_ui(hierarchy_regions,region_config, true);
            if ~isempty(c)
                region_config = c;
                for i = 1:hierarchy_regions
                    if region_config(i).data_size > 0
                        region_config(i) = updateConfigPercentages(region_config(i));
                    end
                end
                hRunItem.Enable = 'on';
            end
        end
        
        for r = 1:5
            %update the config XML file. 
            %Note that this happens every time the hierarchy is changed
            %right now, and it saves five times over due to lack of access.
            %A fix is in order, once problems become apparent.
            saveXML(region_config(r),region_config(1).configFile,r);
        end
        
    end
    function cbPF(hObject,evt)
        %Files...
        [dFileName, dFileLoc] = uiputfile('config.xml','Config file',region_config(1).configFile);
        dFilePath = [dFileLoc, dFileName];
        %update configFile 
        region_config(1).configFile = dFilePath; %Save the ENTIRE path
    end

    function cbPTS(hObject,evt)
        %Training settings
        region_config(1) = train_settings(region_config(1));
        if region_config(1).spatial_pooler == true
            for i = 1:5
                region_config(i).spatial_pooler = true;
            end
        end
        if region_config(1).temporal_memory == true
            for i = 1:5
                region_config(i).temporal_memory = true;
            end
        end
    end
%RUN MENU CALLBACKS
    function cbRR(hObject,evt)
        %Run
        
        %Note seq_time will be set within the region function
        region_data = region(send,region_data,hierarchy_regions,region_config,update_dbg,pauseTime);
        hColStates.Enable = 'on';
        hCellStates.Enable = 'on';
        hRegionOut.Enable = 'on';
        
        cPredsFig = figure();
        cPredsPlot = plot(region_data(1).correctPredictions);
        hold on;
        title('Accurate predictions over time');

        %update time information
        seqTimeElapsed = size(send,2);
        for i = 1:5
            region_config(i).seq_time = seqTimeElapsed;
            region_config(i).htm_time = region_config(i).htm_time+region_config(i).seq_time*region_config(i).reps;
        end
        %quickly update the 't=' text
        timeString = ['total time = ' num2str(region_config(1).htm_time) ',   seq time = ' num2str(region_config(1).seq_time)];
        hTimeText.String = timeString;
    end
%VIEW MENU CALLBACKS
    function cbVCoSc(hObject,evt)
        %Color scheme
        scheme = uisetcolor();
    end
    function cbVCoSt(hObject,evt)
        %Column states
        if region_config(1).spatial_pooler
            column_visualizer(send, columns, region_config(1)); %TODO Make these more clear about what they are for the user; also update config stuff
        end
    end
    function cbVCeSt(hObject,evt)
        %Cell states
        show_cells(region_config(1),region_data(1).cells,region_config(1).seq_time);
    end
    function cbVRO(hObject,evt)
        %Region output
        show_active_columns(region_config(1),region_data(1).activeColumns,region_data(1).prediction,region_config(1).seq_time);
        show_active_columns(region_config(2),region_data(2).activeColumns,region_data(2).prediction,region_config(2).seq_time);
    end
%HELP MENU CALLBACKS
    function cbHHTMWP(hObject,evt)
        %HTM White Paper
    end
    function cbHCLATT(hObject,evt)
        %CLA Theory Tutorial
    end
    function cbHTMPT(hObject,evt)
        %CLA Program Tutorial
    end
    function cbHA(hObject,evt)
        %About
        about_string = ['This program was written by Sam Gallagher, based off of the CLA '...
            ,'White Paper by Numenta. Last updated: 2 June 2016'];
        a = dialog('Position',[300,300,300,250],'Name','About');
        hAboutDialog = uicontrol('Parent',a,'Style','text','String',about_string,'Position',[10,50,280,150],'FontSize',15,'BackgroundColor',[0.9,1,1]);
    end
    function updateDebugger(nextline)
        if exist('textspace') > 0
            if isstr(nextline)
                db_lines = db_lines+1;
                db_str{db_lines} = nextline;
                textspace.String = db_str;
            elseif isnumeric(nextline)

                if iscolumn(nextline)
                    nextline = nextline';
                    nextline = num2str(nextline);
                    db_lines = db_lines+1;
                    db_str{db_lines} = nextline;
                    textspace.String = db_str;
                elseif isrow(nextline)
                    nextline = num2str(nextline);
                    db_lines = db_lines+1;
                    db_str{db_lines} = nextline;
                    textspace.String = db_str;
                elseif ismatrix(nextline)
                    matsize = size(nextline);
                    mat_height = matsize(1);

                    for i = 1:mat_height
                        updateDebugger(nextline(i,:));
                    end
                end
            elseif isstruct(nextline)
                %Try to print the structure out properly...
            else
                db_lines = db_lines+1;
                db_str{db_lines} = 'Unknown data type, display unsuccessful.';
                textspace.String = db_str;
            end
        end
    end
end
