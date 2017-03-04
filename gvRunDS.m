function gvRunDS(data_dir, options)
if ~exist('data_dir', 'var') || isempty(data_dir)
  data_dir = pwd;
end

if ~exist('options', 'var') || isempty(options)
  options = struct();
end

options.overwriteBool = 0;
data = gvLoadDSdata(data_dir, options);

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