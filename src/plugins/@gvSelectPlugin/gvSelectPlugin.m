%% gvSelect - Select GUI Class for GIMBL-Vis
%
% Description: An object of this class becomes a property of gvView to provide 
%              methods for a GIMBL-Vis plot window

classdef gvSelectPlugin < gvGuiPlugin

  %% Public properties %%
  properties (Constant)
    pluginName = 'Select';
    pluginFieldName = 'select';
  end
  
  properties
    metadata = struct()
    
    handles = struct()
  end

  
  %% Public methods %%
  methods
    
    function pluginObj = gvSelectPlugin(varargin)
      pluginObj@gvGuiPlugin(varargin{:});
    end
    
    
    function setup(pluginObj, cntrlObj)
      setup@gvGuiPlugin(pluginObj, cntrlObj);
      
      % Event listeners
      cntrlObj.newListener('activeHypercubeChanged', @gvSelectPlugin.Callback_activeHypercubeChanged);
      addlistener(pluginObj, 'panelControlsMade', @gvSelectPlugin.Callback_panelControlsMade);
    end

    
    panelHandle = makePanelControls(pluginObj, parentHandle)
    
  end
  
  
  %% Protected methods %%
  methods (Access = protected)
    
    dataPanelheight = makeDataPanelControls(pluginObj, parentHandle)
    
    
    makeDataPanelTitles(pluginObj, parentHandle)
    
    
    function initializeControlsDynamicVars(pluginObj)
      pluginObj.view.dynamic.nViewDimsLast = 0;
      pluginObj.updateViewDims();
      pluginObj.updateLockDims();
      pluginObj.updateDisabledDims();
    end
    
    
    function initializeSliderVals(pluginObj)
      pluginObj.view.dynamic.sliderVals = ones(pluginObj.controller.activeHypercube.ndims, 1);
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
    
    
    function updateSliderInd(pluginObj, src)
      % updateSliderInd - update a given slider's value in view dynamic property
      %
      % Input: src can be index of slider or the slider object
      
      if isobject(src)
        sliderObj = src;
        sliderInd = getNumSuffix(sliderObj.Tag);
      elseif isscalar(src)
        sliderInd = src;
        sliderObj = findobjReTag(['select_panel_slider' num2str(sliderInd)]);
      end
      
      pluginObj.view.dynamic.sliderVals(sliderInd) = sliderObj.Value;
    end
    
    
    function valStr = getSliderValStr(pluginObj, src)
      % getSliderValStr - get data value for slider position as string
      %
      % Input: src can be index of slider or the slider object
      
      if isobject(src)
        sliderObj = src;
        sliderInd = getNumSuffix(sliderObj.Tag);
      elseif isscalar(src)
        sliderInd = src;
      end
      
      sliderValInd = pluginObj.view.dynamic.sliderVals(sliderInd);
      
      valStr = pluginObj.controller.activeHypercube.axis(sliderInd).valueAsStr(sliderValInd);
    end
    
    
    function updateEditFromSlider(pluginObj, sliderObj)
      editObj = findobjReTag(sliderObj.UserData.siblingTag);
      
      editObj.String = pluginObj.getSliderValStr(sliderObj);
    end
    
    
    function updateSliderFromEdit(pluginObj, editObj, sliderVal)
      sliderObj = findobjReTag(editObj.UserData.siblingTag);

      sliderObj.Value = sliderVal;
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
      pluginObj = src; % window plugin
      
      pluginObj.initializeControlsDynamicVars();
    end
    
    
    function Callback_activeHypercubeChanged(src, evnt)
      pluginObj = src.guiPlugins.(gvSelectPlugin.pluginFieldName); % window plugin
      
      pluginObj.initializeSliderVals();
      
      % TODO remake controls
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
      
      axind = getNumSuffix(src.Tag);
      
      assert(~isnan(axind), 'Variable axis index not found');
      
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
      sliderObj = src;
      
      pluginObj = sliderObj.UserData.pluginObj;
      
      % round value
      sliderObj.Value = round(sliderObj.Value);
      
      % update slider ind in view.dynamic
      pluginObj.updateSliderInd(sliderObj);
      
      % update sibling edit box str
      pluginObj.updateEditFromSlider(sliderObj);
    end
    
    
    function Callback_select_panel_sliderVal(src, evnt)
      editObj = src;
      pluginObj = editObj.UserData.pluginObj;
      
      controlInd = getNumSuffix(editObj.Tag);
      axVals = pluginObj.controller.activeHypercube.axis(controlInd).values;
      
      if isnumeric(axVals)
        editVal = str2double(editObj.String);
        [~, sliderVal] = min(abs(axVals - editVal));
        finalString = num2str(sliderVal);
      else
        try
           sliderVal = gvArrayAxis.regex_lookup(axVals, editObj.String);
        catch
          wprintf('Coudln''t find regexp match to entered string.\n')
          return
        end
        finalString = axVals{sliderVal};
      end
      
      % update edit box with chosen value from axis
      editObj.String = finalString;
      
      % update sibling slider value
      pluginObj.updateSliderFromEdit(editObj, sliderVal);
    end
    
  end
  
end
