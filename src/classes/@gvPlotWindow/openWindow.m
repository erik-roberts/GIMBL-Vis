function openWindow(windowObj)

% check for main window
warnBool = true;
mainWindowExistBool = windowObj.viewObj.checkMainWindowExists(warnBool);

if mainWindowExistBool
  % check for plot window
  plotWindowExistBool = isValidFigHandle(windowObj.handles.fig);
  
  if plotWindowExistBool
    windowObj.vprintf('Reopening plot window\n')

    % delete plot window handles
    windowObj.handles.fig.delete()
    windowObj.handles.ax.delete()
  end
  
  % Make New Panel
  windowObj.createFig();
  
  % Add listeners
  plotListener = addlistener(windowObj, 'plotEvent', @gvPlotWindow.plotCallback);
  windowObj.viewObj.newListener( plotListener );
  
  % Data cursor
  windowObj.addDataCursor();
  
  % Create Axes/Update Panel
  windowObj.createAxes();
  
  % Plot
  notify(windowObj, 'plotEvent'); % TODO change this
end

end % main fn