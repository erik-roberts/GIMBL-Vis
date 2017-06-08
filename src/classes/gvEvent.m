classdef (ConstructOnLoad) gvEvent < event.EventData
  %% gvEvent - event class for GIMBL-Vis
  %
  % Description: This subclass of event.EventData permits storage of data. If
  % the constructor is passed a char cast of a numeric, it will be recast to a
  % numeric.
  
  properties
    data
  end
  
  methods
    function eventData = gvEvent(varargin)
      if ~nargin
        data = [];
      elseif nargin == 1
        data = varargin{1};
      else
        data = struct(varargin{:}); % key-value pairs
      end
      
      % convert string to double if possible
      if ischar(data) && ~isnan(str2double(data))
        data = str2double(data);
      end
      
      eventData.data = data;
    end
  end
end