%getcell.m
%Sam Gallagher
%8 March 2016
%
%Returns a cell number for the given row,column location, or an array of
%cells in a specified columns, depending on whether or not a cell layer is
%specified
function mycell = getcell(varargin)
    args = nargin;
    if args == 3
        %If only 3 inputs
        c = varargin{1};
        n = varargin{2};
        cells = varargin{3};
        mycell = [];
        
        %give all cells in the column
        if c > n.cols
            disp('Cell not within limits');
            mycell = -1;
        else
            for x = 1:n.cellpercol
                index = (c-1)*n.cellpercol + x;
                mycell = [mycell cells(index)];
            end
        end
    
    elseif args == 4
        %give one cell
        r = varargin{1};
        c = varargin{2};
        n = varargin{3};
        cells = varargin{4};
        
        if r > n.cellpercol
            disp('Error: cell is not within limits.');
            mycell = -1;
        elseif c > n.cols
            disp('Error: cell is not within limits.');
            mycell = -1;
        else
            index = (c-1)*n.cellpercol + r;
            mycell = cells(index);
        end
    end
    
end