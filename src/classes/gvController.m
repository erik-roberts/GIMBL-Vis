%% gvController - Controller class for the GIMBL-Vis Model-View-Controller
%
% Author: Erik Roberts

classdef gvController < handle
  
  properties
    data = struct()
  end % public properties
  
  properties % TODO (Access = private)
    app
    model
    view
  end % private properties
  
  methods
    
    function obj = gvController(gvObj)
      if exist('gvObj','var') && ~isempty(gvObj)
        obj.app = gvObj;
        obj.model = gvObj.model;
        obj.view = gvObj.view;
      end
    end
    
  end % public methods
  
end % classdef
