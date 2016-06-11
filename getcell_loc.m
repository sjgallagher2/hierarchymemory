%getcell.m
%Sam Gallagher
%8 March 2016
%
%Returns a cell number for the given row,column location
function mycell = getcell_loc(r,c,n)

%in this ONE instance, n is the config, and c is the column
    if r > n.cellsPerCol
        disp('Error: cell is not within limits.');
        mycell = -1;
    elseif c > n.columns
        disp('Error: cell is not within limits.');
        mycell = -1;
    else
        mycell = (c-1)*n.cellsPerCol + r;
    end
    
end
