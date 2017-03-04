function gvPlotPanelMouseMoveCallback(figH, mouseData)

if ~isempty(figH.Children)
  
  mousePosPx = get(figH, 'CurrentPoint'); %pixels
  figPos = figH.Position;
%   mousePosRel = mousePosPx ./ figPos(3:4); %relative
  
  % Get all axes
  ax = findobj(figH.Children,'type','axes');
  
  axPos = cat(1,ax.Position);
  
  % Find Positions of LL and UR corners for each ax
  axLLx  = axPos(:,1)*figPos(3);
  axLLy  = axPos(:,2)*figPos(4);
  axURx  = (axPos(:,1)+axPos(:,3))*figPos(3);
  axURy  = (axPos(:,2)+axPos(:,4))*figPos(4);
  
  % determine which axis
  axInd = find((mousePosPx(1)>=axLLx) .* (mousePosPx(1)<=axURx) .* (mousePosPx(2)>=axLLy) .* (mousePosPx(2)<=axURy));
  
  currAx = ax(axInd);
  mouseAxPosInScale = get(currAx, 'CurrentPoint'); %in axis scale
  axPos = get(currAx, 'Position');

  keyboard

  % find nearest point
  
  % check if distance to nearest point is < x% of axis size
  
  
  % For testing
  fprintf('Mouse Pos: %s\n', num2str(mousePosPx))
  fprintf('Mouse Ax Pos: %s\n', num2str(mouseAxPosInScale(1,:)))
end

end
