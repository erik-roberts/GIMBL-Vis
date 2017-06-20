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
  
  
  %% Public methods %%
  methods
    
    function pluginObj = gvSelectPlugin(varargin)
      pluginObj@gvGuiPlugin(varargin{:});
    end
    
    
    function setup(pluginObj, cntrObj)
      setup@gvGuiPlugin(pluginObj, cntrObj);
      
      addlistener(pluginObj, 'panelControlsMade', @gvSelectPlugin.Callback_panelControlsMade);
    end

    
    panelHandle = makePanelControls(pluginObj, parentHandle)
    
  end
  
  
  %% Protected methods %%
  methods (Access = protected)
    
    dataPanelheight = makeDataPanelControls(pluginObj, parentHandle)
    
    
    makeDataPanelTitles(pluginObj, parentHandle)
    
    
    function initializeDynamicVars(pluginObj)
      pluginObj.view.dynamic.nViewDimsLast = 0;
      pluginObj.updateViewDims();
      pluginObj.updateLockDims();
      pluginObj.updateDisabledDims();
    end
    
    
    function updateViewDims(pluginObj)
      viewCheckboxes = sort(findobj(pluginObj.view.windowPlugins.main.handles.fig, '-regexp', 'Tag','viewCheckbox'));
      pluginObj.view.dynamic.viewDims = [viewCheckboxes.Value];
      pluginObj.view.dynamic.nViewDims = sum([viewCheckboxes.Value]);
      
      if pluginObj.view.dynamic.nViewDims ~= pluginObj.view.dynamic.nViewDimsLast
        notify(pluginObj.controller, 'doPlot')
      end
      
      pluginObj.view.dynamic.nViewDimsLast = sum([viewCheckboxes.Value]);
    end
    
    
    function updateLockDims(pluginObj)
      % Don't need to update plot since value is already set, locking just
      % prevents any change
      
      lockCheckboxes = sort(findobj(pluginObj.view.windowPlugins.main.handles.fig, '-regexp', 'Tag','lockCheckbox'));
      pluginObj.view.dynamic.lockDims = [lockCheckboxes.Value];
      pluginObj.view.dynamic.nLockDims = sum([lockCheckboxes.Value]);
    end
    
    
    function updateDisabledDims(pluginObj)
      lockDims = pluginObj.view.dynamic.lockDims;
      viewDims = pluginObj.view.dynamic.viewDims;
      nViewDims = pluginObj.view.dynamic.nViewDims;

      % Disable sliders when all data is shown (dim < 3)
      if any(nViewDims == [1,2])
        disabledDims = logical(lockDims + viewDims);
      else
        disabledDims = logical(lockDims);
      end
      
      % update disabledDims
      pluginObj.view.dynamic.disabledDims = disabledDims;
      
      % set disables
      statusCellStr = cell(size(disabledDims));
      statusCellStr(disabledDims) = {'off'};
      statusCellStr(~disabledDims) = {'on'};
      
      sliders = sort(findobj(pluginObj.view.windowPlugins.main.handles.fig, '-regexp', 'Tag','slider\d+'));
      sliderVals = sort(findobj(pluginObj.view.windowPlugins.main.handles.fig, '-regexp', 'Tag','sliderVal\d+'));
      
      [sliders.Enable] = deal(statusCellStr{:});
      [sliderVals.Enable] = deal(statusCellStr{:});
    end
    
  end
  
  %% Callbacks %%
  methods (Static)

    function Callback_panelControlsMade(src, evnt)
      pluginObj = src;
      
      pluginObj.initializeDynamicVars();
    end
    
    function Callback_select_panel_editModeToggle(src, evnt)
      pluginObj = src.UserData.pluginObj;
      
      
      toggleObjs = findobj('-regexp','Tag','select_panel_.*Text.*');
      
      if src.Value
        [toggleObjs.Style] = deal('edit');
      else
        [toggleObjs.Style] = deal('text');
      end
      
    end
    
    
    function Callback_select_panel_activeHypercubeText(src, evnt)
      pluginObj = src.UserData.pluginObj;
      
      newActiveHypercubeName = src.String;
      
      notify(pluginObj.controller, 'activeHypercubeNameChanged',gvEvent('activeHypercubeName', newActiveHypercubeName))
    end
    
    
    function Callback_select_panel_varText(src, evnt)
      pluginObj = src.UserData.pluginObj;
      
      axind = str2double(getNumSuffix(src.Tag));
      
      assert(~isnan(axind), 'Variable axis index not found')
      
      pluginObj.controller.activeHypercube.axis(axind).name = src.String;
    end
    
    
    function Callback_select_panel_viewCheckbox(src, evnt)
      pluginObj = src.UserData.pluginObj;
      
      pluginObj.updateViewDims();
      pluginObj.updateDisabledDims()
    end
    
    
    function Callback_select_panel_lockCheckbox(src, evnt)
      pluginObj = src.UserData.pluginObj;
      
      pluginObj.updateLockDims();
      pluginObj.updateDisabledDims()
    end
    
    
    function Callback_select_panel_slider(src, evnt)
      pluginObj = src.UserData.pluginObj;
      
      disp(src.Value)
    end
    
  end
  
end
