function sortedHandles = sortByTag( handleArray, byNumSuffixBool )
%
% Author: Erik Roberts
  
if nargin < 2
  byNumSuffixBool = false;
end

tags = {handleArray.Tag};

if byNumSuffixBool
  tagNums = cellfun(@getNumSuffix, tags);
  [~, ind] = sort(tagNums);
else
  
  [~, ind] = sort(tags);
end

sortedHandles = handleArray(ind);

end
