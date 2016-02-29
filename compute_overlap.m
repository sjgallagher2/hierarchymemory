%compute_overlap.m
%Sam Gallagher
%13 Feb 2016
%
%This function computes the overlap of the input dendrite segment and the
%given data, which could be cells or the input data. The overlap is how
%many connected synapses are connected to active inputs. 

function overlap = compute_overlap(in,seg,min_overlap)
    overlap = 0;
    segSize = size(seg.locations);
    in = transpose(in);
    for loc = 1:segSize(2)
        if seg.synCon(loc) == 1
            if in(seg.locations(loc)) > 0
                overlap = overlap+1;
            end
        end
    end
    if overlap < min_overlap
        overlap = 0;
    end
    overlap = overlap*seg.boost;
end
