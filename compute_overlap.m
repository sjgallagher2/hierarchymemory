%compute_overlap.m
%Sam Gallagher
%13 Feb 2016
%
%This function computes the overlap of the input dendrite segment and the
%given data, which could be cells or the input data. The overlap is how
%many connected synapses are connected to active inputs. 

function overlap = compute_overlap(in,seg,min_overlap,boost)
    overlap = 0;
    segSize = size(seg(:,1));
    in = transpose(in);
    for loc = 1:segSize(1)
        if seg(loc,3) == 1
            if in(seg(loc,1)) > 0
                overlap = overlap+1;
            end
        end
    end
    if overlap < min_overlap
        overlap = 0;
    end
    overlap = overlap*boost;
end
