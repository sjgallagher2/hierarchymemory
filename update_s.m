%update_s.m
%Sam Gallagher
%12 Feb 2016
%
%This function updates the synapses input to it. Updates permanences, and
%if their permanences are above the given threshold, t, the connected value
%'c' is set to 'true'
 
function [s_perm s_con] = update_s(in_perm,in_con,th,inc)
    if numel(in_perm) == 1
        in_perm = in_perm + inc;
        if in_perm > th
            in_con = 1;
        elseif in_perm < th
            in_con = 0;
        elseif in_perm < 0
            in_perm = 0;
        elseif in_perm > 1
            in_perm = 1;
        end
        s_perm = in_perm;
        s_con = in_con;
    else
        in_perm = in_perm + inc;
        for p = 1:numel(in_perm)
            if in_perm(p) > th
                in_con(p) = 1;
            elseif in_perm(p) < th
                in_con(p) = 0;
            elseif in_perm(p) < 0
                in_perm(p) = 0;
            elseif in_perm(p) > 1
                in_perm(p) = 1;
            end
        end
        s_perm = in_perm;
        s_con = in_con;
    end
end
