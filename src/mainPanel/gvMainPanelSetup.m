function gvMainPanelSetup(hObject, eventdata, handles, varargin)

% Add data input
if nargin > 3 && isstruct(varargin{1})
  data = varargin{1};
  handles.data = data;
  mdData = data.MultiDim;
  handles.mdData = mdData;
else
  error('Needs data struct input')
end

if nargin > 4
  dataName = varargin{2};
else
  dataName = sprintf('%iD Data', mdData.nDims);
end

% Choose default command line output for gvMainPanel
handles.output = hObject;

% Setup var names
handles.mdData.dimNames = strrep(handles.mdData.dimNames, '_','-'); %replace _ with -
dimNames = mdData.dimNames;
% nonAxDims = data.Table.Properties.UserData.nonAxisDims;
% nonAxDimNames = dimNames(nonAxDims);
% data.Table.Properties.UserData.nonAxDimNames = nonAxDimNames;

axDimNames = dimNames;
% axDimNames(nonAxDims) = [];
% data.Table.Properties.UserData.axDimNames = axDimNames;
nAxDims = length(axDimNames);

%% Setup Main Panel Vars

% Set title
dataName = strrep(dataName, '_','-'); %replace _ with -
handles.panelTitle.String = dataName;

% Change iterateToggle String
handles.iterateToggle.String = sprintf('( %s ) Iterate', char(9654)); %start char (arrow)

% Get fields
flds = fields(handles);
txtH = sort(flds(~cellfun(@isempty,(strfind(flds, 'varText')))));
sH = sort(flds(~cellfun(@isempty,(regexp(flds, 'slider\d'))))); % use regexp to avoid capuring svh also
svH = sort(flds(~cellfun(@isempty,(strfind(flds, 'sliderVal')))));
vdH = sort(flds(~cellfun(@isempty,(strfind(flds, 'viewDim')))));
ldH = sort(flds(~cellfun(@isempty,(strfind(flds, 'lockDim')))));

% Handles Names
handles.MainPanel.HandlesNames.txtH = txtH;
handles.MainPanel.HandlesNames.sH = sH;
handles.MainPanel.HandlesNames.svH = svH;
handles.MainPanel.HandlesNames.vdH = vdH;
handles.MainPanel.HandlesNames.ldH = ldH;

% Handles Types
for iDim = 1:nAxDims
  handles.MainPanel.Handles.txtH(iDim) = handles.(txtH{iDim});
  handles.MainPanel.Handles.sH(iDim) = handles.(sH{iDim});
  handles.MainPanel.Handles.svH(iDim) = handles.(svH{iDim});
  handles.MainPanel.Handles.vdH(iDim) = handles.(vdH{iDim});
  handles.MainPanel.Handles.ldH(iDim) = handles.(ldH{iDim});
end

for iDim = 1:nAxDims
  handles.(txtH{iDim}).String = axDimNames{iDim};
  
  % Shrink font if too large
  while handles.(txtH{iDim}).Extent(3) > handles.(txtH{iDim}).Position(3)
    handles.(txtH{iDim}).FontSize = handles.(txtH{iDim}).FontSize*.99;
  end
end

% Setup slider limits and values
for iDim = 1:nAxDims
  thisMin = min(mdData.dimVals{iDim});
  thisMax = max(mdData.dimVals{iDim});
  thisRange = range(mdData.dimVals{iDim});
  smallestStep = min(abs(diff(mdData.dimVals{iDim}))) / thisRange;
  
  handles.(svH{iDim}).String = num2str(thisMin);
  handles.(svH{iDim}).Value = thisMin;
  handles.(svH{iDim}).SliderStep = [smallestStep 5*smallestStep];
  handles.(svH{iDim}).UserData.lastVal = handles.(svH{iDim}).Value;
  handles.(svH{iDim}).UserData.varName = axDimNames{iDim}; % assign var name to ui obj
  handles.(svH{iDim}).UserData.varInd = iDim; % assign var ind to ui obj
  handles.(svH{iDim}).UserData.siblingName = sH{iDim}; % connected slider name
  handles.(svH{iDim}).UserData.sibling = handles.(sH{iDim}); % connected slider handle
  
  handles.(sH{iDim}).Min = thisMin;
  handles.(sH{iDim}).Max = thisMax;
  handles.(sH{iDim}).Value = thisMin;
  handles.(sH{iDim}).UserData.lastVal = handles.(sH{iDim}).Value;
  handles.(sH{iDim}).SliderStep = [smallestStep 5*smallestStep];
  handles.(sH{iDim}).UserData.varName = axDimNames{iDim}; % assign var name to ui obj
  handles.(sH{iDim}).UserData.varInd = iDim; % assign var ind to ui obj
  handles.(sH{iDim}).UserData.siblingName = svH{iDim}; % connected slider box name
  handles.(sH{iDim}).UserData.sibling = handles.(svH{iDim}); % connected slider box handle
end

% Hide unused guis
for iH = length(axDimNames)+1:length(txtH)
  handles.(txtH{iH}).Visible = 'off';
  handles.(sH{iH}).Visible = 'off';
  handles.(svH{iH}).Visible = 'off';
  handles.(vdH{iH}).Visible = 'off';
  handles.(ldH{iH}).Visible = 'off';
end

% Scrollwheel callback
hObject.WindowScrollWheelFcn = @gvScrollCallback;

% Makes Plot Legend Boolean
handles.MainPanel.legendBool = true;

% MarkerTypes
handles.markerTypeMenu.String = {'scatter', 'pcolor'};
handles.markerTypeMenu.UserData.lastVal = 1;

%% Plot Panel Vars
% Set 0 checked view dims
handles.PlotPanel.viewDims = zeros(1, nAxDims);
handles.PlotPanel.nViewDims = 0;
handles.PlotPanel.nViewDimsLast = 0;

% Set 0 checked locked dims
handles.PlotPanel.lockedDims = zeros(1, nAxDims);
handles.PlotPanel.nLockedDims = 0;
handles.PlotPanel.nLockedDimsLast = 0;

handles.PlotPanel.disabledDims = zeros(1, nAxDims);

handles.PlotPanel.nAxDims = nAxDims;

handles.PlotPanel.figHandle = [];
handles.PlotPanel.axHandle = [];

% set marker type for plotting
handles.PlotPanel.markerType = handles.markerTypeMenu.String{handles.markerTypeMenu.UserData.lastVal};

% Check for index variable
handles.PlotPanel.indVarNum = find(strcmp('index', mdData.dataTypes));

% Check for label variable
if isfield(data, 'Label')
  handles.PlotPanel.Label = data.Label;
  handles.PlotPanel.Label.varNum = data.Label.multiDimNum;
  nClasses = length(data.Label.names);
  
  % Make unique colors
  if ~isfield(data.Label, 'colors')
    handles.PlotPanel.Label.colors = num2cell(distinguishable_colors(nClasses),2);
  end
  
  % Assign all markers to be '.'
  if ~isfield(data.Label, 'markers')
    handles.PlotPanel.Label.markers = cell(nClasses,1);
    [handles.PlotPanel.Label.markers{:}] = deal('.');
  end
end

% Assign starting axis index corresponding to slider position
handles.PlotPanel.axInd = ones(1, nAxDims);

%% Image Panel Vars
handles.ImagePanel.handle = [];
data_dir = data.workingDir;
handles.ImagePanel.plotDir = fullfile(data_dir, 'plots');
handles.imageTypeMenu.UserData.lastVal = [];

%% Legend Panel Vars
handles.LegendPanel.handle = [];


%% Update handles structure
guidata(hObject, handles);

end