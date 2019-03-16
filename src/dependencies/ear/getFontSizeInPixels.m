function [textWidth, textHeight] = getFontSizeInPixels(fontSize, s)
% getFontSizeInPixels - get font size in pixels based on fontSize input (points or normalized)
% e.g., 13 points = 0.04 normalized => 6.4 px width

s.FontSize = fontSize;
if nargin < 2
  if s.FontSize <= 1
    s.FontUnits = 'normalized';
  else
    s.FontUnits = 'points';
  end
  s.FontAngle = get(0,'defaultuicontrolFontAngle');
  s.FontName = get(0,'defaultuicontrolFontName');
  s.FontWeight = get(0,'defaultuicontrolFontWeight');
end

if ~isfield(s, 'Position')
  s.Position = [0 0 560 420]; % use ml2017b default figure size
end

hFig = figure('Visible','off', 'Position',s.Position);
hAx = axes(hFig);

% Get text size in data units
hTest = text(0,0,'2','Units','pixels', 'FontUnits',s.FontUnits,...
    'FontAngle',s.FontAngle, 'FontName',s.FontName, 'FontSize',s.FontSize,...
    'FontWeight',s.FontWeight,'Parent',hAx);
textExt = get(hTest,'Extent');

delete(hFig)

textHeight = textExt(4);
textWidth = textExt(3);

% If using a proportional font, shrink text width by a fudge factor to
% account for kerning.
if ~strcmpi(s.FontName,'FixedWidth')
    textWidth = textWidth*0.8;
end

end