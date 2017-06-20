function iterate(pluginObj)
disabledDims = pluginObj.view.dynamic.disabledDims;

if hObject.Value && (~isValidFigHandle('handles.PlotWindow.figHandle') || ~handles.PlotWindow.nViewDims) || all(disabledDims)
  wprintf('Cannot iterate without a visible Plot Window, at least 1 "view" variable, and at least 1 variable not disabled.')
  hObject.Value = 0;
  return
elseif hObject.Value% turned on
  hObject.String = sprintf('( %s ) Iterate', char(8545)); %pause char (bars)
else % turned off
  hObject.String = sprintf('( %s ) Iterate', char(9654)); %start char (arrow)
end

% Vars
nDimVals = handles.mdData.nDimVals;

viewDims = handles.PlotWindow.viewDims;
if sum(viewDims) > 2
  viewDims(:) = 0;
end
incrDims = ~viewDims;

% Loop
iterBool = hObject.Value;
while iterBool
  tic
  
  incrementSliders();
  
  % Check for off
  iterBool = hObject.Value;
  
  % Check for delay time
  delayTime = handles.delayBox.Value;
  iterTime = toc;
  delayTimeFinal = max( (delayTime - iterTime), 0);
  pause(delayTimeFinal)
end

%% Sub functions
  function incrementSliders()
    handles = getappdata(handles.output, 'UsedByGUIData_m');
    
    axInd = handles.PlotWindow.axInd;
    axInd(disabledDims) = nDimVals(disabledDims); % set disabled dims to max
    
    
    %% New slider position
    if any(axInd < nDimVals) % Increment
      % find new axis indices
      axIndNew = recursiveIterate(axInd, nDimVals, 1);
      incrAxLogical = axIndNew - axInd; % includes resets as negatives and increments as 1, all doubles
      resetAx = incrAxLogical < 0;
      incrAxLogical(resetAx) = 0; % remove resets from incr
      incrAxLogical = logical(incrAxLogical);
      
      % change slider that icnrements
      sliderObject = handles.MainWindow.Handles.sH(incrAxLogical);
      sliderObject.Value = sliderObject.Value + sliderObject.SliderStep(1)*(sliderObject.Max-sliderObject.Min);
      handles = gvSliderChangeCallback(sliderObject, eventdata, handles);
    else
      resetAx = incrDims;
      resetAx(disabledDims) = 0;
    end %if
    
    %% Reset any sliders
    % loop over slider handles and set value to min
    if any(resetAx)
      for iSlider = find(resetAx) %logical to indices
        sliderObject = handles.MainWindow.Handles.sH(iSlider);
        sliderObject.Value = -inf;
        
        handles = gvSliderChangeCallback(sliderObject, eventdata, handles);
        
        % Update handles structure
        guidata(hObject, handles);
      end
    end
    
    %% Update plot and image
    % replot
    handles = gvPlot(hObject, eventdata, handles);
    
    % reshow image
    gvPlotWindowMouseMoveCallback(handles.PlotWindow.figHandle, []);
    
    % Update handles structure
    guidata(hObject, handles);
    
  end %incrementSliders

end %main fun

%% Private functions
function ind = recursiveIterate(ind, maxInd, currI)

if currI < length(ind)
  if any(ind(currI+1:end) ~= maxInd(currI+1:end))
    currI = currI+1;
    ind = recursiveIterate(ind, maxInd, currI);
  else
    ind(currI) = ind(currI)+1;
    ind(currI+1:end) = 1;
  end
else
  ind(currI) = ind(currI)+1;
end

end
