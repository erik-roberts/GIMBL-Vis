function uiControlsHandles = makeDataPanelControls(pluginObj, parentHandle)
%% makeHypercubePanelControls
%
% Input: parentHandle - handle for uicontrol parent
% Outputs:
%   dataPanelheight - height in px of all rows

nDims = ndims(pluginObj.controller.activeHypercube);
axisNames = pluginObj.controller.activeHypercube.axisNames;

% Notes
% - set the container to be based on amount of dims

spacing = 10; % px
padding = 5; % px

fontSize = pluginObj.fontSize;
fontWidth = pluginObj.fontWidth;
fontHeight = pluginObj.fontHeight;
pxHeight = fontHeight + spacing; % px

uiControlsHandles = struct();

thisTag = pluginObj.panelTag('dataPanel');
dataPanel = uix.Panel(...
  'Tag',thisTag,...
  'Parent', parentHandle,...
  'Title', 'Active Hypercube Data',...
  'FontUnits','points',...
  'FontSize',fontSize ...
  );

dataVbox = uix.VBox('Parent',dataPanel); % make box to hold 1)titles and 2)data

% 1) Name
makeActiveHypercubeEdit(dataVbox)

% 2) Titles
pluginObj.makeDataPanelTitles(dataVbox);

% 3) Data
thisTag = pluginObj.panelTag('dataScrollingPanel');
dataScrollingPanel = uix.ScrollingPanel(...
  'Tag',thisTag,...
  'Parent', dataVbox...
  );
uiControlsHandles.dataScrollingPanel = dataScrollingPanel;

makeDataPanelGrid(dataScrollingPanel);

%% Set layout sizes
set(dataVbox, 'Heights',[fontHeight*2, fontHeight*2,-1]);
dataPanelheight = (pxHeight+spacing)*nDims + padding*2;
set(dataScrollingPanel, 'Heights',dataPanelheight);

% Store Handles
% pluginObj.handles.controls = catstruct(pluginObj.handles.dataPanel.controls, uiControlsHandles); % add to handles from makeDataPanelTitles

