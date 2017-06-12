function gvScrollCallback(figH, scrollData)

figPosPx = figH.Position;
mousePosPx = get(figH, 'CurrentPoint'); %pixels
% mousePos = mousePosPx ./ figH.Position(3:4); %relative

handles = gvHandlesFromFig(figH);

nVarSliders = length(handles.MainWindow.Handles.sH);

% Get marker slider imbeded in box pos
figPosPx = handles.output.Position;
boxPos = handles.plotMarkerOutline.Position;
boxPosPx = boxPos .* figPosPx;
markerSliderPosRel2Box = handles.markerSizeSlider.Position;
markerSliderPos(1:2) = (markerSliderPosRel2Box(1:2) + 1) .* boxPosPx(1:2) ./ figPosPx(1:2);
  % thisSliderPosRel2Box = ( (sPix-bPix)/bPix )
  % thisSliderPos = (thisSliderPosRel2Box*bPix + bPix) / figPix
markerSliderPos(3:4) = markerSliderPosRel2Box(3:4) .* boxPos(3:4);

% combined sliders pos
sliderPos = vertcat(cat(1,handles.MainWindow.Handles.sH.Position), markerSliderPos);

% Find Positions of LL and UR corners for each slider
sliderLLx  = sliderPos(:,1)*figPosPx(3);
sliderLLy  = sliderPos(:,2)*figPosPx(4);
sliderURx  = (sliderPos(:,1)+sliderPos(:,3))*figPosPx(3);
sliderURy  = (sliderPos(:,2)+sliderPos(:,4))*figPosPx(4);

% Determine which slider within 2 point boundary
sliderInd = find((mousePosPx(1)>=sliderLLx) .* (mousePosPx(1)<=sliderURx) .* (mousePosPx(2)>=sliderLLy) .* (mousePosPx(2)<=sliderURy));

% For testing
% fprintf('Scrolling over slider #: %i\n', onSlider)

if sliderInd %if in any slider
  eventdata = scrollData.VerticalScrollAmount*scrollData.VerticalScrollCount;

  if sliderInd <= nVarSliders % var slider
    hObject = handles.MainWindow.Handles.sH(sliderInd);
    if strcmp(hObject.Enable, 'on')
      gvSliderChangeCallback(hObject, eventdata, handles)
    end
  else% marker size slider
    hObject = handles.markerSizeSlider;
    if strcmp(hObject.Enable, 'on')
      gvMarkerSizeSliderCallback(hObject, eventdata, handles)
    end
  end
end

end
