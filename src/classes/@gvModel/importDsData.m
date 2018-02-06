function importDsData(modelObj, src, varargin)
% importDsData - import dynasim data
%
% src is a path to a dir or a mat file to save to.

% DEV TODO: check classify functions and analysis functions mixture

%% Setup args
if nargin < 2
  src = pwd;
end

%% Check Options
options = checkOptions(varargin,{...
  'classifyFn', [], [],...
  'overwriteBool', 0, {0,1},... % whether overlapping table entries should be overwritten
  'covarySplitBool', 0, {0,1},... % whether to split varied parameters that affect multiple namespaces
  },false);

%% Parse src
[parentDir,filename, ext] = fileparts(src);
if exist(src, 'dir')
  filePath = fullfile(src, 'gvArrayData.mat');
elseif exist(src, 'file') && strcmp(filename, 'studyinfo') % src = studyinfo.mat
  src = parentDir;
  filePath = fullfile(parentDir, 'gvArrayData.mat');
elseif ~isempty(ext) && ~strcmp(ext, '.mat')
  error('Path input is not a mat file or dir to save ''gvData.mat'' file.')
  % else % given valid mat filename
end

%% Load or Make gvData
if ~exist(filePath,'file') || options.overwriteBool
  % Import studyinfo data
  modelObj.vprintf('gvModel: Importing studyinfo...\n')
  studyinfo = dsCheckStudyinfo(src);
  
  studyinfoParams = studyinfo.base_model.parameters;
  studyinfoParamNames = fieldnames(studyinfoParams);
  
  mods = {studyinfo.simulations.modifications};
  mods = cellfunu(@expand_simultaneous_modifications, mods); % expand simultaneously affected groups
  mods = cellfunu(@arrows2underscores, mods); % fix arrow direction and convert to underscores
  nMods = length(mods);
  modVals = cellfunu(@(x) x(:,3), mods);
  modNames = cellfunu(@(x) x(:,1:2), mods);
  
  % Make names match params
  % and expand mods that share namespace across params
  for iMod = 1:nMods
    nRows = size(modNames{iMod}, 1);
    
    % NOTE: these may have diff nRows from modNames{iMod}
    thisModNames = {};
    thisModVals = {};
    
    for iRow = 1:nRows
      
      % replace periods with underscore in names
      modNames{iMod}{iRow,1} = strrep(modNames{iMod}{iRow,1}, '.','_');
      modNames{iMod}{iRow,2} = strrep(modNames{iMod}{iRow,2}, '.','_');
      
      thisRowName = [modNames{iMod}{iRow,1}, '_', modNames{iMod}{iRow,2}]; % get original row names
      thisRowVal = modVals{iMod}{iRow};% get original row val
      
      if any(strcmp(thisRowName, studyinfoParamNames)) % if matches studyinfoParamNames
        thisModNames{end+1} = thisRowName;
        thisModVals{end+1} = thisRowVal;
      else % need to get full namespace
        re = ['(' modNames{iMod}{iRow,1}, '_.+_', modNames{iMod}{iRow,2} ')']; % make re from original row names
        tokens = regexp(studyinfo.base_model.namespaces(:,2), re, 'tokens');
        tokens = [tokens{:}]; % remove empty
        tokens = [tokens{:}];
        
        thisNrows = numel(tokens);
        
        if thisNrows == 0 % token name not found. likely didn't match so didn't do anything
          % skip it
          continue
        elseif thisNrows == 1 || ~options.covarySplitBool
          thisRowName = tokens{1};
          thisModNames{end+1} = thisRowName;
          thisModVals{end+1} = thisRowVal;
        else % mod affects multiple mechs
          thisModNames(end+1:end+thisNrows) = tokens;
          thisModVals(end+1:end+thisNrows) = repmat({thisRowVal}, 1,thisNrows);
        end
      end
      
    end
    
    % update cells
    modNames{iMod} = thisModNames(:); % ensure col array
    modVals{iMod} = thisModVals(:); % ensure col array
  end
  
  importVariedParamVals();
  
  simIDs = {studyinfo.simulations.sim_id}';
  
  % TODO in case this is useful later:
  %   modNames = cat(2,modNames(:,1), repmat({'_'},size(modNames,1), 1), modNames(:,2));

  % get results struct with fieldnames = analysisFns
  analysisResults = dsImportResults(src, 'import_scope','allResults', 'simplify2cell_bool',0);
  
  % Get analysis functions
  analysisFnIndStr = fieldnames(analysisResults);
  
  analysisFnNameInd = regexpi(analysisFnIndStr, '(\w+)(\d+)', 'tokens');
  analysisFnNameInd = [analysisFnNameInd{:}];
  analysisFnNameInd = cat(1, analysisFnNameInd{:});
  
  % Determine classification functions
  if isempty(options.classifyFn) && ~isempty(analysisFnIndStr)
    classifyFns = regexpi(analysisFnIndStr, '(.*class.*)', 'tokens');
    classifyFns = [classifyFns{:}]; % remove empty
    if ~isempty(classifyFns)
      classifyFns = [classifyFns{:}]; % cat
    end
  elseif ~isempty(options.classifyFn)
    classifyFns = options.classifyFn;
  end
  
  if ~isempty(analysisFnIndStr)
    % Import analysis results
    modelObj.vprintf('gvModel: Importing analysis results...\n')

    for iFn = 1:numel(analysisFnIndStr)
      thisResultFn = analysisFnIndStr{iFn};

      if length( analysisResults.(thisResultFn) ) ~= size(variedParamValues,1)
        wprintf('\tDifferent lengths for number of modifications and %s results.', thisResultFn)
      end
    end
    
    modelObj.vprintf('\tDone importing analysis results\n')
    
    modelObj.vprintf('gvModel: Preparing data to save...\n')
    
    
    % Remove missing data
    missingClassResultsInd = cellfun(@isempty,analysisResults.(thisResultFn));
    for fld = fieldnames(analysisResults)
      missingClassResultsInd = missingClassResultsInd | cellfun(@isempty,analysisResults.(fld{1}));
    end
    
    for fld = fieldnames(analysisResults)'
      analysisResults.(fld{1})(missingClassResultsInd) = [];
    end
    variedParamValues(missingClassResultsInd,:) = [];
    simIDs(missingClassResultsInd) = [];
    
    % Get class info
    classes = struct();
    for iFn = 1:numel(classifyFns)
      if numel(classifyFns) == 1 % rename class fn to 'class'
        thisFnStr = 'class';
        analysisResults.(thisFnStr) = analysisResults.(classifyFns{1});
        analysisResults = rmfield(analysisResults, classifyFns{1});
        thisFnHandle = str2func(classifyFns{1});
        classifyFns{1} = thisFnStr;
      else
        thisFnStr = classifyFns{iFn};
        thisFnHandle = str2func(thisFnStr);
      end
      
      uClassNames = unique(analysisResults.(thisFnStr));
      
      try % to get info from class fn call
        info = feval(thisFnHandle, 'info');
        assert(size(info, 1) >= length(uClassNames))
        classes.(thisFnStr).labels = info(:,1);
        if size(info, 2) > 1 % if color col
          tempColors = info(:,2); % as cells
          tempColors = vertcat(tempColors{:}); % convert cell 2 mat
          classes.(thisFnStr).colors = tempColors; % store mat
          clear tempColors
        else
          classes.(thisFnStr).colors = distinguishable_colors(length(classes.(thisFnStr).labels));
        end
        
        if size(info, 2) > 2 % if marker col
          classes.(thisFnStr).markers = info(:,3);
        end
      catch
        classes.(thisFnStr).labels = uClassNames;
        classes.(thisFnStr).colors = distinguishable_colors(length(classes.(thisFnStr).labels));
      end
    end
  end
  
  %% prepare data
  %   simIDstr = cellfunu(@num2str, simIDs);
  axisNames = variedParamNames;
  axisVals = cell(1,nVariedParams);
  for iParam = 1:nVariedParams
    thisParamValues = variedParamValues(:, iParam);
    %     if isnumeric([thisParamValues{:}])
    %       axisVals{iParam} = cellfunu(@num2str, thisParamValues);
    %     else
    axisVals{iParam} = thisParamValues;
    %     end
  end
  
  %% gvArray
  dynasimData = gvArray;
  dynasimData.meta.defaultHypercubeName = 'dsData';
    
  % store simIDs in axis 1
  analysisResults.simID = simIDs;

  % Make model object
  allResults = {};
  allAxisVals = cell(1, length(axisVals)+1);
  dynasimData.axis(1).axismeta.dataType = {};
  dynasimData.axis(1).axismeta.plotInfo = {};
  for analysisFnName = fieldnames(analysisResults)'
    analysisFnName = analysisFnName{1};

    allResults = [allResults; analysisResults.(analysisFnName)];

    % Add Analysis Fn Name to allAxisVals
    fnNameCell = cell(length(analysisResults.(analysisFnName)),1);
    fnNameCell(:) = deal({analysisFnName});
    allAxisVals{1} = [allAxisVals{1}; fnNameCell];
    
    % Add rest of axes to allAxisVals
    for jCol = 1:length(axisVals)
      allAxisVals{jCol+1} = [allAxisVals{jCol+1}; axisVals{jCol}]; % TODO: speed up with vector ops
    end
    
    % store data types in axismeta
    if strcmp(analysisFnName, 'simID')
      dynasimData.axis(1).axismeta.dataType{end+1} = 'index';
    elseif iscellnum(analysisResults.(analysisFnName))
      dynasimData.axis(1).axismeta.dataType{end+1} = 'numeric';
    elseif iscellstr(analysisResults.(analysisFnName))
      dynasimData.axis(1).axismeta.dataType{end+1} = 'categorical';
      
      % store classes
      axValInd = length(dynasimData.axis(1).axismeta.dataType);
      dynasimData.axis(1).axismeta.plotInfo{axValInd} = classes.(analysisFnName);
    else
      dynasimData.axis(1).axismeta.dataType{end+1} = 'unknown';
    end
    
  end
  
  % Import data table
  try
    dynasimData = dynasimData.importDataTable(allResults, allAxisVals, [{'analysisFn'} axisNames]);
  catch
    warning('Attempting to import overlapping entries. Setting overwriteBool=true to overwrite overlapping entries with the last duplicate entry.')
    dynasimData = dynasimData.importDataTable(allResults, allAxisVals, [{'analysisFn'} axisNames], true);
  end
  
  % Store axisType in axis
  dynasimData.axis(1).axismeta.axisType = 'dataType';
  
  % Store data
  hypercubeObj = gvArrayRef(dynasimData);
  modelObj.addHypercube(hypercubeObj);
  
  modelObj.vprintf('gvModel: Imported multidimensional array object from Dynasim data from: %s\n', filePath)
  
  % Save
  save(filePath, 'dynasimData') % save gvArray obj
  modelObj.vprintf('\tSaved dynasim data as ''gvArray'' object in file ''.\\gvArrayData.m''.\n')
  
