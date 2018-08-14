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
  src = modelObj.app.workingDir;
end

%% Check Options
options = checkOptions(varargin,{...
  'classifyFn', [], [],...
  'powerFn', @gvCalcPower, [],... % the function used to calculate the power
  'overwriteBool', 0, {0,1},... % whether overlapping table entries should be overwritten
  'covarySplitBool', 0, {0,1},... % whether to split varied parameters that affect multiple namespaces, if not probably cannot merge new sims later
  'fillMissingResultsBool', 1, {0,1},... % whether to fill missing results with nan or 'missing' category
  'includeMissingParam', 0, {0,1},... % whether to include missing parameters as dimensions
  'saveBool', 1, {0,1},... % whether to save gvArrayData
  },false);

if ischar(options.powerFn)
  options.powerFn = str2func(options.powerFn);
end

if ~isempty(options.classifyFn) && isa(options.classifyFn, 'function_handle')
  options.classifyFn = func2str(options.classifyFn);
end

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
  [analysisResults, ~, ~, funNamesS, prefixesS] = dsImportResults(src, 'import_scope','allResults', 'as_cell',0);
  % Note: analysisResults will have empty spots in cell array for missing sims
  
  if ~isempty(analysisResults)
    % Get analysis functions
    if isstruct(analysisResults)
      analysisFlds = fieldnames(analysisResults);
    else
      analysisFlds = {char(studyinfo.base_simulator_options.analysis_functions{1})};
      analysisResults = struct(analysisFlds{1}, {analysisResults});
    end
    
    % convert structs to cell
    funNames = struct2cell(funNamesS);
    prefixes = struct2cell(prefixesS);
    gvAnalysisLabels = analysisFlds;
    
    % make prefixes valid names
    prefixes = matlab.lang.makeValidName(prefixes);

    % replace result field name with prefixes that are not 'study' (i.e., the ds default)
    fieldInd2change = ~strcmp(prefixes, 'study');
    if any(fieldInd2change)
      nUniquePref = length(unique(prefixes(fieldInd2change)));
      if nUniquePref == sum(fieldInd2change) % only change if prefixes are unique
        gvAnalysisLabels(fieldInd2change) = prefixes(fieldInd2change);
      end
    end
    
    % remove 'dsResult_' prefix
    if ~all(fieldInd2change)
      gvAnalysisLabels = strrep(gvAnalysisLabels, 'dsResult_', '');
    end
    
    % Determine classification functions
    if ~isempty(options.classifyFn)
      classifyFns = options.classifyFn;
    elseif isempty(options.classifyFn) && ~isempty(analysisFlds)
      classifyFns = regexpi(funNames, '(.*class.*)', 'tokens');
      classifyFnInds = find(~cellfun(@isempty, classifyFns));
      classifyFns = [classifyFns{:}]; % remove empty
      if ~isempty(classifyFns)
        classifyFns = [classifyFns{:}]; % cat
      end
    end
  else
    analysisFlds = [];
    gvAnalysisLabels = [];
    funNames = [];
  end
  
  % remove power results
  powerResultInd = contains(funNames, func2str(options.powerFn) );
  if any(powerResultInd)
    analysisResults = rmfield(analysisResults, analysisFlds{powerResultInd});
    
    analysisFlds(powerResultInd) = [];
    gvAnalysisLabels(powerResultInd) = [];
    funNames(powerResultInd) = [];
    
    powerFnBool = true;
  else
    powerFnBool = false;
  end
  
  if ~isempty(analysisFlds)
    % Import analysis results
    modelObj.vprintf('[gvModel] Importing analysis results...\n')

    resultsUnequal = 0;
    
    for iFn = 1:numel(analysisFlds)
      thisFld = analysisFlds{iFn};

      if length( analysisResults.(thisFld) ) ~= size(variedParamValues,1)
        resultsUnequal = resultsUnequal + 1;
      end
    end

    if resultsUnequal ~= 0
      wprintf('\tDifferent lengths for number of modifications and %i results.', resultsUnequal)
    end
    
    modelObj.vprintf('\tDone importing analysis results\n')
    
    modelObj.vprintf('[gvModel] Preparing data to save...\n')
    
    
    % Fill missing data
    missingAnyResultInd = cellfun(@isempty,analysisResults.(thisFld)); % instantiate size
    for fld = fieldnames(analysisResults)'
      missingAnyResultInd = missingAnyResultInd | cellfun(@isempty,analysisResults.(fld{1}));
    end
    
    if options.fillMissingResultsBool
      for analysisFld = fieldnames(analysisResults)'
        analysisFld = analysisFld{1};
        
        missingThisResultInd = cellfun(@isempty,analysisResults.(analysisFld));
        
        % check against simIDs length (in case missing )
        if length(simIDs) > length(missingThisResultInd)
          % add more missing indicies
          missingThisResultInd(end+1: length(simIDs)) = true;
        end

        if any(missingThisResultInd)
          if iscellnum(analysisResults.(analysisFld)(~missingThisResultInd))
            % fill missing with nan
            analysisResults.(analysisFld)(missingThisResultInd) = {nan};
          elseif iscellstr(analysisResults.(analysisFld)(~missingThisResultInd))
            % fill missing with string
            analysisResults.(analysisFld)(missingThisResultInd) = {'missing'};
            
