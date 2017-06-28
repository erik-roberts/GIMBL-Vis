function iterate(pluginObj)
% const var
hObject = findobjReTag('select_panel_iterateToggle');
nDimVals = cellfun(@length, pluginObj.controller.activeHypercube.axisValues);
sliderHandles = pluginObj.sliderHandles;

% Loop
iterBool = hObject.Value;
while iterBool
  tic
  
  % Changing Vars
  disabledDims = pluginObj.view.dynamic.disabledDims;
  viewDims = pluginObj.view.dynamic.viewDims;

  if sum(viewDims) > 2
    viewDims(:) = 0;
  end
  incrDims = ~viewDims;
  
  incrementSliders();
  
  % Check for off
  iterBool = hObject.Value;
  
  % Check for delay time
  delayBoxObj = findobjReTag('select_panel_delayValueBox');
  try
    delayTime = delayBoxObj.Value;
  catch
    if ~exist(delayTime,'var')
      delayTime = .1;
    end
  end
    iterTime = toc;
    delayTimeFinal = max( (delayTime - iterTime), 0);
    pause(delayTimeFinal)
end

%% Sub functions
  function incrementSliders()
    axInd = pluginObj.view.dynamic.sliderVals;
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
      sliderObject = sliderHandles(incrAxLogical);
      sliderObject.Value = sliderObject.Value + sliderObject.SliderStep(1)*(sliderObject.Max-sliderObject.Min);
      
      % Callback slider
      pluginObj.Callback_select_panel_slider(sliderObject, []);
    else
      resetAx = incrDims;
      resetAx(disabledDims) = 0;
    end %if
    
    %% Reset any sliders
    % loop over slider handles and set value to min
    if any(resetAx)
      for iSlider = find(resetAx) %logical to indices
        sliderObject = sliderHandles(iSlider);
        sliderObject.Value = 1;
        
        pluginObj.Callback_select_panel_slider(sliderObject, []);
      end
    end
    
    %% Update plot and image
    % replot
    notify(pluginObj.controller, 'doPlot');
    
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
