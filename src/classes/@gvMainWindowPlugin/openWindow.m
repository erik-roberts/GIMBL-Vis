function openWindow(pluginObj)

% check for main window
mainWindowExistBool = pluginObj.view.checkMainWindowExists();

if mainWindowExistBool
  pluginObj.vprintf('Reopening main window\n')
  
  pluginObj.handles.fig.delete()
end

%% Main Window Fig
pluginObj.makeFig();

%% Layout
pluginObj.makeWindowControls( pluginObj.handles.fig );

%% Menu
% These handles are arranged in a cell matrix corresponding to the positions in 
% the toolbar and menu columns. The first row contains the toolbar titles.

makeMenu(pluginObj, pluginObj.handles.fig);

end
