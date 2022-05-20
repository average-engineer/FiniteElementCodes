function output_txt = updatePostDataCursor(obj, event_obj)
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).
 
 global nodes displacement post_dcm_obj;
 
 cursorInfo = getCursorInfo(post_dcm_obj);   % struct of all dataTips
 pos = reshape([cursorInfo(1,:).Position]', 3, [])';    % position of all dataTips
 myPos = get(event_obj, 'Position');    % position of this dataTip
 
 % find rows in deformed nodes matrix
 defCoords = nodes.data(:,2:end) + displacement.scale * displacement.data(:,2:4);
 ns = size(pos,1);
 nodes.i = zeros(ns, 1);
 for j = 1 : ns
    nodes.i(j) = findVectorInMatrix(defCoords, pos(j,:));
 end
 myI = findVectorInMatrix(defCoords, myPos);
 
 ID = displacement.data(myI, 1);
 U = displacement.data(myI, 2);
 V = displacement.data(myI, 3);
 W = displacement.data(myI, 4);
 
 output_txt = {['ID: ', num2str(ID)],...
               ['U: ', num2str(U,4)],...
               ['V: ', num2str(V,4)]};

 % If there is a Z-coordinate in the position, display it as well
 if length(pos) > 2
    output_txt{end+1} = ['W: ',num2str(W,4)];
 end
 
 % Update Selected Node position
  set(nodes.hP, 'XData', pos(:,1), 'YData', pos(:,2), 'ZData', pos(:,3));
  set(nodes.hT, 'Position', myPos, 'String', num2str(ID));
 
end

