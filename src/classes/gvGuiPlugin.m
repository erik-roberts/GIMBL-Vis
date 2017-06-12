%% gvGuiPlugin - Abstract GUI Plugin Class for GIMBL-Vis
%
% Description: This abstract class provides a template interface for GIMBL-Vis 
%              gui plugins

classdef (Abstract) gvGuiPlugin < gvPlugin

  %% Abstract Properties %%
  properties (Abstract, Hidden)
    view
    handles
  end
  
  properties (Access = private)
    userData = struct()
  end
  
  %% Concrete Methods %%
  methods
    
%     function pluginObj = gvGuiPlugin(cntrlObj)
%       pluginObj@gvPlugin(cntrlObj);
%     end
    
  end
  
end
