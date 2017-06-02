%% gvMainWindow - UI Main Window Class for GIMBL-Vis
%
% Description: This class is intended to be inherited by gvView to extend its
% methods to supprt a GIMB-Vis main window

classdef gvMainWindow < handle
  
  properties
    mainWindow = struct()
  end
  
  methods
    openMainWindow(viewObj)
    
    createMainWindowFig(viewObj)
    
    createMenu(viewObj, parentHandle)
    
    dataPanelheight = createDataPanelControls(viewObj, parentHandle)
    
    createDataPanelTitles(viewObj, parentHandle)
    
    createHypercubePanelControls(viewObj, parentHandle)
    
    createImagePanelControls(viewObj, parentHandle)
    
    createPlotMarkerPanelControls(viewObj, parentHandle)
    
    createPlotPanelControls(viewObj, parentHandle)
  end
  
  %% Callbacks
  methods (Static)
    function resetCallback(src, evnt)
      src.UserData.openMainWindow(); % reopen main window
    end
  end
  
end