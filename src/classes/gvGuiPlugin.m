%% gvGuiPlugin - Abstract GUI Plugin Class for GIMBL-Vis
%
% Description: This abstract class provides a template interface for GIMBL-Vis
%              gui plugins

classdef (Abstract) gvGuiPlugin < gvPlugin
  
  %% Abstract Properties %%
  properties (Abstract)
    handles
  end
  
  %% Concrete Properties %%
  properties (SetAccess = protected) % read-only
    view
    
    userData = struct()
  end
  
  properties (Dependent) % read-only
    fontSize
    fontWidth
    fontHeight
  end
  
  %% Events %%
  events
    panelControlsMade
  end
  
  
  %% Concrete Methods %%
  methods
    
    function pluginObj = gvGuiPlugin(varargin)
      pluginObj@gvPlugin(varargin{:});
      
      pluginObj.userData.pluginObj = pluginObj;
    end
    
    
    function setup(pluginObj, cntrlObj)
      % overload setup to add view
      
      setup@gvPlugin(pluginObj, cntrlObj);
      
      pluginObj.view = pluginObj.controller.view;
    end
    
    
    function tag = panelTag(pluginObj, str)
      tag = [pluginObj.pluginFieldName '_panel_' str];
    end
    
    
    function tag = figTag(pluginObj)
      tag = [pluginObj.pluginFieldName '_window'];
    end
    
    
    function tag = windowTag(pluginObj, str)
      tag = [pluginObj.pluginFieldName '_window_' str];
    end
    
    
    function handle = callbackHandle(pluginObj, tag)
      handle = str2func([pluginObj.pluginClassName '.Callback_' tag]);
    end
    
    
    function findObjects(pluginObj)
      pluginObj.handles.all = sortByTag(findobj('-regexp','Tag',['^' pluginObj.pluginFieldName]));
    end
    
    
    function value = get.fontSize(pluginObj)
      value = pluginObj.view.fontSize;
    end
    
    function value = get.fontWidth(pluginObj)
      value = pluginObj.view.fontWidth;
    end
    
    function value = get.fontHeight(pluginObj)
      value = pluginObj.view.fontHeight;
    end
    
  end
  
  %% Abstract Methods %%
  methods (Abstract)
    panelHandle = makePanelControls(pluginObj, parentHandle)
  end
  
end
