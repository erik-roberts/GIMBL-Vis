function hideEmptyAxes(hFig)
%
% Author: Erik Roberts
  
hAx = hFig.Children;

for hInd = 1:length(hAx)
  if strcmp(hAx(hInd).Type, 'axes') && isempty(hAx(hInd).Children)
    hAx(hInd).Visible = 'off';
  end
end   

end
