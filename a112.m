v1 = zeros(1,144);
v1(1) = 1;
v1(13) = 1;
v1(25) = 1;
v1(37) = 1;

v2 = zeros(1,144);
v2(2) = 1;
v2(3) = 1;
v2(4) = 1;
v2(5) = 1;

v1 = transpose(v1);
v2 = transpose(v2);
v = [v1 v2 v1 v2 v1 v2 v1 v2 v1 v2 v1 v2 v1 v2 v1 v2 v1 v2 v1 v2];
v = [v v v];
region(v);