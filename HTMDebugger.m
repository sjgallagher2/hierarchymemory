%debug.m
%Sam Gallagher
%6 June 2016
%
%Window to display debugging information

function dbg_f = HTMDebugger(nextline)
    if exist('dbg_f') == 0
        

        
    else
        lines = lines+1;
        str{lines} = nextline;
        textspace.String = str;
    end
    
end