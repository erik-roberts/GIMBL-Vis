%% gvSelect - Select GUI Class for GIMBL-Vis
%
% Description: An object of this class becomes a property of gvView to provide 
%              methods for a GIMBL-Vis plot window

classdef gvSelectPlugin < gvGuiPlugin

  %% Public properties %%
  properties
    metadata = struct()
    
    handles = struct()
  end
  
  
  properties (Constant)
    pluginName = 'Select';
    pluginFieldName = 'select';
  end
  
  
  %% Events %%
  events
    
  end
  
  
  %% Public methods %%
  methods
    
    function pluginObj = gvSelectPlugin(varargin)
      pluginObj@gvGuiPlugin(varargin{:});
    end
    
    
    function setup(pluginObj, cntrObj)
      setup@gvGuiPlugin(pluginObj, cntrObj);
      
      pluginObj.view.dynamic.nViewDims = 0;
      pluginObj.view.dynamic.nViewDimsLast = 0;
      pluginObj.view.dynamic.viewDims = [];
    end

    
    panelHandle = makePanelControls(pluginObj, parentHandle)
    
  end
  
  
  %% Protected methods %%
  methods (Access = protected)
    
    dataPanelheight = makeDataPanelControls(pluginObj, parentHandle)
    
    makeDataPanelTitles(pluginObj, parentHandle)
    
    function updateNumViewDims(pluginObj)
      % TODO
      pluginObj.handles;
    end
    
  end
  
  %% Callbacks %%
  methods (Static)

    function Callback_select_panel_activeHypercubeNameEdit(src, evnt)
      pluginObj = src.UserData.pluginObj;
      
      newActiveHypercubeName = src.String;
      
      notify(pluginObj.controller, 'activeHypercubeNameChanged',gvEvent('activeHypercubeName', newActiveHypercubeName))
    end
    
    
    function Callback_select_panel_viewCheckbox(src, evnt)
      pluginObj = src.UserData.pluginObj;
      
      pluginObj.updateNumViewDims();
    end
    
  end
  
end
