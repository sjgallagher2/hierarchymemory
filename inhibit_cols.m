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
    
    %Find the max values, assuming there are multiple
    for i = 1:desiredLocalActivity
        vec = find(max(neighborhood) == neighborhood);
        for j = 1:numel( vec )
            winners(1,i) =  vec(j);
            i = max(1,i-1);
        end
        neighborhood(vec) = 0; %replace previous maximums with 0
    end
    
end