function makeFig(pluginObj)

% determine figure pos
pos = pluginObj.getConfig([pluginObj.pluginClassName '_Position']);
if isempty(pos)
  % default Position
  
  pos = [29 778 567 567];
end


mainWindowHandle = figure(...
  'Units','pixels',...
  'Position',pos,...
  'MenuBar','none',...
  'Name',pluginObj.windowName,...
  'NumberTitle','off',...
  'Tag',pluginObj.figTag(),...
  'UserData',pluginObj.userData,...
  'CloseRequestFcn',@pluginObj.Callback_CloseRequestFcn,...
  'WindowScrollWheelFcn', @pluginObj.Callback_WindowScrollWheelFcn...
);

% Set Handle
pluginObj.handles.fig = mainWindowHandle;

end
