%% gvSelectPlugin - Select GUI Plugin Class for GIMBL-Vis
%
% Description: An object of this class becomes a property of gvView to provide 
%              methods for a GIMBL-Vis main window tab for hypercube slice selection.

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
  
  %% Events %%
  events
    dynamicSliderValsChanged
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
      addlistener(pluginObj, 'dynamicSliderValsChanged', @gvSelectPlugin.Callback_dynamicSliderValsChanged);
    end

    
    panelHandle = makePanelControls(pluginObj, parentHandle)
    
    
    function sliderPos = getSliderAbsolutePosition(pluginObj)
      nSliders = length(pluginObj.view.dynamic.sliderVals);
      sliderPos = nan(nSliders, 4);
      for sliderInd = 1:nSliders
        thisPosCell = cellfunu(@getPos, pluginObj.view.dynamic.selectSliderAncestry{sliderInd});
        thisPos = vertcat(thisPosCell{:});
        thisPos = sum(thisPos);
        
        sliderPos(sliderInd,:) = [thisPos, pluginObj.view.dynamic.selectSliderAncestry{sliderInd}{1}.Position(3:4)];
      end
      
      function out = getPos(x)
        thisUnits = x.Units;
        if ~strcmp(thisUnits, 'pixels')
          x.Units = 'pixels';
          out = x.Position;
          x.Units = thisUnits; 
        else
          out = x.Position;
        end
        
        out = out(1:2);
      end
    end
    
    iterate(pluginObj)
    
  end
  
  
  %% Protected methods %%
  methods (Access = protected)
    
    dataPanelheight = makeDataPanelControls(pluginObj, parentHandle)
    
    
    makeDataPanelTitles(pluginObj, parentHandle)
    
    
    function initializeControlsDynamicVars(pluginObj)
      pluginObj.view.dynamic.nViewDims = 0;
      pluginObj.view.dynamic.nViewDimsLast = 0;
      pluginObj.updateViewDims();
      pluginObj.updateLockDims();
%       pluginObj.updateDisabledDims();
    end
    
    
    function initializeSliderVals(pluginObj)
      pluginObj.view.dynamic.sliderVals = ones(1, pluginObj.controller.activeHypercube.ndims);
    end
    
    
    function updateViewDims(pluginObj)
      viewCheckboxes = sortByTag(findobj(pluginObj.view.windowPlugins.main.handles.fig, '-regexp', 'Tag','viewCheckbox'), true);
      pluginObj.view.dynamic.viewDims = [viewCheckboxes.Value];
      pluginObj.view.dynamic.nViewDims = sum([viewCheckboxes.Value]);
      
      if (pluginObj.view.dynamic.nViewDims ~= pluginObj.view.dynamic.nViewDimsLast) && pluginObj.view.dynamic.nViewDims > 0
        notify(pluginObj.controller, 'nViewDimsChanged')
      end
      
      pluginObj.view.dynamic.nViewDimsLast = sum([viewCheckboxes.Value]);
    end
    
    
    function updateLockDims(pluginObj)
      % Don't need to update plot since value is already set, locking just
      % prevents any change
      
      lockCheckboxes = sortByTag(findobj(pluginObj.view.windowPlugins.main.handles.fig, '-regexp', 'Tag','lockCheckbox'), true);
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
%       if any(nViewDims == [1,2])
%         disabledDims = logical(lockDims + viewDims);
%       else
        disabledDims = logical(lockDims);
