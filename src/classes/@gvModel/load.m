function load(modelObj, src, fld, staticBool)
% load - load gv, gvArray, or multidimensional object data
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
      modelObj.importDsData(src); % ignore src
      return
    end
  else
    if ~staticBool
      error('No mat files found in dir for loading.')
    else % called gv.Run() in directory without mat files
      modelObj.vprintf('No mat files found in dir for loading. Opening GIMBL-Vis with empty model.\n');
      return
    end
  end
elseif ~exist(src, 'file')
  error('Load source not found. Use ''obj.importTabularDataFromFile'' instead for non-mat files.')
end

% import data
data = importdata(src);

modelObj.importDataFromWorkspace(data, fld, staticBool)

end
