function sortedHandles = sortByTag( handleArray, byNumSuffixBool )

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