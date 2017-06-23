function Callback_WindowScrollWheelFcn(src, evnt)
% Permits scrolling of select panel sliders in main window

pluginObj = src.UserData.pluginObj;
selectObj = pluginObj.controller.guiPlugins.select;

figH = src;
scrollData = evnt;

figPosPx = figH.Position;
mousePosPx = get(figH, 'CurrentPoint'); %pixels
% mousePos = mousePosPx ./ figH.Position(3:4); %relative

nVarSliders = length(pluginObj.view.dynamic.sliderVals);

% % Get marker slider imbeded in box pos
% figPosPx = figH.Position;
% boxPos = handles.plotMarkerOutline.Position;
% boxPosPx = boxPos .* figPosPx;
% markerSliderPosRel2Box = handles.markerSizeSlider.Position;
% markerSliderPos(1:2) = (markerSliderPosRel2Box(1:2) + 1) .* boxPosPx(1:2) ./ figPosPx(1:2);
%   % thisSliderPosRel2Box = ( (sPix-bPix)/bPix )
%   % thisSliderPos = (thisSliderPosRel2Box*bPix + bPix) / figPix
% markerSliderPos(3:4) = markerSliderPosRel2Box(3:4) .* boxPos(3:4);

% combined sliders pos
sliderHandles = sortByTag(findobjReTag('select_panel_slider\d+'));
% sliderPos = cat(1,sliderHandles.Position);
sliderPos = selectObj.getSliderAbsolutePosition();

% Find Positions of LL and UR corners for each slider
sliderLLx  = sliderPos(:,1);
sliderLLy  = sliderPos(:,2);
sliderURx  = (sliderPos(:,1)+sliderPos(:,3));
sliderURy  = (sliderPos(:,2)+sliderPos(:,4));

% Determine which slider within 2 point boundary
sliderInd = find((mousePosPx(1)>=sliderLLx) .* (mousePosPx(1)<=sliderURx) .* (mousePosPx(2)>=sliderLLy) .* (mousePosPx(2)<=sliderURy));

% For testing
% fprintf('Scrolling over slider #: %i\n', onSlider)

if sliderInd %if in any slider
  sliderChange = scrollData.VerticalScrollAmount*scrollData.VerticalScrollCount;
  
  sliderObj = sliderHandles(sliderInd);
  
  if strcmp(sliderObj.Enable, 'on')
    startValue = sliderObj.Value;
    newValue = max(min(sliderObj.Value+sliderChange, sliderObj.Max), sliderObj.Min);
    if startValue ~= newValue
      sliderObj.Value = newValue;
      selectObj.Callback_select_panel_slider(sliderObj);
    end
  end
end

end
