%compute_overlap.m
%Sam Gallagher
%13 Feb 2016
%
%This function computes the overlap of the input dendrite segment and the
%given data, which could be cells or the input data.

function overlap = compute_overlap(in,seg,min_overlap,boost)
    overlap = 0;
    for iter = 1:numel(in)
        overlap = overlap+in(seg);
    end
    if overlap < min_overlap
        overlap = 0;
    end
    overlap = overlap*boost;
end
