%make_proximal_segment.m
%Sam Gallagher
%12 Feb 2016
%
%This function generates a proximal dendrite segment connected to input locations
%i_radius determines how far from the random center, col_center, 
%the connection can be. Output, seg, is a list of indices.
%The return is a 3 x nDendrite matrix
    
function [inLoc,perm,con] = make_proximal_segment(n_dendrites, i_radius, dat_length, col_center,syn_thresh)
   
    %maxLoc is the maximum location number we can set as an indice in
    %the final segment. minLoc is the minimum. The index must be
    %between 0 and dat_length.
    
    %Seed the random generator
    rng('shuffle');
    
    %Set bounds
    maxLoc = min(col_center+i_radius, dat_length);
    minLoc = max(col_center-i_radius, 1);
    inLoc = [];
    perm = [];
    con = [];
    
    %We need to make sure we can actually find as many elements in the
    %given input radius based on the dendrite ratio, and column center. To
    %find the number of nearby input spaces in a linear array, simply take
    %maxLoc-minLoc and see if there are n_dendrites available.
    
    if n_dendrites <= (maxLoc-minLoc)
        for i = 1:(n_dendrites) %generate iter new dendrites in the segment
            tempseg = inLoc; %hold the current state of the segment
            
            %The segment is made of random numbes between minLoc and maxLoc
            inLoc(i) = randi([minLoc,maxLoc],1);
            %while any(inLoc(i) == tempseg) %make sure we haven't already assigned this position
             %   inLoc(i) = randi([minLoc,maxLoc],1);
            %end
            %this next line creates the synapses, which occupy columns 2
            %and 3, the perm and connectivity, resp. Uses a random
            %distribution that centers slightly to the left of the
            %threshold, such that 66% synapses arent starting
            %connected.
            r = mod(rand(), 0.05) + syn_thresh - 0.03;  
            [perm(i) con(i)] = update_s( 0, 0 , syn_thresh , mod(rand(),0.05)+syn_thresh-0.03 );
        end
    else
        fprintf('Error: There will not be enough dendrites in this radius\n\n')
    end
end