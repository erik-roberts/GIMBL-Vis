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

dataPanel = uix.Panel(...
  'Tag','dataPanelBox',...
  'Parent', parentHandle,...
  'Title', 'Active Hypercube Data',...
  'FontUnits','points',...
  'FontSize',fontSize ...
  );

dataVbox = uix.VBox('Parent',dataPanel); % make box to hold 1)titles and 2)data

% 1) Titles
pluginObj.makeDataPanelTitles(dataVbox); % row 1

% 2) Data
dataScrollingPanel = uix.ScrollingPanel(...
  'Tag','dataScrollingPanel',...
  'Parent', dataVbox...
  );

makeDataPanelGrid(dataScrollingPanel);

%% Set layout sizes
set(dataVbox, 'Heights',[fontHeight*2,-1]);
dataPanelheight = (pxHeight+spacing)*nDims + padding*2;
set(dataScrollingPanel, 'Heights',dataPanelheight);

% Store Handles
% pluginObj.handles.controls = catstruct(pluginObj.handles.dataPanel.controls, uiControlsHandles); % add to handles from makeDataPanelTitles

%% Nested fn
  function makeDataPanelGrid(parentHandle)
    % Make grid of nDims x 4
    dataPanelGrid = uix.Grid('Tag','dataPanelGrid', 'Parent',parentHandle, 'Spacing',spacing, 'Padding',padding);
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
      uiControlsHandles.(['varText' nStr]) = uicontrol(...
        'Tag',['varText' nStr],...
        'Style','edit',...
        'FontUnits','points',...
        'FontSize',fontSize,...
        'String', axisNames{n},...
        'Callback',@(hObject,eventdata)gvMainWindow_export('slider1_Callback',hObject,eventdata,guidata(hObject)),...
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
      uiControlsHandles.(['slider' nStr]) = uicontrol(...
        'Tag',['slider' nStr],...
        'Style','slider',...
        'Min',get(0,'defaultuicontrolMin'),...
        'Max',get(0,'defaultuicontrolMax'),...
        'SliderStep',get(0,'defaultuicontrolSliderStep'),...
        'Value',get(0,'defaultuicontrolValue'),...
        'Callback',@(hObject,eventdata)gvMainWindow_export('slider1_Callback',hObject,eventdata,guidata(hObject)),...
        'Parent',sliderHbox);


      % sliderVal
      uiControlsHandles.(['sliderVal' nStr]) = uicontrol(...
        'Tag',['sliderVal' nStr],...
        'Style','edit',...
        'FontUnits','points',...
        'FontSize',fontSize,...
        'String',['val' nStr],...
        'Callback',@(hObject,eventdata)gvMainWindow_export('sliderVal1_Callback',hObject,eventdata,guidata(hObject)),...
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
      uiControlsHandles.(['viewCheckbox' nStr]) = uicontrol(...
        'Tag',['viewCheckbox' nStr],...
        'Style','checkbox',...
        'Value',0,...
        'Callback',@(hObject,eventdata)gvMainWindow_export('viewDim1_Callback',hObject,eventdata,guidata(hObject)),...
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
      uiControlsHandles.(['lockCheckbox' nStr]) = uicontrol(...
        'Tag',['lockCheckbox' nStr],...
        'Style','checkbox',...
        'Value',0,...
        'Callback',@(hObject,eventdata)gvMainWindow_export('viewDim1_Callback',hObject,eventdata,guidata(hObject)),...
        'Parent',parentHandle);
      
      pluginObj.handles.dataPanel.lockCheckboxHandles{n} = uiControlsHandles.(['lockCheckbox' nStr]);
    end
  end

end
