%% gvAnalysisPlugin - Select GUI Class for GIMBL-Vis
%
% Description: An object of this class becomes a property of gvView to provide 
%              methods for a GIMBL-Vis analysis tab in the main  window.

classdef gvAnalysisPlugin < gvGuiPlugin
  
  %% Public properties %%
  properties (Constant)
    pluginName = 'Analysis'
    pluginFieldName = 'analysis'
  end
  
  properties
    metadata = struct()
    
    handles = struct()
  end
  
  %% Public methods %%
  methods
    
    function pluginObj = gvAnalysisPlugin(varargin)
      pluginObj@gvGuiPlugin(varargin{:});
    end
    
    
    function setup(pluginObj, cntrlObj)
      setup@gvGuiPlugin(pluginObj, cntrlObj);
    end

    
    panelHandle = makePanelControls(pluginObj, parentHandle)
    
  end
  
  %% Protected methods %%
  methods (Access = protected)
    
    function fns = getFnList(pluginObj)
      fnDir = fullfile(gv.RootPath, 'src', 'analysisFunctions');
      fns = lscell(fnDir);
%       fns = [sprintf('[ User Specified ]    %s',char(hex2dec('279E')) ); fns];
      fns = ['[ User Specified ]'; fns];
    end
    
  end
  
end