function out = findobjReTag(varargin)

out = findobj('-regexp','Tag',varargin{:});

end