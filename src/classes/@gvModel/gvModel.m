%% gvModel - Model class for the GIMBL-Vis Model-View-Controller
%
% Methods (public):
%   toRef - convert all model data to gvArrayRef
%
% Methods (protected):
%   nextModelFieldName - get next default field for model
%   checkModelFieldName - check if hypercubeName exists as field in model
%
% Author: Erik Roberts

classdef gvModel < handle
  
  properties %(SetObservable, AbortSet) % allows listener callback, aborts if set to current value
    data = struct() % of gvArrayRef
  end % public properties
  
  properties % TODO (Access = private)
    app
    view
    controller
    listeners
  end % private properties
  
  %% Events %%
  events
  end
  
  %% Public Methods %%
  methods
    
    function obj = gvModel(gvObj)
      if exist('gvObj','var') && ~isempty(gvObj)
        obj.app = gvObj;
        obj.view = gvObj.view;
        obj.controller = gvObj.controller;
      end
    end
    

    function obj = toRef(obj, flds)
      %toRef - convert all model data to gvArrayRef
      
      if ~exist('flds','var') || isempty(flds)
        flds = fieldnames(obj.data);
      end
      
      for iFld = 1:length(flds)
        fld = flds{iFld};
        if ~isa(obj.data.(fld), 'gvArrayRef')
          obj.data.(fld) = gvArrayRef(obj.data.(fld));
        end
      end
    end
    
    %% Loading
    obj = load(obj, src, fld, staticBool)
    
  end % public methods
  
  %% Protected Methods %%
  methods (Access = protected)
    
    function fld = nextModelFieldName(obj)
      % nextModelFieldName - get next default fld for .defaultName#
      
      flds = fieldnames(obj.data);
      tokens = regexp(flds,'hypercube(\d+)$', 'tokens');
      tokens = [tokens{:}]; % enter cells
      if ~isempty(tokens)
        tokens = [tokens{:}]; % get ind
        inds = str2double(tokens);
        fld = ['hypercube' num2str(max(inds)+1)];
      else
        fld = 'hypercube1';
      end
    end
    
    
    function [obj, fldOut] = checkModelFieldName(obj, src)
      % checkModelFieldName - check if hypercubeName exists as field in model.
      %
      % Usage: [obj, hypercubeName_Out] = obj.checkModelFieldName(hypercubeName_In)
      %        [obj, hypercubeName_Out] = obj.checkModelFieldName(arrayObj)
      %
      % Details:
      %   If 2nd arg is hypercubeName_In, hypercubeName = hypercubeName_In.
      % If 2nd arg is arrayObj, check if hypercubeName = arrayObj.hypercubeName
      % exists. If not, use obj.nextModelFieldName.
      %   If hypercubeName is already a field in model without a trailing index,
      % add a 1 to original and make this new one with suffix 2. If exists with
      % index, increment to find next index.
      
      if isa(src, 'MDD') || isa(src, 'MDDRef') % or gvArray
        if isfield(src.meta, 'hypercubeName')
          fldIn = src.meta.hypercubeName;
        else
          fldIn = [];
        end
      elseif ischar(src)
        fldIn = src;
      else
        error('Unknown input')
      end
      
      if ~isempty(fldIn)
        flds = fieldnames(obj.data);
        
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
            obj.data.([fldIn '1']) = obj.data.(fldIn);
            obj.data = rmfield(obj.data, fldIn);
            
            fldOut = [fldIn '2'];
          end
        else
          fldOut = fldIn;
        end
      else % isempty(hypercubeName)
        fldOut = obj.nextModelFieldName; % get next fld for model.axes#
      end
    end
    
  end
  
end % classdef
