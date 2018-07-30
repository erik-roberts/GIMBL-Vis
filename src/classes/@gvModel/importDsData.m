function importDsData(modelObj, src, varargin)
% importDsData - import dynasim data
%
% src is a path to a dir or a mat file to save to.

%{
DEV TODO:
- check classify functions and analysis functions mixture
- dsCheckCovary
%}

%% Setup args
if nargin < 2
  src = pwd;
end

%% Check Options
options = checkOptions(varargin,{...
  'classifyFn', [], [],...
  'overwriteBool', 0, {0,1},... % whether overlapping table entries should be overwritten
  'covarySplitBool', 0, {0,1},... % whether to split varied parameters that affect multiple namespaces, if not probably cannot merge new sims later
  'fillMissingResultsBool', 1, {0,1},... % whether to fill missing results with nan or 'missing' category
  'includeMissingParam', 0, {0,1},... % whether to include missing parameters as dimensions
  'saveBool', 1, {0,1},... % whether to save gvArrayData
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
  modelObj.vprintf('[gvModel] Importing studyinfo...\n')
  studyinfo = dsCheckStudyinfo(src);
  
  studyinfoParams = studyinfo.base_model.parameters;
  studyinfoParamNames = fieldnames(studyinfoParams);
  
  % add state var initial conditions
  initialStateVars = cellfun(@(x) [x '_0_'], studyinfo.base_model.state_variables(:), 'uni',0);

  % vertcat initialStateVars with initialStateVars
  studyinfoParamNames = [studyinfoParamNames; initialStateVars];
  
  mods = {studyinfo.simulations.modifications};
  
  if isempty(mods{1})
    modelObj.vprintf('[gvModel] Attempted to import DS data with no vary \n');
    wprintf('GIMBL-Vis Only Supports DynaSim studies with multiple simulations (using ''vary'').');
    return
  end
  
  nSims = length(mods);
  nVaryPerMod = size(mods{1}, 1);
  
  for iSim = 1:nSims
    %change initial conditions (0) to _0_
    mods{iSim}(:,2) = strrep(mods{iSim}(:,2), '(0)', '_0_');
    
    % standardize and expand modifications
    [mods{iSim}, identLinkedMods] = dsStandardizeModifications(mods{iSim}, studyinfo.base_model.specification);
  end
  
  nLinkedMods = length(identLinkedMods);
  
  % check for covary
  if nVaryPerMod ~= size(mods{1}, 1)
    % TODO: covary pop or mech that was expanded
  end
  
%   mods = cellfunu(@expand_simultaneous_modifications, mods); % expand simultaneously affected groups
  mods = cellfunu(@arrows2underscores, mods); % fix arrow direction and convert to underscores
  
  modVals = cellfunu(@(x) x(:,3), mods);
  modNames = cellfunu(@(x) x(:,1:2), mods); 
  
  nMods = numel(modVals{1});
  
  clear mods
  
  % Make names match params
  % and expand mods that share namespace across params
  for iSim = 1:nSims
    nRows = size(modNames{iSim}, 1);
    
    % NOTE: these may have diff nRows from modNames{iSim}
    thisModNames = {};
    thisModVals = {};
    
    missingRows = false(1,nRows); % store which rows are missing
    
    for iRow = 1:nRows
      
      % replace periods with underscore in names
      modNames{iSim}{iRow,1} = strrep(modNames{iSim}{iRow,1}, '.','_');
      modNames{iSim}{iRow,2} = strrep(modNames{iSim}{iRow,2}, '.','_');
      
      thisRowName = [modNames{iSim}{iRow,1}, '_', modNames{iSim}{iRow,2}]; % get original row names
      thisRowVal = modVals{iSim}{iRow};% get original row val
      
      if any(strcmp(thisRowName, studyinfoParamNames)) || options.includeMissingParam % if matches studyinfoParamNames
        thisModNames{end+1} = thisRowName;
        thisModVals{end+1} = thisRowVal;
      else % need to get full namespace
        re = ['(' modNames{iSim}{iRow,1}, '_.+_', modNames{iSim}{iRow,2} ')']; % make re from original row names
%         tokens = regexp(studyinfo.base_model.namespaces(:,2), re, 'tokens');
        tokens = regexp(studyinfoParamNames, re, 'tokens');
        tokens = [tokens{:}]; % remove empty
        tokens = [tokens{:}];
        
        thisNrows = numel(tokens);
        
        if thisNrows == 0 % token name not found. likely didn't match so didn't do anything
          % skip it
          missingRows(iRow) = true;
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
    modNames{iSim} = thisModNames(:); % ensure col array
    modVals{iSim} = thisModVals(:); % ensure col array
  end
  
  if any(missingRows)
    wprintf('Some mechanisms are missing so those modifcations are not imported.');
    
    % reindex linked mod numbers
    for iLinkMod = 1:nLinkedMods
      thisLinkedRows = identLinkedMods{iLinkMod};
      
      tempInds = false(1,nMods);
      tempInds(thisLinkedRows) = true;
      tempInds(missingRows) = [];
      
      identLinkedMods{iLinkMod} = find(tempInds);
      
      clear tempInds
    end
    
    nMods = sum(~missingRows); % update new nMods
  end
  
  importVariedParamVals();
    % this switches vars from modNames to variedParamNames and modVals to variedParamValues
  
  if ~options.covarySplitBool && nLinkedMods>0
    for iLinkMod = 1:nLinkedMods
      thisLinkedRows = identLinkedMods{iLinkMod};
      
      thisLinkedModNames = modNames{1}(thisLinkedRows);
      thisCombName = strjoin(thisLinkedModNames, '-');
      
      [~, indVarParName] = intersect(variedParamNames, thisLinkedModNames);
      
      % the new index
      newInd = indVarParName(1);
      
      % indices to remove
      removeInd = indVarParName(2:end);
      
      % change name to merged name
      variedParamNames{newInd} = thisCombName;
      
      % remove duplicates
      variedParamNames(removeInd) = [];
      variedParamValues(:, removeInd) = [];
    end
    
    nVariedParams = numel(variedParamNames); % update val
  end
  
  clear modNames modVals
  
  simIDs = {studyinfo.simulations.sim_id}';
  
  % get results struct with fieldnames = analysisFns
  analysisResults = dsImportResults(src, 'import_scope','allResults', 'as_cell',0);
  
  if ~isempty(analysisResults)
    % Get analysis functions
    analysisFnIndStr = fieldnames(analysisResults);
    
%     analysisFnNameInd = regexpi(analysisFnIndStr, '(\w+)(\d+)', 'tokens');
%     analysisFnNameInd = [analysisFnNameInd{:}];
%     analysisFnNameInd = cat(1, analysisFnNameInd{:});
%     analysisFnName = analysisFnNameInd(:,1);
    
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
  else
    analysisFnIndStr = [];
  end
  
  if ~isempty(analysisFnIndStr)
    % Import analysis results
    modelObj.vprintf('[gvModel] Importing analysis results...\n')

    resultsUnequal = 0;
    
    for iFn = 1:numel(analysisFnIndStr)
      thisResultFn = analysisFnIndStr{iFn};

      if length( analysisResults.(thisResultFn) ) ~= size(variedParamValues,1)
        resultsUnequal = resultsUnequal + 1;
      end
    end

    if resultsUnequal ~= 0
      wprintf('\tDifferent lengths for number of modifications and %s results.', thisResultFn)
    end
    
    modelObj.vprintf('\tDone importing analysis results\n')
    
    modelObj.vprintf('[gvModel] Preparing data to save...\n')
    
    
    % Fill missing data
    missingClassResultsInd = cellfun(@isempty,analysisResults.(thisResultFn));
    for fld = fieldnames(analysisResults)'
      missingClassResultsInd = missingClassResultsInd | cellfun(@isempty,analysisResults.(fld{1}));
    end
    
    if options.fillMissingResultsBool
      % check against simIDs length
      if length(simIDs) > length(missingClassResultsInd)
        % add more missing indicies
        missingClassResultsInd(end+1: length(simIDs)) = true;
      end

      for analysisFnName = fieldnames(analysisResults)'
        analysisFnName = analysisFnName{1};

        if iscellnum(analysisResults.(analysisFnName)(~missingClassResultsInd))
          % fill missing with nan
          analysisResults.(analysisFnName)(missingClassResultsInd) = {nan};
        elseif iscellstr(analysisResults.(analysisFnName)(~missingClassResultsInd))
          % fill missing with string
          analysisResults.(analysisFnName)(missingClassResultsInd) = {'missing'};

          % convert to categorical in cells
          analysisResults.(analysisFnName) = num2cell( categorical(analysisResults.(analysisFnName)) );
        end

        % TODO: handle categorical
      end
    else % ~options.fillMissingResultsBool
      for analysisFnName = fieldnames(analysisResults)'
        analysisFnName = analysisFnName{1};
        
        analysisResults.(analysisFnName)(missingClassResultsInd) = [];
        
        % convert to categorical in cells
        if iscellstr(analysisResults.(analysisFnName))
          analysisResults.(analysisFnName) = num2cell( categorical(analysisResults.(analysisFnName)) );
        end
      end
      
      % check against simIDs length
      if length(simIDs) > length(missingClassResultsInd)
        % add more missing indicies
        missingClassResultsInd(end+1: length(simIDs)) = true;
      end
      
      variedParamValues(missingClassResultsInd,:) = [];
      simIDs(missingClassResultsInd) = [];
    end % options.fillMissingResultsBool
    
    % Get class info
    classes = struct();
    for iFn = 1:numel(classifyFns)
      thisFnStr = classifyFns{iFn};
      
      % get name without ind
      classifyFnNameInd = regexpi(thisFnStr, '(\w+)(\d+)', 'tokens');
      classifyFnNameInd = [classifyFnNameInd{:}];
      
      % rename without index
      analysisResults.(classifyFnNameInd{1}) = analysisResults.(thisFnStr);
      analysisResults = rmfield(analysisResults, thisFnStr);
      thisFnStr = classifyFnNameInd{1};
      classifyFns{iFn} = thisFnStr;
      
      if numel(classifyFns) == 1 % rename class fn to 'class'
        analysisResults.class = analysisResults.(thisFnStr);
        analysisResults = rmfield(analysisResults, thisFnStr);
        thisFnHandle = str2func(thisFnStr);
        thisFnStr = 'class';
      else
        thisFnStr = classifyFns{iFn};
        thisFnHandle = str2func(thisFnStr);
      end

      % find unique classes
      uClassNames = categories([analysisResults.(thisFnStr){:}]);
      
      try % to get info from class fn call
        info = feval(thisFnHandle, 'info');
        
        if any(missingClassResultsInd) && options.fillMissingResultsBool
          assert(size(info, 1) >= length(uClassNames)-1, 'More classes than info for classes from classifcation function.');
        else
          assert(size(info, 1) >= length(uClassNames), 'More classes than info for classes from classifcation function.');
        end
        
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
      end % try
    end % classifyFns
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
      if contains(analysisFnName, 'class')
        axValInd = length(dynasimData.axis(1).axismeta.dataType);
        dynasimData.axis(1).axismeta.plotInfo{axValInd} = classes.(analysisFnName);
      end
    elseif iscellcategorical(analysisResults.(analysisFnName))
      dynasimData.axis(1).axismeta.dataType{end+1} = 'categorical';
      
      % store classes
      if contains(analysisFnName, 'class')
        axValInd = length(dynasimData.axis(1).axismeta.dataType);
        dynasimData.axis(1).axismeta.plotInfo{axValInd} = classes.(analysisFnName);
      end
    else
      dynasimData.axis(1).axismeta.dataType{end+1} = 'unknown';
    end
    
  end % analysisFnName
  
  % check results vs axis values
  nResults = numel(allResults);
  assert(all(cellfun(@numel, allAxisVals) == nResults), 'Results must be matched to corresponding parameter values.');
  
  % Import data table
  try
    dynasimData = dynasimData.importDataTable(allResults, allAxisVals, [{'analysisFn'} axisNames]);
  catch
    wprintf('Attempting to import overlapping entries. Setting overwriteBool=true to overwrite overlapping entries with the last duplicate entry.')
    dynasimData = dynasimData.importDataTable(allResults, allAxisVals, [{'analysisFn'} axisNames], true);
  end
  
  % Store axisType in axis
  dynasimData.axis(1).axismeta.axisType = 'dataType';
  
  % Store data
  hypercubeObj = gvArrayRef(dynasimData);
  modelObj.addHypercube(hypercubeObj);
  
  modelObj.vprintf('[gvModel] Imported multidimensional array object from Dynasim data from: %s\n', filePath)
  
  % Save
  if options.saveBool
    save(filePath, 'dynasimData') % save gvArray obj
    modelObj.vprintf('\tSaved dynasim data as ''gvArray'' object in file ''.\\gvArrayData.m''.\n')
  end
  
else % data file exists
  wprintf('File exists and overwriteBool=false. Choose new file name or set overwriteBool=true for new import.')
  modelObj.vprintf('[gvModel] Loading dynasim data from: %s\n', filePath)
  
  modelObj.load(filePath);
end


%% Nested Fns
  function  importVariedParamVals()
    modelObj.vprintf('[gvModel] Importing varied parameter values...\n')
    
    % Get varied params
    variedParamNames = vertcat(modNames{:});
    variedParamNames = unique(variedParamNames)';
    nVariedParams = numel(variedParamNames);
    
    % Get param values for each sim
    variedParamValues = cell(nMods, nVariedParams);
    for iParam = 1:nVariedParams
      thisParam = variedParamNames{iParam};
      
      try
        thisStudyinfoParamValue = studyinfoParams.(thisParam);
      catch
        thisStudyinfoParamValue = nan; % if state var initial val
      end
      
      for iSim = 1:nSims
        thisModParams = modNames{iSim};
        thisModInd = strcmp(thisModParams, thisParam);
        if any(thisModInd)
          variedParamValues{iSim, iParam} = modVals{iSim}{thisModInd};
        else  % param missing for this sim, so use the value from studyinfo (for sims with sparse vary, ie non lattice)
          variedParamValues{iSim, iParam} = thisStudyinfoParamValue;
        end
      end
    end
    
    %   for iParam = 1:nVariedParams
    %     VariedData.(variedParamNames{iParam}) = variedParamValues(:,iParam);
    %   end
    
    modelObj.vprintf('\tDone importing varied parameter values.\n')
  end


  function mods = arrows2underscores(mods)
    % Purpose: change arrow direction to 'target <- source' and convert to underscores
    mods(:,1:2) = cellfun( @fix_arrows, mods(:,1:2),'UniformOutput',0); % fix order of directionality to be L -> R
    mods(:,1:2) = cellfun( @(x) strrep(x,'<-','_'),mods(:,1:2),'UniformOutput',0); % replace modification arrows with _
    
    function obj = fix_arrows(obj)
      if any(strfind(obj,'->'))
        ind=strfind(obj,'->');
        obj=[obj(ind(1)+2:end) '<-' obj(1:ind(1)-1)];
      end
    end
  end

end % main fn
