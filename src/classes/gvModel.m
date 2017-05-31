%% gvModel - Model class for the GIMBL-Vis Model-View-Controller
%
% Author: Erik Roberts

classdef gvModel < handle
  
  properties %(SetObservable, AbortSet) % allows listener callback, aborts if set to current value
    data = struct() % of gvArrayRef
  end % public properties
  
  properties %(Access = private)
    app
    view
    controller
    listeners
  end % private properties
  
  events
  end
  
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
    
  end % public methods
  
end % classdef