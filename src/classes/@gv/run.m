function obj = run(obj, varargin)
% run - run gv

options = checkOptions(varargin,{...
  'loadPath',[],[],...
  'classifyFn', [], [],...
  'overwriteBool', 0, {0,1},...
  'verboseBool', 1, {0,1},...
},false);

% if specify load path
if ~isempty(options.loadPath)
  obj = obj.load(options.loadPath, varargin{:});
  obj.guiData.workingDir = options.loadPath;
else
  obj.guiData.workingDir = pwd;
end

%% TODO: from here on

% Get last directory name
[dataPath] = fileparts([data_dir filesep]);
if ~ispc
  dataPath = strsplit(dataPath, filesep);
else
  dataPath = strsplit(dataPath, '\\');
end
dataPath = dataPath(~cellfun(@isempty, dataPath));
dataName = dataPath{end};

gvMainPanel(data, dataName);

end