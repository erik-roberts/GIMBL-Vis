%% gvMainWindowPlugin - UI Main Window Class for GIMBL-Vis
%
% Description: An object of this class becomes a property of gvView to provide 
%              methods for a GIMBL-Vis main window

classdef gvMainWindowPlugin < gvWindowPlugin
  
  %% Public properties %%
  properties
    metadata = struct()
    handles = struct()
  end
  
  properties (Constant)
    pluginName = 'Main';
    pluginFieldName = 'main';
    
    windowName = 'GIMBL-Vis Toolbox';
  end

  
  
  %% Public methods %%
  methods
    
    function pluginObj = gvMainWindowPlugin(varargin)
      pluginObj@gvWindowPlugin(varargin{:});
    end
    
    
    openWindow(pluginObj)
    
    panelHandle = makePanelControls(pluginObj, parentHandle)

  end
  
  
  %% Protected methods %%
  methods (Access = protected)
     
    makeFig(pluginObj)
    
    makeWindowControls(pluginObj, parentHandle)
    
    makeMenu(pluginObj, parentHandle)
    
    makeHypercubePanelControls(pluginObj, parentHandle)

  end
  
  %% Callbacks %%
  methods (Static, Access = protected)
    
    function Callback_closeRequestFcn(src, ~)
      % Close request function
 
      pluginObj = src.UserData.pluginObj;
      closeMainWindowSaveDialogBool = pluginObj.controller.app.config.closeMainWindowSaveDialogBool;
      
      if ~closeMainWindowSaveDialogBool
        return % if config turns off this dialog win
      end
      
      selection = questdlg('Save GIMBL-Vis object before closing?',...
        'GIMBL-Vis',...
        'Cancel','Yes','No', 'No');
      switch selection
        case 'No'
          delete(pluginObj.handles.fig)
        case 'Yes'
          % TODO
          error('Not implemented yet');
        case 'Cancel'
          return
      end
    end
    
    
    function Callback_activeHyperCubeMenu(src, ~)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      newActiveHypercube = src.String{src.Value};
      
      pluginObj.controller.view.setActiveHypercube(newActiveHypercube);
    end
    
    
    function Callback_loadPluginCheckbox(src, ~)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      checkBool = src.Value;
      if checkBool
        pluginClassName = src.UserData.pluginClassName;
        pluginObj.controller.connectPlugin(pluginClassName);
      else
        pluginFieldName = src.UserData.pluginFieldName;
        pluginObj.controller.disconnectPlugin(pluginFieldName);
      end
    end
    
  end
  
end
