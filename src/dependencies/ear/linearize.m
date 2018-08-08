function x = linearize(x)
%% linearize
%
% Purpose: linearize an array. This fn is useful when wanting to linearize the
%  contents of a struct field, which normally requires an additional assignment
%  step.
%
% Code: x = x(:);
%
% Author: Erik Roberts

x = x(:);

end