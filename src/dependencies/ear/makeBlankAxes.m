function axh = makeBlankAxes(figH)
%% makeBlankAxes
% Author: Erik Roberts
  
axh = axes(figH, 'Position', [0 0 1 1], 'XTickLabels',[], 'YTickLabels',[],...
  'XTick',[], 'YTick',[]);
xlim(axh, [0,1])
ylim(axh, [0,1])
  
end