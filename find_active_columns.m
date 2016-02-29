%find_active_columns.m
%Sam Gallagher
%20 Feb 2016
%
%This module finds the active columns and returns their column index in a
%list

function act = find_active_columns(columns, nCols)
    act = [];
    for i = 1:nCols
        if columns(i).active == 1
            act = [act i];
        end
    end
end