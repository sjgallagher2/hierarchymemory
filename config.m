%config.m
%Sam Gallagher
%8 June 2016
%
%A configuration class containing all configurations for a given region

classdef config
    properties 
        %region settings: must be set, no default values
        region
        reps
        htm_time
        seq_time
        temporal_memory
        spatial_pooler
        TM_delay
        data_size
        
        %SP and TM settings
        synThreshold
        synInc
        synDec
        dendritePercent
        nDendrites                          
        minSegOverlap
        columnPercent
        columns                              
        cellsPerCol
        desiredLocalActivity
        Neighborhood
        inputRadius
        boostInc
        minActiveDuty                      %percentage
        minOverlapDuty                   %percentage
        maxSegs
        LearningRadius
        minOverlap
        
        %program settings, the same for all regions, ideally
        lastDir
        configFile
    end
    
    methods
        function settings = formatConfigVector(obj)
            settings = [];
            settings(1) = obj.region;
            settings(2) = obj.reps;
            settings(3) = obj.htm_time;
            settings(4) = obj.seq_time;
            settings(5) = obj.temporal_memory;
            settings(6) = obj.spatial_pooler;
            settings(7) = obj.TM_delay;
            settings(8) = obj.data_size;
            settings(9) = obj.synThreshold;
            settings(10) = obj.synInc;
            settings(11) = obj.synDec;
            settings(12) = obj.nDendrites;
            settings(13) = obj.minSegOverlap;
            settings(14) = obj.columns;
            settings(15) = obj.cellsPerCol;
            settings(16) = obj.desiredLocalActivity;
            settings(17) = obj.Neighborhood;
            settings(18) = obj.inputRadius;
            settings(19) = obj.boostInc;
            settings(20) = obj.minActiveDuty;
            settings(21) = obj.minOverlapDuty;
            settings(22) = obj.maxSegs;
            settings(23) = obj.LearningRadius;
            settings(24) = obj.minOverlap;
        end
        function obj = setToDefault(obj)
            %sets SP and TM settings to default values
            obj.synThreshold = 0.2;
            obj.synInc = 0.075;
            obj.synDec = -0.05;
            obj.dendritePercent = 0.5;
            obj.nDendrites = 0;
            obj.minSegOverlap = 10;
            obj.columnPercent = 0.3;
            obj.columns = 0;
            obj.cellsPerCol =3;
            obj.desiredLocalActivity = 5;
            obj.Neighborhood = 20;
            obj.inputRadius = 120;
            obj.boostInc = 0.5;
            obj.minActiveDuty = 0.1;
            obj.minOverlapDuty = 0.1;
            obj.maxSegs = 1;
            obj.LearningRadius = 200;
            obj.minOverlap = 2;
        end
        
        function obj = updateConfigPercentages(obj)
            obj.columns = obj.columnPercent*obj.data_size;
            obj.nDendrites = obj.dendritePercent*obj.data_size;
        end
        
        function obj = readFormattedConfig(obj,settings)
            %take in a column vector in order which contains the config
            %data. Typically comes from a file.
            obj.region = settings(1);
            obj.reps = settings(2);
            obj.htm_time = settings(3);
            obj.seq_time =settings(4);
            obj.temporal_memory = settings(5);
            obj.spatial_pooler = settings(6);
            obj.TM_delay = settings(7);
            obj.data_size = settings(8);
            obj.synTreshold = settings(9);
            obj.synInc = settings(10);
            obj.synDec = settings(11);
            obj.nDendrites = settings(12);
            obj.minSegOverlap = settings(13);
            obj.columns = settings(14);
            obj.cellsPerCol = settings(15);
            obj.desiredLocalActivity = settings(16);
            obj.Neighborhood = settings(17);
            obj.inputRadius = settings(18);
            obj.boostInc = settings(19);
            obj.minActiveDuty = settings(20);
            obj.minOverlapDuty = settings(21);
            obj.maxSegs = settings(22);
            obj.LearningRadius = settings(23);
            obj.minOverlap = settings(24);
        end
        
        function obj = readXMLConfig(obj,filename)
            configDOM = xmlread(filename);
            cElement = configDOM.getDocumentElement;
            cNodes = cElement.getChildNodes;
            cRegion = cNodes.item(1);
            cAlgorithm = cNodes.item(3);
            cFiles = cNodes.item(5);
            
            %read in region settings
            cRegNodes = cRegion.getChildNodes;
            node = cRegNodes.getFirstChild;
            while ~isempty(node)
                if strcmpi(node.getNodeName,'region')
                    obj.region = str2num(char(node.getTextContent));
                    node = node.getNextSibling;
                elseif strcmpi(node.getNodeName,'htm_time')
                    obj.htm_time = str2num(char(node.getTextContent));
                    node = node.getNextSibling;
                elseif strcmpi(node.getNodeName,'seq_time')
                    obj.seq_time = str2num(char(node.getTextContent));
                    node = node.getNextSibling;
                elseif strcmpi(node.getNodeName,'temporal_memory')
                    obj.temporal_memory = str2num(char(node.getTextContent));
                    node = node.getNextSibling;
                elseif strcmpi(node.getNodeName,'spatial_pooler')
                    obj.spatial_pooler = str2num(char(node.getTextContent));
                    node = node.getNextSibling;
                elseif strcmpi(node.getNodeName,'TM_delay')
                    obj.TM_delay = str2num(char(node.getTextContent));
                    node = node.getNextSibling;
                else
                    node = node.getNextSibling;
                end
            end
            
            %read in algorithm settings
            cAlgNodes = cAlgorithm.getChildNodes;
            node = cAlgNodes.getFirstChild;
            while~isempty(node)
                if strcmpi(node.getNodeName,'synThreshold')
                    obj.synThreshold = str2num(char(node.getTextContent));
                    node = node.getNextSibling;
                elseif strcmpi(node.getNodeName,'synInc')
                    obj.synInc = str2num(char(node.getTextContent));
                    node = node.getNextSibling;
                elseif strcmpi(node.getNodeName,'synDec')
                    obj.synDec = str2num(char(node.getTextContent));
                    node = node.getNextSibling;
                elseif strcmpi(node.getNodeName,'dendritePercent')
                    obj.dendritePercent = str2num(char(node.getTextContent));
                    node = node.getNextSibling;
                 elseif strcmpi(node.getNodeName,'dendrites')
                    obj.nDendrites = str2num(char(node.getTextContent));
                    node = node.getNextSibling;
                elseif strcmpi(node.getNodeName,'minSegOverlap')
                    obj.minSegOverlap = str2num(char(node.getTextContent));
                    node = node.getNextSibling;
                elseif strcmpi(node.getNodeName,'columnPercent')
                    obj.columnPercent = str2num(char(node.getTextContent));
                    node = node.getNextSibling;
                elseif strcmpi(node.getNodeName,'columns')
                    obj.columns = str2num(char(node.getTextContent));
                    node = node.getNextSibling;
                elseif strcmpi(node.getNodeName,'cellsPerCol')
                    obj.cellsPerCol = str2num(char(node.getTextContent));
                    node = node.getNextSibling;
                elseif strcmpi(node.getNodeName,'desiredLocalActivity')
                    obj.desiredLocalActivity = str2num(char(node.getTextContent));
                    node = node.getNextSibling;
                elseif strcmpi(node.getNodeName,'Neighborhood')
                    obj.Neighborhood = str2num(char(node.getTextContent));
                    node = node.getNextSibling;
                elseif strcmpi(node.getNodeName,'inputRadius')
                    obj.inputRadius = str2num(char(node.getTextContent));
                    node = node.getNextSibling;
                elseif strcmpi(node.getNodeName,'boostInc')
                    obj.boostInc = str2num(char(node.getTextContent));
                    node = node.getNextSibling;
                elseif strcmpi(node.getNodeName,'minActiveDuty')
                    obj.minActiveDuty = str2num(char(node.getTextContent));
                    node = node.getNextSibling;
                elseif strcmpi(node.getNodeName,'minOverlapDuty')
                    obj.minOverlapDuty = str2num(char(node.getTextContent));
                    node = node.getNextSibling;
                elseif strcmpi(node.getNodeName,'maxSegs')
                    obj.maxSegs = str2num(char(node.getTextContent));
                    node = node.getNextSibling;
                elseif strcmpi(node.getNodeName,'LearningRadius')
                    obj.LearningRadius = str2num(char(node.getTextContent));
                    node = node.getNextSibling;
                elseif strcmpi(node.getNodeName,'minOverlap')
                    obj.minOverlap = str2num(char(node.getTextContent));
                    node = node.getNextSibling;
                else
                    node = node.getNextSibling;
                end
            end
            
            %read in file settings
            cFileNodes = cFiles.getChildNodes;
            node = cFileNodes.getFirstChild;
            while~isempty(node)
                if strcmpi(node.getNodeName,'configfile')
                    obj.configFile = char(node.getTextContent);
                    node = node.getNextSibling;
                elseif strcmpi(node.getNodeName,'lastDir')
                    obj.lastDir = char(node.getTextContent);
                    node = node.getNextSibling;
                else
                    node = node.getNextSibling;
                end
            end
            
        end
    end
end