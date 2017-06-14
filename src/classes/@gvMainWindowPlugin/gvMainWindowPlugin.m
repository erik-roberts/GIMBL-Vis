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
  
  
  %% Other properties %%
  properties (Hidden)
    controller
    view
  end
  
  properties (Constant, Hidden)
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
    
  end
  
  
  %% Hidden methods %%
  methods (Hidden)
    panelHandle = makePanelControls(pluginObj, parentHandle)
    
    makeWindowControls(pluginObj, parentHandle)
  end
  
  
  %% Protected methods %%
  methods (Access = protected)
     
    makeFig(pluginObj)
    
    makeMenu(pluginObj, parentHandle)
    
    makeHypercubePanelControls(pluginObj, parentHandle)

  end
  
  %% Callbacks %%
  methods (Static, Access = protected)
    
    function CloseRequestFcn(src, evnt)
      % Close request function
      
      selection = questdlg('Save GIMBL-Vis object before closing?',...
        'GIMBL-Vis',...
        'Cancel','Yes','No', 'No');
      switch selection
        case 'No'
          delete(gcf)
        case 'Yes'
          % TODO
          error('Not implemented yet');
        case 'Cancel'
          return
      end
    end
    
    
    function Callback_activeHyperCubeMenu(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      newActiveHypercube = src.String{src.Value};
      
      pluginObj.controller.view.setActiveHypercube(newActiveHypercube);
    end
    
    
    function Callback_loadPluginCheckbox(src, evnt)
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
