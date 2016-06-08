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
        
        %SP and TM settings
        synTreshold
        synInc
        synDec
        nDendrites                          %percentage
        minSegOverlap
        columns                              %percentage
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
        
        %Config settings
        percentSet = false;
        dataSize
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
            settings(8) = obj.synTreshold;
            settings(9) = obj.synInc;
            settings(10) = obj.synDec;
            settings(11) = obj.nDendrites;
            settings(12) = obj.minSegOverlap;
            settings(13) = obj.columns;
            settings(14) = obj.cellsPerCol;
            settings(15) = obj.desiredLocalActivity;
            settings(16) = obj.Neighborhood;
            settings(17) = obj.inputRadius;
            settings(18) = obj.boostInc;
            settings(19) = obj.minActiveDuty;
            settings(20) = obj.minOverlapDuty;
            settings(21) = obj.maxSegs;
            settings(22) = obj.LearningRadius;
            settings(23) = obj.minOverlap;
            settings(24) = false;
            settings(25) = obj.dataSize;
        end
        function setToDefault(obj)
            %sets SP and TM settings to default values
            obj.synTreshold = 0.2;
            obj.synInc = 0.075;
            obj.synDec = -0.05;
            obj.nDendrites = 0.5;
            obj.minSegOverlap = 10;
            obj.columns = 0.3;
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
        
        function complete = updateConfigPercentages(obj)
            complete = false;
            if obj.percentSet == false
                if objdataSize > 0
                    obj.nDendrites = obj.nDendrites*data_size;
                    obj.columns = obj.columns*data_size;
                    obj.percentSet = true;
                    complete = true;
                end
            end
        end
        
        function readFormattedConfig(obj,settings)
            %take in a column vector in order which contains the config
            %data. Typically comes from a file.
            obj.region = settings(1);
            obj.reps = settings(2);
            obj.htm_time = settings(3);
            obj.seq_time =settings(4);
            obj.temporal_memory = settings(5);
            obj.spatial_pooler = settings(6);
            obj.TM_delay = settings(7);
            obj.synTreshold = settings(8);
            obj.synInc = settings(9);
            obj.synDec = settings(10);
            obj.nDendrites = settings(11);
            obj.minSegOverlap = settings(12);
            obj.columns = settings(13);
            obj.cellsPerCol = settings(14);
            obj.desiredLocalActivity = settings(15);
            obj.Neighborhood = settings(16);
            obj.inputRadius = settings(17);
            obj.boostInc = settings(18);
            obj.minActiveDuty = settings(19);
            obj.minOverlapDuty = settings(20);
            obj.maxSegs = settings(21);
            obj.LearningRadius = settings(22);
            obj.minOverlap = settings(23);
            obj.percentSet = settings(24);
            obj.dataSize = settings(25);
        end
    end
end