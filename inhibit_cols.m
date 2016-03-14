%inhibit_cols.m
%Sam Gallagher
%17 Feb 2016
%
%This module takes a neighborhood of columns in and returns an array with
%the indices of the winning columns out based on the
%desiredLocalActivity. The neighborhood input is the overlaps of the
%columns in the neighborhood, not the column values themselves.

function winners = inhibit_cols(neighborhood, desiredLocalActivity)
    
    winners = ones(1,desiredLocalActivity);
    
    if max(neighborhood) == 0 %If the whole neighborhood fell under minOverlap, winners is a -1
        winners = [];
        winners = -1;
    else
        %Find the max values, assuming there are multiple
        i = 1;
        while i < desiredLocalActivity
            vec = find(max(neighborhood) == neighborhood);
            for j = 1:numel( vec )
                winners(1,i) =  vec(j);
                i = min(desiredLocalActivity,i+1);
            end
            neighborhood(vec) = 0; %replace previous maximums with 0
            i=i+1;
        end
    end
end