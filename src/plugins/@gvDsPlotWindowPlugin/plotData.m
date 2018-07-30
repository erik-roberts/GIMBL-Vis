function plotData(pluginObj, index)
% TODO: handle missing data, fix axis labels on copy

try
  pluginObj.fig2copy = 'lock'; % lock out other function calls
  
  cwd = pluginObj.controller.app.workingDir;
  
  modeVal = pluginObj.view.dynamic.dsPlotModeVal;
  importMode = pluginObj.importModes{modeVal};
  
  % update stored index
  pluginObj.lastIndex = index;
  
  modelObj = pluginObj.controller.model;
  
  fieldExistBool = isfield(modelObj.activeHypercube.meta, 'simData');
  
  if ~fieldExistBool || length(modelObj.activeHypercube.meta.simData) < index || isempty(modelObj.activeHypercube.meta.simData{index})
    modelObj = pluginObj.controller.model;
    
    switch importMode
      case 'auto' % load all data
        pluginObj.vprintf('[gvDsPlotWindowPlugin] Importing all DS data \n')
        if ~fieldExistBool
          modelObj.activeHypercube.meta.simData = dsImport(cwd, 'as_cell',1);
        else % fill in missing
          missingInds = find(cellfun(@isempty, modelObj.activeHypercube.meta.simData));
          
          tempData = dsImport(cwd, 'as_cell',1, 'simIDs', missingInds);
          
          if isempty(tempData)
            wprintf('Data did not load.');
            return
          end
          
          modelObj.activeHypercube.meta.simData(missingInds) = tempData;
        end
        
        fieldExistBool = true;
      case {'withPlot' 'tempWithPlot'}
        pluginObj.vprintf('[gvDsPlotWindowPlugin] Importing sim_id=%i \n', index)
        tempData = dsImport(cwd, 'as_cell',1, 'simIDs', index);
        
        if isempty(tempData)
          wprintf('Data did not load.');
          return
        end
        
        modelObj.activeHypercube.meta.simData(index) = tempData;
        
        fieldExistBool = true;
    end
    
  end
  
  if fieldExistBool
    data = modelObj.activeHypercube.meta.simData;
  else
    wprintf('gvDsPlotWindowPlugin: DS Data not imported. Tip: click the "Import All DS Data" button in DsPlot');
    cleanup();
    return
  end
  
  figH = pluginObj.handles.fig;
  
  % open window if closed
  if ~isValidFigHandle(figH)
    pluginObj.openWindow();
    figH = pluginObj.handles.fig;
  end
  
  if ~isempty(data) && length(data) >= index && ~isempty(data{index})
    thisData = data{index};
    
    clf(figH);
    plotAxH = makeBlankAxes(figH);
    th = addTextToBlankAx(plotAxH, sprintf('Plotting index %i...', index) );
    
    % plot
    fnBox = findobjReTag('dsPlot_panel_funcBox');
    plotFn = str2func(fnBox.String);
    h = figH; % enable this as alias in gui
    try
      fnOptBox = findobjReTag('dsPlot_panel_funcOptsBox');
      
      plotFnOpts = eval(['{' fnOptBox.String ' ''visible'',''off''' '}']);
    catch
      wprintf('gvDsPlotWindowPlugin: Could not evaluate dsPlot "Function Options".')
      
      cleanup();
      
      return
    end
    plotH = feval(plotFn, thisData, plotFnOpts{:});
    pluginObj.fig2copy = plotH; % allows lock in Callback_mouseMove
    
    
    % copy axes from plotFn handle output
    if figH ~= plotH(1)
      % delete axis and title
      %   delete(th);
      delete(findobj(figH,'type','axes'));
      
      axh = findobj(plotH,'type','axes');
      copyobj(axh, figH);
      plotAxH = findobj(figH.Children,'type','axes');
      close(plotH)
    else
      delete(th)
    end
    
    % close hidden plot from plotFn eval
    pluginObj.fig2copy = [];
    
    % fig title
    figTitle = sprintf('SimID:%i; Vary:', index);
    for varInd = 1:length(thisData.varied)
      thisVary = thisData.varied{varInd};
      figTitle = sprintf('%s %s=%g,', figTitle, strrep(thisVary,'_','\_'), thisData.(thisVary)); % replace '_' with '\_' to avoid subscript
    end
    figTitle(end) = ''; % remove trailing comma
    
    suptitle2(figTitle, figH);
  else
    pluginObj.fig2copy = [];
    
    clf(figH);
    plotAxH = makeBlankAxes(figH);
    
    addTextToBlankAx(plotAxH, sprintf('No data found for index %i', index) );
  end
  
  cleanup();
  
catch err
  cleanup();
  rethrow(err);
end

%% Nested Fn
  function cleanup()
    % remove temp data
    if strcmp(importMode, 'tempWithPlot')
      modelObj.activeHypercube.meta.simData{index} = [];
    end
    
    pluginObj.fig2copy = [];
  end

end % main

%% Local Fn
function th = addTextToBlankAx(axH, str)
th = text(axH, 0.1,0.5, str,...
  'FontUnits','normalized', 'FontSize',0.06);
end
