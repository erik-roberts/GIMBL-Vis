function openWindow(pluginObj)

% check for main window
warnBool = true;
mainWindowExistBool = pluginObj.view.checkMainWindowExists(warnBool);

if mainWindowExistBool && ~pluginObj.checkWindowExists()
    %% Make Image Window
    pluginObj.makeFig();
    
    pluginObj.addWindowOpenedListenerToPlotPlugin();
    pluginObj.addMouseMoveCallbackToPlotFig();
    
    notify(pluginObj, 'windowOpened');
end

end