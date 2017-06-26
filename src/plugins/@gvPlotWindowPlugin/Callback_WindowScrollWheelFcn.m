function Callback_WindowScrollWheelFcn(src, evnt)
% Permits scrolling of select panel sliders in main window
mainPluginObj = src.UserData.pluginObj;
guiPluginObj = mainPluginObj.controller.guiPlugins.plot;

sliderObj = findobjReTag('plot_panel_markerSizeSlider');

if ~strcmp(mainPluginObj.whichTabActive.Title, guiPluginObj.pluginName) || strcmp(sliderObj.Enable, 'off')
  return % since wrong tab selected or slider off
end

figH = src;
scrollData = evnt;

mousePosPx = get(figH, 'CurrentPoint'); %pixels

sliderPos = guiPluginObj.getSliderAbsolutePosition();

% Find Positions of LL and UR corners for each slider
sliderLLx  = sliderPos(:,1);
sliderLLy  = sliderPos(:,2);
sliderURx  = (sliderPos(:,1)+sliderPos(:,3));
sliderURy  = (sliderPos(:,2)+sliderPos(:,4));

% Determine which slider within 2 point boundary
onSliderBool = logical((mousePosPx(1)>=sliderLLx) .* (mousePosPx(1)<=sliderURx) .* (mousePosPx(2)>=sliderLLy) .* (mousePosPx(2)<=sliderURy));

if onSliderBool %if in any slider
  sliderChange = scrollData.VerticalScrollAmount*scrollData.VerticalScrollCount;

  if strcmp(sliderObj.Enable, 'on')
    startValue = sliderObj.Value;
    newValue = max(min(sliderObj.Value+sliderChange, sliderObj.Max), sliderObj.Min);
    if startValue ~= newValue
      sliderObj.Value = newValue;
      
      guiPluginObj.Callback_plot_panel_markerSizeSlider(sliderObj);
    end
  end
end

end
