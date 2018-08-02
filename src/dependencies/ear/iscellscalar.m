function OUT = iscellscalar(IN)
% iscellscalar(S) returns 1 if input is a cell array of scalars and 0 otherwise.

if iscell(IN)
  OUT = all( cellfun(@isscalar,IN(:)) & ~cellfun(@iscategorical, IN(:)) );
else
  OUT = false;
end

end