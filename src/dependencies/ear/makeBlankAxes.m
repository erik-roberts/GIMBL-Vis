function axh = makeBlankAxes(figH)
%
% Author: Erik Roberts
  
axh = axes(figH, 'Position', [0 0 1 1], 'XTickLabels',[], 'YTickLabels',[],...
  'XTick',[], 'YTick',[]);
xlim(plotAxH, [0,1])
ylim(plotAxH, [0,1])
  
end
