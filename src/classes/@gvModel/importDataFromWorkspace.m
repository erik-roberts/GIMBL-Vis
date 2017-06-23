function importDataFromWorkspace(modelObj, data, fld, staticBool)
% importDataFromWorkspace
%
% Usage: obj.importDataFromWorkspace(variable)
%        obj.importDataFromWorkspace(variable, hypercubeName)
%
% Inputs:
%   variable: variable from workspace, either variable itself or variable
%             name as string. variable can an object of class/subclass gv,
%             MDD, or gvArray.
%   hypercubeName: is a hypercubeName to store loaded data in. If empty
%                  will use default indexing.

% Setup args
if nargin < 3
  fld = [];
end
if nargin < 4
  staticBool = false;
end

% if data given as data name string
if ischar(data)
  data = evalin('base', data);
end

% check data type
if isa(data, 'gv')
  if ~staticBool
    for modelFld = fieldnames(data.model.data)'
      modelFld = modelFld{1};
      modelFldNew = modelObj.checkHypercubeName(modelFld); % check fld name
      modelObj.data.(modelFldNew) = data.model.data.(modelFld); % add fld to checked fld name
      modelObj.data.(modelFldNew).hypercubeName = modelFldNew;
    end
    
    notify(modelObj.controller, 'modelChanged');
  else
    modelObj.app.replaceApp(data);
  end
  modelObj.vprintf('Loaded gv object data.\n')
elseif isa(data, 'MDD') || isa(data, 'MDDRef') || isnumeric(data) || iscell(data)
  % Determine fld/hypercubeName
  if isempty(fld)
    fld = modelObj.checkHypercubeName(gvArray(data));
  else
    fld = modelObj.checkHypercubeName(fld);
  end
  
  modelObj.data.(fld) = gvArrayRef(gvArray(data));
  
  notify(modelObj.controller, 'modelChanged');
  
  modelObj.vprintf('Loaded multidimensional array object data.\n')
else
  error('Attempting to load non-gv/non-multidimensional data. Use ''obj.importTabularDataFromFile'' instead.')
end

end