function [textWidth, textHeight] = getFontSizeInPixels(fontSize, s)
% getFontSizeInPixels - get font size in pixels based on fontSize input

s.FontSize = fontSize;
if nargin < 2
  s.FontUnits = 'points';
  s.FontAngle = get(0,'defaultuicontrolFontAngle');
  s.FontName = get(0,'defaultuicontrolFontName');
  s.FontWeight = get(0,'defaultuicontrolFontWeight');
end

hFig = figure('Visible','off');
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