function importDsData(modelObj, src, varargin)
% importDsData - import dynasim data
%
% src is a path to a dir or a mat file to save to.
%
% To pass arguments from top level run call:
%   gvr([], 'key',val)
%   gvRun([], 'key',val)
%   gv.Run([], 'key',val)
%   gvObj.load([], [], 'key',val) % Do not forget extra [] with load method!


%% Setup args
if nargin < 2
  src = modelObj.app.workingDir;
end

%% Check Options
options = checkOptions(varargin,{...
  'classifyFn', [], [],...
  'powerFn', @gvCalcPower, [],... % the function used to calculate the power
  'overwriteBool', 0, {0,1},... % whether overlapping table entries should be overwritten
  'identVarCombineBool', 1, {0,1},... % whether to combine varied parameters that are identically varied. If do so, probably cannot merge new sims later.
  'nonLatticeVarCombineBool', 0, {0,1},... % whether to combine varied parameters that are non-lattice. If do so, probably cannot merge new sims later.
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

%% -- Load or Make gvData --
if ~exist(filePath,'file') || options.overwriteBool
  % Import studyinfo data
  modelObj.vprintf('[gvModel] Importing studyinfo...\n')
  studyinfo = dsCheckStudyinfo(src);
  
  %% Varied Params
  studyinfoParams = studyinfo.base_model.parameters;
  studyinfoParamNames = fieldnames(studyinfoParams);
  
  
  % add state var initial conditions
  initialStateVars = cellfun(@(x) [x '_0_'], studyinfo.base_model.state_variables(:), 'uni',0);

  % vertcat initialStateVars with initialStateVars
  studyinfoParamNames = [studyinfoParamNames; initialStateVars];
  
  % collect modifications
  mods = {studyinfo.simulations.modifications};
  
  if isempty(mods{1})
    modelObj.vprintf('[gvModel] Attempted to import DS data with no vary \n');
    wprintf('\tGIMBL-Vis Only Supports DynaSim studies with multiple simulations (using ''vary'').');
    return
  end
  
  nSims = length(mods);
  
  % Standardize Modifications
  [mods, identicalMods, nonLatticeMods] = standardizeAllMods(mods);
  
  nIdentVarGroups = length(identicalMods);
  % strategy: merge var names
  
  nNonLatticeVarGroups = length(nonLatticeMods);
  % strategy: merge var names and var values, making the latter a string
  
  
  % Make names match params and expand mods that share namespace across params
  [modNames, modVals, missingRows] = expandModNamesVals(mods);
  nMods = sum(~missingRows); % update new nMods
  clear mods
  
  
  % make variedParamNames uniform accross mods and add values from studyinfo if missing for any sims
  [variedParamNames, variedParamValues] = importVariedParamVals(modNames, modVals);
  %   variedParamNames: a cellstring of just the unique modNames
  %   variedParamValues: a cell array for each mod, containing cells of the values of modVals
  
  
  % check/combine names of all ident rows, replacing the single row name from before
  [variedParamNames, variedParamValues] = identVarCombine(variedParamNames, variedParamValues);
  
  
  % check/combine names of all non lattice rows, replacing the single row name from before
  [variedParamNames, variedParamValues] = nonLatticeVarCombine(variedParamNames, variedParamValues);
  
  clear modNames modVals
  
  
  %% Results
  [analysisResults, analysisFlds, gvAnalysisLabels, classes] = importAnalysisResults();
  
  
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
  
  %% modelObj and hypercubeObj
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
  function [mods, identicalMods, nonLatticeMods] = standardizeAllMods(mods)
    for iSim = 1:nSims
      %change initial conditions (0) to _0_
      mods{iSim}(:,2) = strrep(mods{iSim}(:,2), '(0)', '_0_');
      
      % standardize and expand modifications
      [mods{iSim}, identicalMods, nonLatticeMods] = dsStandardizeModifications(mods{iSim}, studyinfo.base_model.specification);
      %   mods: standardized (right arrow if conn), expanded modifications. one var per line in cell array.
      %   identicalMods: cell array of indicies of which mods are identically
      %                  linked/covaried, where each cell is a diff linked set
      %                  2 ways to get this: either param matches multiple mechs,
      %                  or specified multiple mechs for 1 param
      %   nonLatticeMods: cell array of indicies of which mods are not identically
      %                   linked/covaried, where each cell is a diff linked set.
      %                   i.e., for non-lattice/non-Cartesian product.
    end % iSim
    
    % convert arrows2underscores
    mods = cellfunu(@arrows2underscores, mods); % fix arrow direction and convert to underscores  
  end % fn standardizeAllMods
  

  function [modNames, modVals, missingRows] = expandModNamesVals(mods)
    % expands vars that match multiple parameters if ~identVarCombineBool and removes missing vars
    
    % split mods cell array
    modVals = cellfunu(@(x) x(:,3), mods);
    modNames = cellfunu(@(x) x(:,1:2), mods);
    
    nMods = size(mods{1}, 1);
    
    for iSim = 1:nSims
      nRows = size(modNames{iSim}, 1);
      
      thisSimModNames = modNames{iSim};
      
      % NOTE: these may have diff nRows from thisSimModNames if not combining
      % covaried vars
      thisSimExpandedModNames = {};
      thisSimExpandedModVals = {};
      
      missingRows = false(1,nRows); % store which rows are missing
      
      for iRow = 1:nRows
        
        thisRowName = [thisSimModNames{iRow,1}, '_', thisSimModNames{iRow,2}]; % get original row names
        
        % replace periods with underscore in names
        thisRowName = strrep(thisRowName, '.','_');
        
        thisRowVal = modVals{iSim}{iRow};% get original row val
        
        if any(strcmp(thisRowName, studyinfoParamNames)) || options.includeMissingParam % if matches studyinfoParamNames
          thisSimExpandedModNames{end+1} = thisRowName;
          thisSimExpandedModVals{end+1} = thisRowVal;
        else % need to get full namespace
          regex = ['(' thisSimModNames{iRow,1}, '_.+_', thisSimModNames{iRow,2} ')']; % make re from original row names
          %         tokens = regexp(studyinfo.base_model.namespaces(:,2), re, 'tokens');
          tokens = regexp(studyinfoParamNames, regex, 'tokens');
          tokens = [tokens{:}]; % remove empty
          tokens = [tokens{:}];
          
          thisNrows = numel(tokens);
          
          if thisNrows == 0 % token name not found. likely didn't match so didn't do anything
            % skip it
            missingRows(iRow) = true;
            continue
          
          elseif thisNrows == 1 || options.identVarCombineBool % single token found or take first and combine names later
            thisRowName = tokens{1};
            thisSimExpandedModNames{end+1} = thisRowName;
            thisSimExpandedModVals{end+1} = thisRowVal;
            
            % Note: if thisNrows > 1 & options.identVarCombineBool, identVarCombine
            % will later combine all the var names and replace thisRowName with
            % that concat name
            
          else % mod affects multiple mechs and they are expanded here
            thisSimExpandedModNames(end+1:end+thisNrows) = tokens;
            thisSimExpandedModVals(end+1:end+thisNrows) = repmat({thisRowVal}, 1,thisNrows);
          end
        end
        
      end
      
      % update cells
      modNames{iSim} = thisSimExpandedModNames(:); % ensure col array
      modVals{iSim} = thisSimExpandedModVals(:); % ensure col array
    end
    
    if any(missingRows)
      wprintf('\tSome mechanisms are missing so those modifcations are not imported.');
      
      % reindex ident mod numbers since removing missing rows
      for iLinkMod = 1:nIdentVarGroups
        thisLinkedRows = identicalMods{iLinkMod};
        
        tempInds = false(1,nMods);
        tempInds(thisLinkedRows) = true;
        tempInds(missingRows) = [];
        
        identicalMods{iLinkMod} = find(tempInds);
        
        clear tempInds iLinkMod thisLinkedRows
      end
      
      % reindex nonLattice mod numbers since removing missing rows
      for iLinkMod = 1:nNonLatticeVarGroups
        thisLinkedRows = nonLatticeMods{iLinkMod};
        
        tempInds = false(1,nMods);
        tempInds(thisLinkedRows) = true;
        tempInds(missingRows) = [];
        
        nonLatticeMods{iLinkMod} = find(tempInds);
        
        clear tempInds iLinkMod thisLinkedRows
      end
    end % any(missingRows)
  end % fn expandModNamesVals


  function  [variedParamNames, variedParamValues] = importVariedParamVals(modNames, modVals)
    modelObj.vprintf('[gvModel] Importing varied parameter values...\n')
    
    % Get varied params
    variedParamNames = vertcat(modNames{:});
    variedParamNames = unique(variedParamNames)';
    nVariedParams = numel(variedParamNames);
    
    % Get param values for each sim
    variedParamValues = cell(nSims, nVariedParams);
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
  end % fn importVariedParamVals


  function [variedParamNames, variedParamValues] = identVarCombine(variedParamNames, variedParamValues)
    % check/combine names of all ident rows, replacing the single row name left from before
    
    if options.identVarCombineBool && (nIdentVarGroups > 0)
      for iLinkMod = 1:nIdentVarGroups
        thisLinkedRows = identicalMods{iLinkMod};
        
        thisLinkedModNames = modNames{1}(thisLinkedRows);
        thisCombName = strjoin(thisLinkedModNames, '-');
        
        [~, indVariedParamName] = intersect(variedParamNames, thisLinkedModNames);
        
        % the new index
        newInd = indVariedParamName(1);
        
        % indices to removex (to replace all others)
        removeInd = indVariedParamName(2:end);
        
        % change name to merged name
        variedParamNames{newInd} = thisCombName;
        
        % remove duplicates
        variedParamNames(removeInd) = [];
        variedParamValues(:, removeInd) = [];
      end
      
      % update val
      nVariedParams = numel(variedParamNames);
    end
  end % fn identVarCombine


  function [variedParamNames, variedParamValues] = nonLatticeVarCombine(variedParamNames, variedParamValues)
    % check/combine names and vals of all non lattice rows, replacing the single row name left from before
    % this is diff from identVarCombine fn since need to combine vals and
    % convert to string if they were numeric
    
    % variedParamValues = cell(nSims, nVariedParams);
    
    if options.nonLatticeVarCombineBool && (nIdentVarGroups > 0)
      for iLinkMod = 1:nNonLatticeVarGroups
        thisLinkedRows = nonLatticeMods{iLinkMod};
        
        thisLinkedModNames = modNames{1}(thisLinkedRows);
        thisCombName = strjoin(thisLinkedModNames, '-');
        
        [~, indVariedParamName] = intersect(variedParamNames, thisLinkedModNames);
        
        if length(indVariedParamName) < 2
          % was already combined in identVarCombineBool
          continue
        end
        
        % the new index (to replace all others)
        newInd = indVariedParamName(1);
        
        % indices to remove
        removeInd = indVariedParamName(2:end);
        
        % unique vals to combine
        vals2combine = variedParamValues(:, removeInd);

        % if multiple values, convert to char and cat
        if size(unique(cell2mat(vals2combine)','rows')', 2) > 1
          % cat rows as string representation and store in first column
          for iRow = 1:size(vals2combine,1)
            vals2combine{iRow,1} = sprintf('%g_', vals2combine{1,:});
            vals2combine{iRow,1}(end) = [];
          end
          
          % only keep first column
          vals2combine = vals2combine(:,1);
          
          variedParamValues(:, newInd) = vals2combine;
        end
        
        % change name to merged name
        variedParamNames{newInd} = thisCombName;
        
        % remove duplicates
        variedParamNames(removeInd) = [];
        variedParamValues(:, removeInd) = [];
      end
      
      % update val
      nVariedParams = numel(variedParamNames);
    end
  end % fn identVarCombine


  function [analysisResults, analysisFlds, gvAnalysisLabels, classes] = importAnalysisResults()
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
        funNamesS = struct(analysisFlds{1}, {funNamesS});
        prefixesS = struct(analysisFlds{1}, {prefixesS});
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
    if ~isempty(funNames)
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
    end
    
    
    simIDs = {studyinfo.simulations.sim_id}';
    
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
      
      
      % Deal with missing results
      analysisResults = reconcileMissingResults(analysisResults);
      
      
      % convert strings to categorical in cells
      for analysisFld = fieldnames(analysisResults)'
        analysisFld = analysisFld{1};
        
        if iscellstr(analysisResults.(analysisFld))
          analysisResults.(analysisFld) = num2cell( categorical(analysisResults.(analysisFld)) );
        end
      end
      
      
      % Get classifyFns info
      classes = getClassifyFnInfo();
    else
      classes = [];
      powerFnBool = false;
    end % if analysis results
    
    
    %% "importAnalysisResults" Nested Fns
    function analysisResults = reconcileMissingResults(analysisResults)
      % deal with missing results either by filling or removing
      
      % find result inds missing data
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
        
      else
        % ~options.fillMissingResultsBool so remove missing results
        
        for analysisFld = fieldnames(analysisResults)'
          analysisResults.(analysisFld{1})(missingAnyResultInd) = [];
        end
        
        % check against simIDs length
        if length(simIDs) > length(missingAnyResultInd)
          % add more missing indicies
          missingAnyResultInd(end+1: length(simIDs)) = true;
        end
        
        variedParamValues(missingAnyResultInd,:) = [];
        simIDs(missingAnyResultInd) = [];
      end % options.fillMissingResultsBool
    end % fn handleMissingData
    
    
    function classes = getClassifyFnInfo()
      classes = struct();
      
      for iClassifyFn = 1:numel(classifyFns)
        thisFnNum = classifyFnInds(iClassifyFn);
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
    end
  end % fn importAnalysisResults


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
  end % fn arrows2underscores

end % main fn
