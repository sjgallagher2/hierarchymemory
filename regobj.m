%regobj.m
%Sam Gallagher
%16 June 2016
%
%An object to hold region information, not including configuration. This
%leaves columns, cells, output, prediction, and active columns

classdef regobj
    properties
        id
        columns
        cells
        activeColumns
        prediction
        output
        queue
        correctPredictions
        multiStep
    end
    methods
        function obj = reg_init(obj,id)
            obj.id = id;
            obj.columns = [];
            obj.cells = [];
            obj.activeColumns = [];
            obj.prediction = [];
            obj.output = [];
            obj.queue = [];
            obj.correctPredictions = [];
            multiStep = false;
        end
        
    end
end