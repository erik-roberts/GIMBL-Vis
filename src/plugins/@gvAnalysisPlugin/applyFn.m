function applyFn(pluginObj)
global gvAnalysisPlugin_applyFn_temp__
evalin('base', 'global gvAnalysisPlugin_applyFn_temp__');

settings = pluginObj.metadata.settings;

settings.source = pluginObj.controller.model.data.(settings.sourceHypercubeName);

if isempty(pluginObj.metadata.settings)
  error('gvAnalysisPlugin: settings not found.')
end

% apply fn
switch settings.sourceType
  case 'Hypercube Data Array'
    out = feval(settings.fn, settings.source.data, settings.fnArgs{:});
  case 'Hypercube Data Points (Arrayfun)'
    out = arrayfun(settings.fn, settings.source.data);
  case 'Hypercube Object'
    out = feval(settings.fn, settings.source, settings.fnArgs{:});
end

% add output to target
targetStr = settings.targetStr;
switch settings.targetType
  case 'Merge into Source Hypercube'
    dataStr = [func2str(settings.fn) 'Data'];
    
    % assign axis name if target empty
    if isempty(targetStr)
      targetStr = 'dataType';
    end
    
    % look for axis target
    axInd = find(strcmp(settings.source.axisNames, targetStr), 1);
    
    % make new axis if needed
    if isempty(axInd)
      nDims = settings.source.ndims;
      axInd = nDims + 1;
      settings.source.axis(axInd) = gvArrayAxis;
      settings.source.axis(axInd).name = targetStr;
      settings.source.axis(axInd).values = {'originalData'};
    end
    
    % create hypercube to merge
    if ~isa(out, 'gvArrayRef')
      axisNames = settings.source.axisNames;
      axisValues = settings.source.axisValues;
      axisValues{axInd} = {dataStr};
      
      cube2merge = gvArray(out, axisValues, axisNames);
    else
      cube2merge = out;
    end
    
    % merge data
    settings.source.merge(cube2merge);
    
    notify(pluginObj.controller, 'modelChanged');
  case 'New Hypercube'
    % get hypercube name
    dataStr = [func2str(settings.fn) 'Data'];
    if isempty(targetStr)
      targetStr = dataStr;
    end
    
    % make new hypercube
    if isa(out, 'gvArrayRef')
      newHypercube = out;
    else
      newHypercube = gvArrayRef(out);
    end
    
    % add hypercube
    pluginObj.controller.model.addHypercube(newHypercube, targetStr);
  case 'Workspace Variable'
    % get ws var name
    dataStr = [func2str(settings.fn) 'Data'];
    if isempty(targetStr)
      targetStr = dataStr;
    end
    
    gvAnalysisPlugin_applyFn_temp__ = out;
    
    evalin('base', [targetStr '= gvAnalysisPlugin_applyFn_temp__;']);
  case 'New File'
    % get absolute path to file
    dataStr = [func2str(settings.fn) 'Data'];
    if isempty(targetStr)
      targetStr = fullfile(pwd, dataStr);
    else
      targetStr = getAbsolutePath(targetStr);
    end
    
    % make new var
    eval([dataStr ' = out']);
    
    % save var to file
    save(targetStr, dataStr);
end

% handle source deletion
if settings.deleteSourceBool
  pluginObj.controller.model.deleteHypercube(settings.sourceHypercubeName);
end

clear global gvAnalysisPlugin_applyFn_temp__

end
