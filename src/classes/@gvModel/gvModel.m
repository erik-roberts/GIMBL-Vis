%% gvModel - Model class for the GIMBL-Vis Model-View-Controller
%
% Methods (public):
%   toRef - convert all model data to gvArrayRef
%
% Methods (protected):
%   nextModelFieldName - get next default field for model
%   checkHypercubeName - check if hypercubeName exists as field in model
%
% Author: Erik Roberts

classdef gvModel < handle
  
  %% Public Properties %%
  properties
    data = struct() % of gvArrayRef
  end
  
  properties (SetAccess = private)
    app
    view
    controller
  end
  
  %% Dependent Properties %%
  properties (Dependent)
    activeHypercube
    activeHypercubeName
  end
  
  methods
    
    function value = get.activeHypercube(viewObj)
      value = viewObj.controller.activeHypercube;
    end
    
    function value = get.activeHypercubeName(viewObj)
      value = viewObj.controller.activeHypercubeName;
    end
    
  end
  
  %% Public Methods %%
  methods
    
    function modelObj = gvModel(gvObj)
      if exist('gvObj','var') && ~isempty(gvObj)
        modelObj.app = gvObj;
      end
    end
    
    
    function varargout = printHypercubeList(modelObj)
      flds = fieldnames(modelObj.data);
      if isempty(flds)
        flds = {'[ None ]'};
      end
      
      if nargout
        varargout{1} = flds;
      else
        fprintf(['Hypercubes:\n\t' strjoin(flds,'\n\t') '\n'])
      end
    end
    
    
    function summary(modelObj)
      % summary - print gvModel object summary
      %
      % See also: gv/summary, gvView/summary, gvArray/summary
      
      fprintf('Model Summary:\n')
      
      flds = fieldnames(modelObj.data)';
      if ~isempty(flds)
        for modelFld = flds
          fprintf(['Hypercube: ' modelFld{1} '\n'])
          modelObj.data.(modelFld{1}).summary()
          fprintf('\n')
        end
      else
        fprintf('\t[ Empty Model ]\n')
      end
    end
    

    function modelObj = toRef(modelObj, flds)
      %toRef - convert all model data to gvArrayRef
      
      if ~exist('flds','var') || isempty(flds)
        flds = fieldnames(modelObj.data);
      end
      
      for iFld = 1:length(flds)
        fld = flds{iFld};
        if ~isa(modelObj.data.(fld), 'gvArrayRef')
          modelObj.data.(fld) = gvArrayRef(modelObj.data.(fld));
        end
      end
    end
    
    
    %% Loading
    modelObj = load(modelObj, src, fld, staticBool, varargin)
    
    %% Importing
    modelObj = importDataFromWorkspace(modelObj, fld, varargin)
    
    modelObj = importTabularDataFromFile(modelObj, fld, varargin)
    
    importDsData(modelObj, src, varargin);
    
    importDsPower(modelObj, src, varargin);
    
    %% Saving
    function saveHypercube(modelObj, hypercubeName, filePath, overwriteBool)
      % saveActiveHypercube - save gvArray object to file as MDD object (default: 'gvHypercubeData.mat')
      
      if ~exist('filePath', 'var') || isempty(filePath)
        filePath = 'gvHypercubeData.mat';
      end
      if nargin < 3
        overwriteBool = false;
      end
      
      if ~exist(filePath,'file') || overwriteBool
        eval([hypercubeName ' = modelObj.data.(''' hypercubeName ''').gv2mdd;']);
        save(filePath, hypercubeName);
      else
        wprintf('File exists and overwriteBool=false. Choose a new file name or set overwriteBool=true.');
      end
    end
    
    %% Misc
    function setup(modelObj)
      modelObj.view = modelObj.app.view;
      modelObj.controller = modelObj.app.controller;
    end
    
    
    function mergeHypercubes(modelObj, hypercube, hypercube2merge)
      modelObj.data.(hypercube).merge(modelObj.data.(hypercube2merge));
      
      modelObj.deleteHypercube(hypercube2merge);
    end
    
    
    function changeHypercubeName(modelObj, oldHypercubeName, newHypercubeName)
      if isfield(modelObj.data, newHypercubeName)
        error('New hypercube name already exists. Use a different name.');
        return %#ok<UNRCH>
      end
      
      modelObj.data.(newHypercubeName) = modelObj.data.(oldHypercubeName);
      modelObj.data = rmfield(modelObj.data, oldHypercubeName);
    end
    
    
    function addHypercube(modelObj, hypercubeObj, hypercubeName)
      if nargin < 3 || isempty(hypercubeName)
        hypercubeName = modelObj.checkHypercubeName(hypercubeObj);
      else
        hypercubeName = modelObj.checkHypercubeName(hypercubeName);
      end
      
      modelObj.data.(hypercubeName) = hypercubeObj;

      notify(modelObj.controller, 'modelChanged');
    end
    
    
    function deleteHypercube(modelObj, hypercubeName)
      modelObj.data = rmfield(modelObj.data, hypercubeName);

      notify(modelObj.controller, 'modelChanged');
    end
        
    
    function fld = nextModelFieldName(modelObj)
      % nextModelFieldName - get next default fld for .defaultName#
      
      flds = fieldnames(modelObj.data);
      tokens = regexp(flds,'hypercube(\d+)$', 'tokens');
      tokens = [tokens{:}]; % enter cells
      if ~isempty(tokens)
        tokens = [tokens{:}]; % get ind
        inds = str2double(tokens);
        
        availInds = setxor(inds, 1:max(inds)+1);
        selectedInd = min(availInds);
        
        fld = ['hypercube' num2str(selectedInd)];
      else
        fld = 'hypercube1';
      end
    end
    
    
    function fldOut = checkHypercubeName(modelObj, src)
      % checkHypercubeName - check if hypercubeName exists as field in model.
      %
      % Usage: [obj, hypercubeName_Out] = obj.checkHypercubeName(hypercubeName_In)
      %        [obj, hypercubeName_Out] = obj.checkHypercubeName(arrayObj)
      %
      % Details:
      %   If 2nd arg is hypercubeName_In, hypercubeName = hypercubeName_In.
      % If 2nd arg is arrayObj, check if hypercubeName = arrayObj.hypercubeName
      % exists. If not, use obj.nextModelFieldName.
      %   If hypercubeName is already a field in model without a trailing index,
      % add a 1 to original and make this new one with suffix 2. If exists with
      % index, increment to find next index.
      
      if isa(src, 'MDD') || isa(src, 'MDDRef') % or gvArray
        if ~isempty(src.hypercubeName)
          fldIn = src.hypercubeName;
        elseif isfield(src.meta, 'defaultHypercubeName')
          fldIn = src.meta.defaultHypercubeName;
        else
          fldIn = [];
        end
      elseif ischar(src)
        fldIn = src;
      else
        error('Unknown input')
      end
      
      if ~isempty(fldIn)
        flds = fieldnames(modelObj.data);
        
        hypercubeNameAlreadyExist = any(~cellfun(@isempty, regexp(flds, ['^' fldIn])));
        if hypercubeNameAlreadyExist
          fldInNoDigits = fldIn(1:find(~isstrprop(fldIn, 'digit'), 1, 'last'));
          tokens = regexp(flds,['^' fldInNoDigits '(\d+)$'], 'tokens');
          tokens = [tokens{:}]; % enter cells
          if ~isempty(tokens)
            tokens = [tokens{:}]; % get ind
            inds = str2double(tokens);
            fldOut = [fldInNoDigits num2str(max(inds)+1)];
          else
            % rename field with index 1
            modelObj.data.([fldIn '1']) = modelObj.data.(fldIn);
            modelObj.data = rmfield(modelObj.data, fldIn);
            
            fldOut = [fldIn '2'];
          end
        else
          fldOut = fldIn;
        end
      else % isempty(hypercubeName)
        fldOut = modelObj.nextModelFieldName; % get next fld for model.axes#
      end
    end
    
  end
  
  
  %% Protected Methods %%
  methods (Access = protected)

    function vprintf(obj, varargin)
      obj.app.vprintf(varargin{:});
    end
    
    function toHypercubeName(modelObj, src)
      if isa(src, 'MDD') || isa(src, 'MDDRef') % or gvArray
        if ~isempty(src.hypercubeName)
          fldIn = src.hypercubeName;
        elseif isfield(src.meta, 'defaultHypercubeName')
          fldIn = src.meta.defaultHypercubeName;
        else
          fldIn = [];
        end
      elseif ischar(src)
        fldIn = src;
      else
        error('Unknown input')
      end
    end
    
  end % protected methods
  
end % classdef