%       end
      
      % update disabledDims
      pluginObj.view.dynamic.disabledDims = disabledDims;
      
      % set disables
      statusCellStr = cell(size(disabledDims));
      statusCellStr(disabledDims) = {'off'};
      statusCellStr(~disabledDims) = {'on'};
      
      sliders = pluginObj.sliderHandles;
      sliderVals = sortByTag(findobj(pluginObj.view.windowPlugins.main.handles.fig, '-regexp', 'Tag','sliderVal\d+'), true);
      
      [sliders.Enable] = deal(statusCellStr{:});
      [sliderVals.Enable] = deal(statusCellStr{:});
    end
    
    
    function makeSliderAncestryMetadata(pluginObj)
      sliderHandles = sortByTag(findobjReTag('select_panel_slider\d+'), true);
      
      pluginObj.view.dynamic.selectSliderAncestry = {};
      
      for sliderInd = 1:length(sliderHandles)
        h = sliderHandles(sliderInd);
        
        pluginObj.view.dynamic.selectSliderAncestry{sliderInd} = {};
        
        notFigParent = true;
        while notFigParent
          if isequal(h, pluginObj.view.main.handles.fig)
            notFigParent = false;
            continue
          end
          
          pluginObj.view.dynamic.selectSliderAncestry{sliderInd}{end+1} = h;
          
          h = h.Parent;
        end
      end
    end
    
    function sliders = sliderHandles(pluginObj)
      sliders = sortByTag(findobj(pluginObj.view.windowPlugins.main.handles.fig, '-regexp', 'Tag','slider\d+'), true);
    end

  end
  
  %% Static %%
  methods (Static, Hidden)

    function str = helpStr()
      str = [gvSelectPlugin.pluginName ':\n',...
        'Use the sliders or the adjoining box to choose a slice of the data.\n'
        ];
    end
    
    
    %% Callbacks %%
    function Callback_panelControlsMade(src, evnt)
      pluginObj = src; % window plugin
      
      pluginObj.initializeControlsDynamicVars();
      
      pluginObj.makeSliderAncestryMetadata();
    end
    
    
    function Callback_dynamicSliderValsChanged(src, evnt)
      pluginObj = src;
      
      sliderHandles = pluginObj.sliderHandles;
      
      nSliders = length(sliderHandles);
      for sliderInd = 1:nSliders
        thisSlider = sliderHandles(sliderInd);
        
        % get current value in view.dynamic
        curVal = pluginObj.view.dynamic.sliderVals(sliderInd);
        
        % update slider pos
        thisSlider.Value = curVal;
        
        % update label
        pluginObj.updateEditFromSlider(thisSlider);
      end
      
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
      
      notify(pluginObj.controller, 'activeHypercubeAxisLabelChanged');
    end
    
    
    function Callback_select_panel_viewCheckbox(src, ~)
      pluginObj = src.UserData.pluginObj;
      
      pluginObj.updateViewDims();
%       pluginObj.updateDisabledDims()
    end
    
    
    function Callback_select_panel_lockCheckbox(src, ~)
      pluginObj = src.UserData.pluginObj;
      
      pluginObj.updateLockDims();
%       pluginObj.updateDisabledDims()
    end
    
    
    function Callback_select_panel_slider(src, ~)
      sliderObj = src;
      pluginObj = sliderObj.UserData.pluginObj;
      
      % round value
      sliderObj.Value = round(sliderObj.Value);
      
      % update slider ind in view.dynamic
      pluginObj.updateSliderInd(sliderObj);
      
      % update sibling edit box str
      pluginObj.updateEditFromSlider(sliderObj);
      
      notify(pluginObj.controller, 'activeHypercubeSliceChanged')
    end
    
    
    function Callback_select_panel_sliderVal(src, ~)
      editObj = src;
      pluginObj = editObj.UserData.pluginObj;
      
      controlInd = getNumSuffix(editObj.Tag);
      axVals = pluginObj.controller.activeHypercube.axis(controlInd).values;
      
      % check for # notation
      reToken = regexp(editObj.String, '^#(\d+)$', 'tokens');
      if ~isempty(reToken)
        reToken = reToken{:};
        reToken = reToken{:};
        sliderVal = str2double(reToken);
        if isnumeric(axVals)
          finalString = num2str(axVals(sliderVal));
        else
          finalString = axVals{sliderVal};
        end
        
      else % entered value, not # notation
        if isnumeric(axVals)
          editVal = str2double(editObj.String);
          [~, sliderVal] = min(abs(axVals - editVal));
          finalString = num2str(axVals(sliderVal));
        else
          try
            sliderVal = gvArrayAxis.regex_lookup(axVals, editObj.String);
          catch
            wprintf('Coudln''t find regexp match to entered string.\n         Defaulting to first value.\n')
            editObj.String = axVals{1};
            return
          end
          finalString = axVals{sliderVal};
        end
      end
      
      % update edit box with chosen value from axis
      editObj.String = finalString;
      
      % update sibling slider value
      pluginObj.updateSliderFromEdit(editObj, sliderVal);
      
      notify(pluginObj.controller, 'activeHypercubeSliceChanged')
    end
    
    
    function Callback_select_panel_iterateToggle(src, evnt)
      pluginObj = src.UserData.pluginObj; % window plugin
      
      if src.Value
        src.String = sprintf('Iterate ( %s )', char(8545)); %pause char (bars)
%         src.String = sprintf('Iterate ( %s )', char(hex2dec('23F8'))); %pause char (bars)

        pluginObj.iterate();
      else
        src.String = sprintf('Iterate ( %s )', char(9654)); %start char (arrow)
      end
    end

    
    function Callback_select_panel_delayValueBox(src, evnt)
      src.Value = str2double(src.String);
    end
    
    
    Callback_WindowScrollWheelFcn(src, evnt);
    
  end
  
end
