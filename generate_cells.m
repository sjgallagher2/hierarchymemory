%generate_cells.m
%Sam Gallagher
%29 Feb 2016
%
%This module will generate an array of cell objects.
function cells = generate_cells(nCols,nCells,nSegs,nDendrites,synThreshold,LearningRadius,segment,cell)
    cells = [];
    for i = 1:nCols
        for j = 1:nCells
            cell.col = i;
            cell.layer = j;
            for s = 1:nSegs
                cell.segs = [ cell.segs segment ];
                cell.segs(s) = [ segment ];
                [ cell.segs(s).locations cell.segs(s).perm cell.segs(s).synCon ] = make_distal_segment(LearningRadius,synThreshold,nDendrites,nCols,nCells,i,j);
            end
            cells = [cells cell];
        end
    end
end