% blackandwhiteimage.m
% Sam Gallagher
% 3 March 2016
%
% Much needed image creator which takes in a matrix size and lets the user
% draw an image in black and white. The image is returned as a 1xn vector
% for use in the HTM CLA

function img_mat = blackandwhiteimage(aLim, frames)
    
    %Create the figure itself
    v1 = ones(aLim);
    img_mat = zeros(aLim^2,1);
    h.fig = figure();
    colormap([[1,1,1];[0,0,0];[0.85,0.85,0.85]])
    hold on
    h.img = image(v1);
    
    %Turn off the menubar and format the axes and sizing
    h.fig.MenuBar = 'none';
    axis([0,aLim+1,0,aLim+1]);
    
    %Make a text box
    hTextBox = uicontrol('Style','text','String','Press SPACE to continue','Position',[10,390,100,30]);
    for i = 1:frames
        %initialize variables for drawing mode functions
        if i > 1
            prevV = vec2mat(img_mat(:,i-1), aLim);
            v1 = ones(aLim);
            for b = 1:aLim
                for c = 1:aLim
                    if prevV(b,c) == 1
                        v1(c,b) = 3;
                    end
                end
            end
        else
            v1 = ones(aLim);
        end
        
        h.img = image(v1);
        draw = true;
        escButton = '';
        h.fig.CurrentCharacter = 'a';
        
        while(draw == true)
            escButton = h.fig.CurrentCharacter;
            if escButton == ' '
                draw = false;
            else
                [x,y,key] = ginput(1);
                if key == 1
                    %Place the x coordinate from the mouse and make sure it
                    %is an even number and is on the grid
                    x = round(x);
                    if x > aLim
                        x = aLim;
                    elseif x < 1
                        x = 1;
                    end

                    y = round(y);
                    if y > aLim
                        y = aLim;
                    elseif y < 1
                        y = 1;
                    end
                    if v1(y,x) == 2
                        v1(y,x) = 1;
                    else
                        v1(y,x) = 2;
                    end
                    h.img.CData = v1;
                end
            end
        end
        
        img_mat(:,i) = reshape(v1, [aLim^2,1]) - 1;
        for b = 1:aLim^2
            if img_mat(b,i) == 2
                img_mat(b,i) = 0;
            end
        end
        
    end
    close;
end
