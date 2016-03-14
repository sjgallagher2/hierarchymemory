%getcell.m
%Sam Gallagher
%8 March 2016
%
%Returns a cell number for the given row,column location
function mycell = getcell_loc(r,c,n)
    if r > n.cellpercol
        disp('Error: cell is not within limits.');
        mycell = -1;
    elseif c > n.cols
        disp('Error: cell is not within limits.');
        mycell = -1;
    else
        mycell = (c-1)*n.cellpercol + r;
    end
    
end
