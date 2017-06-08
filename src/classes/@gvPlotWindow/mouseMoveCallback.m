function mouseMoveCallback(src, evnt)

% TODO

windowFig = src;

viewObj = windowFig.UserData.windowObj.viewObj;

if ~isempty(windowFig.Children)
  
  mousePosPx = get(windowFig, 'CurrentPoint'); %pixels
  figPos = windowFig.Position;
%   mousePosRel = mousePosPx ./ figPos(3:4); %relative
  
  % Get all axes
  ax = findobj(windowFig.Children,'type','axes');
  
  axPos = cat(1,ax.Position);
  
  % Find Positions of LL and UR corners for each ax
  axLLx  = axPos(:,1)*figPos(3);
  axLLy  = axPos(:,2)*figPos(4);
  axURx  = (axPos(:,1)+axPos(:,3))*figPos(3);
  axURy  = (axPos(:,2)+axPos(:,4))*figPos(4);
  
  % determine which axis
  axInd = find((mousePosPx(1)>=axLLx) .* (mousePosPx(1)<=axURx) .* (mousePosPx(2)>=axLLy) .* (mousePosPx(2)<=axURy));
  
  if ~isempty(axInd)
    currAx = ax(axInd);
    mouseAxPosInScale = get(currAx, 'CurrentPoint'); %in axis scale
    % returns the points into and out of the plot volume
  %   axPos = get(currAx, 'Position');
    mouseAxPosInScale = mouseAxPosInScale(1,:);
    if mouseAxPosInScale(3) ~= 1 %in 3d scale
      return
    end
    mouseAxPosInScale = mouseAxPosInScale(1:2);

    % find nearest point
    plotDims = currAx.UserData.plotDims;
    nPlotDims = length(plotDims);
    if nPlotDims > 2 %only 1d or 2d
      return
    end
    axVals = viewObj.mdData.dimVals(plotDims);
    plotInd = nan(nPlotDims,1);
    for iAx = 1:nPlotDims
      plotInd(iAx) = nearest(axVals{iAx}, mouseAxPosInScale(iAx));
    end
    
    % find corresponding simID
    fullInd = viewObj.PlotWindow.axInd; % sliderInd
    fullInd(plotDims) = plotInd; % index of sliders with curr pos
    fullInd = num2cell(fullInd);
    simID = viewObj.mdData.data{1}{fullInd{:}};
    
    % show image
    viewObj.ImageWindow.simID = simID;
    if isValidFigHandle(viewObj.ImageWindow.handle)
      gvShowImage(viewObj);
    end
    
    % Update handles structure
    guidata(windowFig.UserData.MainFigH, viewObj);
    
     % TODO: % check if distance to nearest point is < x% of axis size
    
  %   % For testing
  %   fprintf('Mouse Pos: %s\n', num2str(mousePosPx))
  %   fprintf('Mouse Ax Pos: %s\n', num2str(mouseAxPosInScale(1,:)))
  end
end

end