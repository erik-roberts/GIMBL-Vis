function out = findobjReTag(varargin)
% Author: Erik Roberts

out = findobj('-regexp','Tag',varargin{:});

end