%% Nested fn
  function makeActiveHypercubeEdit(parentHandle)
    hypercubeHbox = uix.HBox('Parent',parentHandle, 'Spacing',spacing, 'Padding',padding);
    
    % activeHypercubeLabel
    thisTag = pluginObj.panelTag('activeHypercubeLabel');
    uiControlsHandles.activeHypercubeText = uicontrol(...
      'Tag',thisTag,...
      'Style','text',...
      'FontUnits','points',...
      'FontSize',fontSize,...
      'String','Name:',...
      'Parent',hypercubeHbox);
    
    % activeHypercubeText
    thisTag = pluginObj.panelTag('activeHypercubeText');
    uiControlsHandles.activeHypercubeNameEdit = uicontrol(...
      'Tag',thisTag,...
      'Style','text',...
      'FontUnits','points',...
      'FontSize',fontSize,...
      'String',pluginObj.controller.activeHypercubeName,...
      'Callback',pluginObj.callbackHandle(thisTag),...
      'UserData',pluginObj.userData,...
      'Parent',hypercubeHbox);
    
    set(hypercubeHbox, 'Widths', [-1,-1])
  end

  function makeDataPanelGrid(parentHandle)
    % Make grid of nDims x 4
    thisTag = pluginObj.panelTag('dataPanelGrid');
    dataPanelGrid = uix.Grid('Tag',thisTag,...
      'Parent',parentHandle, 'Spacing',spacing, 'Padding',padding);
    uiControlsHandles.dataPanelGrid = dataPanelGrid;
    
    % grid (:,1)
    makeVarCol(dataPanelGrid)
    
    % grid (:,2)
    makeValCol(dataPanelGrid)
    
    % grid (:,3)
    makeViewCol(dataPanelGrid)
    
    % grid (:,4)
    makeLockCol(dataPanelGrid)
    
    % Set grid sizes
    set(dataPanelGrid, 'Heights',pxHeight*ones(1, nDims), 'Widths',[-3,-5,fontWidth*6,fontWidth*6])
  end


  function makeVarCol(parentHandle)
    % Row 1
    %   titles from 'makeDataPanelTitles.m'
    
    % Row 2:nDims+1
    for n = 1:nDims
      % varText1
      nStr = num2str(n);
      thisTag = pluginObj.panelTag(['varText' nStr]);
      uiControlsHandles.(['varText' nStr]) = uicontrol(...
        'Tag',thisTag,...
        'Style','text',...
        'FontUnits','points',...
        'FontSize',fontSize,...
        'String', axisNames{n},...
        'UserData',pluginObj.userData,...
        'Callback',pluginObj.callbackHandle(pluginObj.panelTag('varText')),...
        'Parent',parentHandle);
    end
  end


  function makeValCol(parentHandle)
    % Row 2:nDims+1
    for n = 1:nDims
      nStr = num2str(n);
      
      % sliderHbox
      sliderHbox = uix.HBox('Parent',parentHandle, 'Spacing',spacing);

      % slider
      thisTag = pluginObj.panelTag(['slider' nStr]);
      uiControlsHandles.(['slider' nStr]) = uicontrol(...
        'Tag',thisTag,...
        'Style','slider',...
        'Min',get(0,'defaultuicontrolMin'),...
        'Max',get(0,'defaultuicontrolMax'),...
        'SliderStep',get(0,'defaultuicontrolSliderStep'),...
        'Value',get(0,'defaultuicontrolValue'),...
        'UserData',pluginObj.userData,...
        'Callback',pluginObj.callbackHandle(pluginObj.panelTag('slider')),...  use same callback for each
        'Parent',sliderHbox);

      % sliderVal
      thisTag = pluginObj.panelTag(['sliderVal' nStr]);
      uiControlsHandles.(['sliderVal' nStr]) = uicontrol(...
        'Tag',thisTag,...
        'Style','edit',...
        'FontUnits','points',...
        'FontSize',fontSize,...
        'String',['val' nStr],...
        'UserData',pluginObj.userData,...
        'Callback',pluginObj.callbackHandle(pluginObj.panelTag('sliderVal')),...  use same callback for each
        'Parent',sliderHbox);
      
        set(sliderHbox, 'Widths',[-2, -1]);
    end
    
  end


  function makeViewCol(parentHandle)
    pluginObj.handles.dataPanel.viewCheckboxHandles = cell(1, nDims);
    
    % Row 2:nDims+1
    for n = 1:nDims
      nStr = num2str(n);
      
      % viewCheckbox
      thisTag = pluginObj.panelTag(['viewCheckbox' nStr]);
      uiControlsHandles.(['viewCheckbox' nStr]) = uicontrol(...
        'Tag',thisTag,...
        'Style','checkbox',...
        'Value',0,...
        'UserData',pluginObj.userData,...
        'Callback',pluginObj.callbackHandle(pluginObj.panelTag('viewCheckbox')),... % use same callback for each
        'Parent',parentHandle);
      
      pluginObj.handles.dataPanel.viewCheckboxHandles{n} = uiControlsHandles.(['viewCheckbox' nStr]);
    end
  end


  function makeLockCol(parentHandle)
    pluginObj.handles.dataPanel.lockCheckboxHandles = cell(1, nDims);
    
    % Row 2:nDims+1
    for n = 1:nDims
      nStr = num2str(n);
      
      % viewCheckbox
      thisTag = pluginObj.panelTag(['lockCheckbox' nStr]);
      uiControlsHandles.(['lockCheckbox' nStr]) = uicontrol(...
        'Tag',thisTag,...
        'Style','checkbox',...
        'Value',0,...
        'UserData',pluginObj.userData,...
        'Callback',pluginObj.callbackHandle(pluginObj.panelTag('lockCheckbox')),...% use same callback for each
        'Parent',parentHandle);
      
      pluginObj.handles.dataPanel.lockCheckboxHandles{n} = uiControlsHandles.(['lockCheckbox' nStr]);
    end
  end

end
