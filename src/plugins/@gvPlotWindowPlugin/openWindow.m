function openWindow(pluginObj)

% check for main window
warnBool = true;
mainWindowExistBool = pluginObj.view.checkMainWindowExists(warnBool);

if mainWindowExistBool
  % check for plot window
  plotWindowExistBool = isValidFigHandle(pluginObj.handles.fig);
  
  if plotWindowExistBool
    pluginObj.vprintf('Reopening plot window\n')

    % delete plot window handles
    pluginObj.handles.fig.delete()
    pluginObj.handles.ax.delete()
  end
  
  % Make New Panel
  pluginObj.makeFig();
  
  % Add listeners
  addListener(pluginObj, 'plotEvent', @gvPlotWindowPlugin.plotCallback);
  
  % Data cursor
  pluginObj.addDataCursor();
  
  % Make Axes/Update Panel
  pluginObj.makeAxes();
  
  % Plot
  pluginObj.plot();
end

end % main fn