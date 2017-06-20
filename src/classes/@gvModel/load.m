function load(modelObj, src, fld, staticBool)
% load - load gv or gvArray object data
%
% Usage: obj.load()
%        obj.load(src)
%        obj.load(src, hypercubeName)
%
% Inputs:
%   src: is a dir or a file to load.
%   hypercubeName: is a hypercubeName to store loaded data in. If empty
%                  will use default indexing.
%
% See also: gv.Load (static method)

% Setup args
if nargin < 2 || isempty(src)
  src = pwd;
end
if nargin < 3
  fld = [];
end
if nargin < 4
  staticBool = false;
end

% parse src
if exist(src, 'dir')
  matFile = lscell(fullfile(src, '*.mat'));
  if ~isempty(matFile)
    if any(strcmp(matFile, 'gvData.mat'))
      src = fullfile(src, 'gvData.mat');
    else
      if length(matFile) > 1
        error('Found multiple mat files in dir. Please specify path to which mat file to load.')
      end
      src = fullfile(src, matFile{1});
    end
    
    % in case specify dynasim data dir
    if strcmp(matFile{1}, 'studyinfo.mat')
      modelObj = gv.ImportDsData(src); % ignore src
      return
    end
  else
    error('No mat files found in dir for loading.')
  end
elseif ~exist(src, 'file')
  error('Load source not found. Use ''obj.importTabularDataFromFile'' instead for non-mat files.')
end

% import data
data = importdata(src);
if isa(data, 'gv')
  if ~staticBool
    for modelFld = fieldnames(data.model)'
      modelFld = modelFld{1};
      modelFldNew = modelObj.checkHypercubeName(modelFld); % check fld name
      modelObj.data.(modelFldNew) = data.model.(modelFld); % add fld to checked fld name
      modelObj.data.(modelFldNew).hypercubeName = modelFldNew;
    end
    
    notify(modelObj.controller, 'modelChanged');
  else
    modelObj.app.replaceApp(data);
  end
  fprintf('Loaded gv object data.\n')
elseif isa(data, 'MDD') || isa(data, 'MDDRef') % || isa(data, 'gvArray')
  % Determine fld/hypercubeName
  if isempty(fld)
    fld = modelObj.checkHypercubeName(gvArray(data));
  else
    fld = modelObj.checkHypercubeName(fld);
  end
  
  modelObj.data.(fld) = gvArrayRef(gvArray(data));
  
  notify(modelObj.controller, 'modelChanged');
  
  fprintf('Loaded multidimensional array object data.\n')
else
  error('Attempting to load non-gv data. Use ''obj.importTabularDataFromFile'' instead.')
end

end