else % data file exists
  warning('File exists and overwriteBool=false. Choose new file name or set overwriteBool=true for new import.')
  modelObj.vprintf('gvModel: Loading dynasim data from: %s\n', filePath)
  
  modelObj.load(filePath);
end


%% Nested Fns
  function  importVariedParamVals()
    modelObj.vprintf('gvModel: Importing varied parameter values...\n')
    
    % Get varied params
    variedParamNames = vertcat(modNames{:});
    variedParamNames = unique(variedParamNames)';
    nVariedParams = numel(variedParamNames);
    
    % Get param values for each sim
    variedParamValues = cell(nMods, nVariedParams);
    for iParam = 1:nVariedParams
      thisParam = variedParamNames{iParam};
      thisStudyinfoParamValue = studyinfoParams.(thisParam);
      for iMod = 1:nMods
        thisModParams = modNames{iMod};
        thisModInd = strcmp(thisModParams, thisParam);
        if any(thisModInd)
          variedParamValues{iMod, iParam} = modVals{iMod}{thisModInd};
        else  % param missing for this sim, so use the value from studyinfo (for sims with sparse vary, ie non lattice)
          variedParamValues{iMod, iParam} = thisStudyinfoParamValue;
        end
      end
    end
    
    %   for iParam = 1:nVariedParams
    %     VariedData.(variedParamNames{iParam}) = variedParamValues(:,iParam);
    %   end
    
    modelObj.vprintf('\tDone importing varied parameter values.\n')
  end


  function mods = arrows2underscores(mods)
    % Purpose: fix arrow direction and convert to underscores
    mods(:,1:2) = cellfun( @fix_arrows, mods(:,1:2),'UniformOutput',0); % fix order of directionality to be L -> R
    mods(:,1:2) = cellfun( @(x) strrep(x,'->','_'),mods(:,1:2),'UniformOutput',0); % replace modification arrows with _
    
    function obj = fix_arrows(obj)
      if any(strfind(obj,'<-'))
        ind=strfind(obj,'<-');
        obj=[obj(ind(1)+2:end) '->' obj(1:ind(1)-1)];
      end
    end
  end


  function modifications = expand_simultaneous_modifications(mods)
    % Purpose: expand simultaneous modifications into larger list
    % NOTE: copied from dsSimulate expand_modifications subfunction
    modifications={};
    for i=1:size(mods,1)
      % get object list without grouping symbols: ()[]{}
      objects=regexp(mods{i,1},'[^\(\)\[\]\{\},]+','match');
      variables=regexp(mods{i,2},'[^\(\)\[\]\{\},]+','match');
      
      for j=1:length(objects)
        for k=1:length(variables)
          thisModNames = mods{i,3};
          
          if all(size(thisModNames) == [1,1]) %same val for each obj and var
            modifications(end+1,1:3)={objects{j},variables{k},thisModNames};
          elseif (size(thisModNames,1) > 1) && (size(thisModNames,2) == 1) %same val for each obj, diff for each var
            modifications(end+1,1:3)={objects{j},variables{k},thisModNames(k)};
          elseif (size(thisModNames,1) == 1) && (size(thisModNames,2) > 1) %same val for each var, diff for each obj
            modifications(end+1,1:3)={objects{j},variables{k},thisModNames(j)};
          elseif (size(thisModNames,1) > 1) && (size(thisModNames,2) > 1) %diff val for each var and obj
            modifications(end+1,1:3)={objects{j},variables{k},thisModNames(k,j)};
          else
            error('Unknown modification type (likely due to excess dims)')
          end %if
        end %k
      end %j
    end %i
  end  %fun

end
