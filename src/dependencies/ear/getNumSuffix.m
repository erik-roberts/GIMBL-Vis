function suffix = getNumSuffix(str)
% getNumSuffix - get numeric suffix from string; returns [] if no numeric suffix.

suffix = regexp(str, '\D(\d*)$', 'tokens');
suffix = str2double(suffix{1}{1});
if isnan(suffix)
  suffix = [];
end

end