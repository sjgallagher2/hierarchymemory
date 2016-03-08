%run_sp.m
%Sam Gallagher
%7 March 2016
%
%This program will run a spatial pooler from start to finish, with the
%possibility of recycling after equilibrium is found to a next region

send_in = generate_input();
for levels = 1:2
    r_out = region( send_in );
    send_in = [];
    for i = 1:50
        send_in = [send_in r_out];
    end
end
