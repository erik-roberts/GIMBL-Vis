function gvMainPanelSetup(hObject, eventdata, handles, varargin)

%% TODO
% have a common way to get to obj
% come up with convention for different things

% Check args for gv obj
if nargin > 3 && isa(varargin{1}, 'gv')
  gvObj = varargin{1};
else
  gvObj = gv();
%   error('Need gv obj input')
end

% store hObject handle in gvObj
gvObj.guiData.mainPanel.obj = hObject;
gvObj.guiData.mainPanel.handles = handles; % check this

% store gvObj reference in hObject
handles.gvObj = gvObj;

% handles.gvObj.guiData.guiWindowBool = true;
notify(handles.gvObj, 'mainWindowChange');

%% EDIT FROM HERE

data = varargin{1};
handles.data = data;
mdData = data.MultiDim;
handles.mdData = mdData;

%   dataName = sprintf('%iD Data', mdData.nDims); % in case want dimensions later

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
handles.panelTitle.String = 'GIMBL-Vis Main Panel';

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
gvObj.guiData.mainPanel.HandlesNames.txtH = txtH;
gvObj.guiData.mainPanel.HandlesNames.sH = sH;
gvObj.guiData.mainPanel.HandlesNames.svH = svH;
gvObj.guiData.mainPanel.HandlesNames.vdH = vdH;
gvObj.guiData.mainPanel.HandlesNames.ldH = ldH;

% Handles Types
for iDim = 1:nAxDims
  gvObj.guiData.mainPanel.Handles.txtH(iDim) = handles.(txtH{iDim});
  gvObj.guiData.mainPanel.Handles.sH(iDim) = handles.(sH{iDim});
  gvObj.guiData.mainPanel.Handles.svH(iDim) = handles.(svH{iDim});
  gvObj.guiData.mainPanel.Handles.vdH(iDim) = handles.(vdH{iDim});
  gvObj.guiData.mainPanel.Handles.ldH(iDim) = handles.(ldH{iDim});
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
gvObj.guiData.mainPanel.legendBool = true;

% MarkerTypes
handles.markerTypeMenu.String = {'scatter', 'pcolor'};
handles.markerTypeMenu.UserData.lastVal = 1;

hObject.CloseRequestFcn = @gvCloseRequestFcn;

%% Plot Panel Vars
% Set 0 checked view dims
gvObj.guiData.plotPanel.viewDims = zeros(1, nAxDims);
gvObj.guiData.plotPanel.nViewDims = 0;
gvObj.guiData.plotPanel.nViewDimsLast = 0;

% Set 0 checked locked dims
gvObj.guiData.plotPanel.lockedDims = zeros(1, nAxDims);
gvObj.guiData.plotPanel.nLockedDims = 0;
gvObj.guiData.plotPanel.nLockedDimsLast = 0;

gvObj.guiData.plotPanel.disabledDims = zeros(1, nAxDims);

gvObj.guiData.plotPanel.nAxDims = nAxDims;

gvObj.guiData.plotPanel.figHandle = [];
gvObj.guiData.plotPanel.axHandle = [];

% set marker type for plotting
gvObj.guiData.plotPanel.markerType = handles.markerTypeMenu.String{handles.markerTypeMenu.UserData.lastVal};

% Check for index variable
gvObj.guiData.plotPanel.indVarNum = find(strcmp('index', mdData.dataTypes));

% Check for label variable
if isfield(data, 'Label')
  gvObj.guiData.plotPanel.Label = data.Label;
  gvObj.guiData.plotPanel.Label.varNum = data.Label.multiDimNum;
  nClasses = length(data.Label.names);
  
  % Make unique colors
  if ~isfield(data.Label, 'colors')
    gvObj.guiData.plotPanel.Label.colors = num2cell(distinguishable_colors(nClasses),2);
  end
  
  % Assign all markers to be '.'
  if ~isfield(data.Label, 'markers')
    gvObj.guiData.plotPanel.Label.markers = cell(nClasses,1);
    [gvObj.guiData.plotPanel.Label.markers{:}] = deal('.');
  end
end

% Assign starting axis index corresponding to slider position
gvObj.guiData.plotPanel.axInd = ones(1, nAxDims);

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