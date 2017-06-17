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

    panelHandle = makePanelControls(pluginObj, parentHandle)
    
  end
  
  
  %% Protected methods %%
  methods (Access = protected)
    
    dataPanelheight = makeDataPanelControls(pluginObj, parentHandle)
    
    makeDataPanelTitles(pluginObj, parentHandle)
    
  end
  
  %% Callbacks %%
  methods (Static)

    function Callback_activeHypercubeNameEdit(src, evnt)
      pluginObj = src.UserData.pluginObj;
      
      newActiveHypercubeName = src.String;
      
      notify(pluginObj.controller, 'activeHypercubeNameChanged',gvEvent('activeHypercubeName', newActiveHypercubeName))
    end
    
  end
  
end
