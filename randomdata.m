%randomdata.m
%Sam Gallagher
%7 July 2016
%
%Generates random data of a given sparsity s at square size z
%Size z is squared to give final size
%Sparsity s is a percentage of the data space that will be active. Higher
%sparsity means fewer active bits, with sparsity == 1 meaning no active
%bits, and sparsity == 0 meaning all active

function d = randomdata(s, z, reps)
    z = z^2;    
    
    if z>0
        d =zeros(reps,z);
        for j = 1:reps
            %Decide how many numbers we need
            n = floor(z - (s*z));
            for i = 1:n
                r = randi(z,1,1);
                d(j,r) = 1;
            end
        end
    end
    d = transpose(d);
end