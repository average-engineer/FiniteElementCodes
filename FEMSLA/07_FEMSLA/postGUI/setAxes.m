function setAxes(hAxes)
%SETAXES Sets the Axes Properties to ilbCalfemGUI default
    
 grid on;
 xlabel(hAxes, 'x');
 ylabel(hAxes, 'y');
 zlabel(hAxes, 'z');
 set(hAxes, 'Box', 'off', 'nextplot', 'replace');
 axis(hAxes, 'vis3d');
end

