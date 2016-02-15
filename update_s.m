%update_s.m
%Sam Gallagher
%12 Feb 2016
%
%This function updates the synapses input to. Updates permanences, and
%if their permanences are above the given threshold, t, the connected value
%'c' is set to 'true'

function s = update_s(s_in,t,inc)
    s = s_in; %we'll work with s
    
    s(1) = s(1)+inc;
    if s(1) >= t
        s(2) = 1;
    elseif s(1) <= t
        s(2) = 0;
    end
    
end
