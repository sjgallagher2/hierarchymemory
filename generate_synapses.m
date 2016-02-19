%generate_synapses.m
%Sam Gallagher
%12 Feb 2016
%
%This function creates j synapses with permanences of 0.00. The synapses is
%a structure, an object that is somewhat unique to MATLAB, but is easy to
%implement. To access, use s.perm and s.connected

function s = generate_synapses(j)
    for i = [1:j] 
        s(i) = struct('perm',0.00,'connected',false);
    end
end
