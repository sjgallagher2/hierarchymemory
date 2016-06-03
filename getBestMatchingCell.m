%getBestMatchingCell.m
%Sam Gallagher
%31 May 2016
%
%Returns the cell in a column with the best segment, the fewest segments,
%or in 1-2-3 order if none have segments

function [bestcell, newSeg] = getBestMatchingCell(column, cells, n, t)
    bestcell = -1;
    bestcellsegs = -1;
    bestcell_segment = 0;
    newSeg = false;
    %fprintf('Finding best matching cell for column %d\n',column)
    for i = 1:n.cellpercol
        mycell = getcell_loc(i,column,n);
        mycell = cells(mycell);
%        fprintf('Cell %d has %d segment(s).\n',mycell.layer,numel(mycell.segs) )
        %Find the cell with the best segment
        best_seg = getBestMatchingSeg(mycell,cells,t);
        if bestcell == -1
            if numel(best_seg) > 0
                bestcell = mycell.layer;
                
                %If this segment has connections made, start with a new
                %segment
                for q = 1:numel(best_seg)
                    for j = 1:numel(mycell.segs(best_seg(q)))
                        if mycell.segs(best_seg(q)).synCon(j) == 1
                            mycell.segs(best_seg(q)).overlap = mycell.segs(best_seg(q)).overlap + 1;
                        end
                    end
                    if mycell.segs(best_seg(q)).overlap > 0
                        newSeg = true;
                    end
                end
            end
        end
    end
    %if you haven't found one, choose one with the fewest segments
    if bestcell == -1
        newSeg = true;
        for i = 1:n.cellpercol
            mycell = getcell_loc(i,column,n);
            mycell = cells(mycell);
            if bestcellsegs > 0
                if numel(mycell.segs) < bestcellsegs
                    bestcell = mycell.layer;
                    bestcellsegs = numel(mycell.segs);
                end
            elseif bestcellsegs == -1
                bestcell = mycell.layer;
                bestcellsegs = numel(mycell.segs);
            end
        end
    end
end