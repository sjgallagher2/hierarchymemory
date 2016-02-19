%
%Sam Gallagher
%17 February 2016
%
%

function show_active_columns(nCols,active_columns)
    myMap = [[1,1,1];[0,0,0];[1,0,0];[0.5,0.5,0.5];[1,1,0]];
    activevisual = ones(1,nCols);
    
    for iter = active_columns
        activevisual(iter) = 4;
    end
        
    activevisual = vec2mat(activevisual,ceil( sqrt(nCols ) ) )+1;
    
    figure;
    colormap(myMap);
    hold on;
    image(activevisual)
end