%             % convert to categorical in cells
%             analysisResults.(analysisFld) = num2cell( categorical(analysisResults.(analysisFld)) );
          elseif all( cellfun(@iscategorical, analysisResults.(analysisFld)(~missingThisResultInd)) )
            % fill missing with string
            analysisResults.(analysisFld)(missingThisResultInd) = {categorical(cellstr('missing'))};
          end
        end
      end
    else % ~options.fillMissingResultsBool
      for analysisFld = fieldnames(analysisResults)'
        analysisFld = analysisFld{1};
        
        analysisResults.(analysisFld)(missingAnyResultInd) = [];
      end
      
      % check against simIDs length
      if length(simIDs) > length(missingAnyResultInd)
        % add more missing indicies
        missingAnyResultInd(end+1: length(simIDs)) = true;
      end
      
      variedParamValues(missingAnyResultInd,:) = [];
      simIDs(missingAnyResultInd) = [];
    end % options.fillMissingResultsBool
    
    % convert strings to categorical in cells
    for analysisFld = fieldnames(analysisResults)'
      analysisFld = analysisFld{1};
      
      if iscellstr(analysisResults.(analysisFld))
        analysisResults.(analysisFld) = num2cell( categorical(analysisResults.(analysisFld)) );
      end
    end
    
    % Get class info
    classes = struct();
    for iFn = 1:numel(classifyFns)
      thisFnNum = classifyFnInds(iFn);
      thisFn = funNames{thisFnNum};
      thisFnFld = analysisFlds{thisFnNum};
      thisFnLabel = gvAnalysisLabels{thisFnNum};

      if numel(classifyFns) == 1 % rename class fn label to 'class'
        thisFnLabel = 'class';
        gvAnalysisLabels{thisFnNum} = thisFnLabel;
        thisFnHandle = str2func(thisFn);
      else
        thisFnHandle = str2func(thisFn);
      end

      % find unique classes
      uClassNames = categories([analysisResults.(thisFnFld){:}]);
      
      try % to get info from class fn call
        info = feval(thisFnHandle, 'info');
        
        if any(missingAnyResultInd) && options.fillMissingResultsBool
          assert(size(info, 1) >= length(uClassNames)-1, 'More classes than info for classes from classifcation function.');
        else
          assert(size(info, 1) >= length(uClassNames), 'More classes than info for classes from classifcation function.');
        end
        
        classes.(thisFnLabel).labels = info(:,1);
        if size(info, 2) > 1 % if color col
          tempColors = info(:,2); % as cells
          tempColors = vertcat(tempColors{:}); % convert cell 2 mat
          classes.(thisFnLabel).colors = tempColors; % store mat
          clear tempColors
        else
          classes.(thisFnLabel).colors = distinguishable_colors(length(classes.(thisFnLabel).labels));
        end
        
        if size(info, 2) > 2 % if marker col
          classes.(thisFnLabel).markers = info(:,3);
        end
      catch
        classes.(thisFnLabel).labels = uClassNames;
        classes.(thisFnLabel).colors = distinguishable_colors(length(classes.(thisFnLabel).labels));
      end % try
    end % classifyFns
  end % if analysis results
  
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
  
  nResultFns = length(fieldnames(analysisResults));

  for iResultFn = 1:nResultFns
    if iResultFn ~= nResultFns
      thisFnFld = analysisFlds{iResultFn};
      thisLabel = gvAnalysisLabels{iResultFn};
    else
      thisFnFld = 'simID';
      thisLabel = 'simID';
    end
    
    allResults = [allResults; analysisResults.(thisFnFld)];

    % Add Analysis Fn Name to allAxisVals
    fnNameCell = cell(nSims,1);
    fnNameCell(:) = deal({thisLabel});
    allAxisVals{1} = [allAxisVals{1}; fnNameCell];
    
    % Add rest of axes to allAxisVals
    for jCol = 1:length(axisVals)
      allAxisVals{jCol+1} = [allAxisVals{jCol+1}; axisVals{jCol}]; % TODO: speed up with vector ops
    end
    
    % store data types in axismeta
    if strcmp(thisFnFld, 'simID')
      dynasimData.axis(1).axismeta.dataType{end+1} = 'index';
    elseif iscellnum(analysisResults.(thisFnFld))
      dynasimData.axis(1).axismeta.dataType{end+1} = 'numeric';
    elseif iscellstr(analysisResults.(thisFnFld))
      dynasimData.axis(1).axismeta.dataType{end+1} = 'categorical';
      
      % store classes
      if contains(thisLabel, 'class')
        axValInd = length(dynasimData.axis(1).axismeta.dataType);
        dynasimData.axis(1).axismeta.plotInfo{axValInd} = classes.(thisLabel);
      end
    elseif iscellcategorical(analysisResults.(thisFnFld))
      dynasimData.axis(1).axismeta.dataType{end+1} = 'categorical';
      
      % store classes
      if contains(thisLabel, 'class')
        axValInd = length(dynasimData.axis(1).axismeta.dataType);
        dynasimData.axis(1).axismeta.plotInfo{axValInd} = classes.(thisLabel);
      end
    else
      dynasimData.axis(1).axismeta.dataType{end+1} = 'unknown';
    end
    
  end % analysisFld
  
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
  
  % Check for power
  if powerFnBool
    opts = struct2KeyValueCell(options);
    modelObj.importDsPower(varargin{:}, opts{:});
  end
  
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
        ind = strfind(obj,'->');
        obj = [obj(ind(1)+2:end) '<-' obj(1:ind(1)-1)];
      end
    end
  end

end % main fn
