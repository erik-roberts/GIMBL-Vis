function gvImagePanel(hObject, eventdata, handles)

if ~isValidFigHandle(handles.ImagePanel.handle)
  createImagePanel()
end

% Update handles structure
guidata(hObject, handles);

  function createImagePanel()
    if ~isValidFigHandle('handles.PlotPanel.figHandle')
      hFig = figure('Name','Image Panel','NumberTitle','off');
    else
      plotPanPos = handles.PlotPanel.figHandle.Position;
      newPos = plotPanPos; % same size as plot panel
      newPos(1) = newPos(1)+newPos(3)+50; % move right
%       newPos(3:4) = newPos(3:4)*.8; %shrink
      hFig = figure('Name','Image Panel','NumberTitle','off','Position',newPos);
    end
    
%     if isfield(handles.ImagePanel, 'lastPos')
%       hFig.Units = 'normalized';
%       hFig.Position = handles.ImagePanel.lastPos;
%     end
    axes(hFig, 'Position', [0 0 1 1], 'XTickLabels',[], 'YTickLabels',[],...
      'XTick',[], 'YTick',[]);
    handles.ImagePanel.handle = hFig;
  end

end