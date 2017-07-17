%% GIMBL-Vis Matlab Command Line Interface Tutorial
% This is a tutorial explaining the command line interface for GIMBL-Vis (using 
% the Matlab command window).
%
% For a tutorial on the easier-to-use graphical interface, see the slides at:
%   http://www.earoberts.com/GIMBL-Vis-Docs/slides.html


%% Setup

% Format
format compact

% Check if in gimbl-vis folder
if ~exist(fullfile('.','gvCommandLineTutorial.m'), 'file')
  error('Current folder should be the gimbl-vis folder in order to run this code block.')
end

% Add gv toolbox to Matlab path if needed
if ~exist('gv','class')
  addpath(genpath(pwd));
end

% Check for MDD toolbox
if ~exist('MDD','class')
  error('Download MDD toolbox: https://github.com/davestanley/MultiDimensionalDictionary');
end


%% Basics %%

%% Open GV GUI with empty model
% 3 ways:

% 1) Using constructor followed by method call
gvObj = gv;
gvObj.run();

% 2) Using static/class method
gv.Run; % or `gvObj = gv.Run;`

% 3) using constructor with simulataneous method call
gv().run % or `gvObj = gv().run;`

%% Object Construction

% Here is some sample data. The data has 3 dimensions.
vec = -9:1:10;
[x,y,z] = meshgrid(vec,vec,vec);
sampleData = x.*y.*z;
sampleData = cat(4,sampleData,sampleData);
sampleData = cat(4,sampleData,sampleData);
sampleData = cat(4,sampleData,sampleData);
sampleData = sampleData + 0.5*max(sampleData(:))*rand(size(sampleData));

% Here are some names for the dimensions.
axis_names = {'x','y','z','dataType'};

% Here are the names of the possible values for each dimension.
dataTypeAxisVals = cellfunu(@(x) ['dataType' x],mat2cellstr(1:size(sampleData,4)));
axis_vals = {1:20, 1:20, 1:20, dataTypeAxisVals};

% The name of the multidimensional dataset.
hypercubeName = 'sampleDataset';

% Let's import the same data and axis information.
sampleGvArray = gvArray(sampleData, axis_vals, axis_names);
sampleGvArray.meta.defaultHypercubeName = hypercubeName;

% Let's also store the path to some sample data stored on disk.
% gvFilePath = fullfile('.', 'gvSampleFile.mat');

% 4 ways to use the gv constructor method (ie the class name as a function):

%   1) Create empty gv object
gvObj = gv();
gvObj.summary;
clear gvObj


%   2) Call load method on file/dir. If dir, must have only 1 mat file. File can
%   store a gv, gvArray, or MDD object.
% gvObj = gv(gvFilePath);
% gvObj.summary;
% 
% gvObj = gv(gvFilePath, hypercubeName);
% gvObj.summary;


%   3) Call gvArray constructor on gvArray/MDD data
gvObj = gv(sampleGvArray);
gvObj.summary;
gvObj.printHypercubeList;
clear gvObj

gvObj = gv(hypercubeName, sampleGvArray);
gvObj.printHypercubeList;
clear gvObj

%   4) Call gvArray constructor on cell/numeric array data. Can be linear
%         or multidimensional array data.
gvObj = gv(sampleData);
gvObj.summary;
clear gvObj

gvObj = gv(hypercubeName, sampleData);
gvObj.summary;
clear gvObj

gvObj = gv(sampleData, axis_vals, axis_names);
gvObj.summary;
clear gvObj

gvObj = gv(hypercubeName, sampleData, axis_vals, axis_names);
gvObj.summary;

%% Run from file
% 2 ways to run directly from a file:
% gv(gvFilePath).run;

% gv.Run(gvFilePath);


%% Advanced %%

%% Command line control of GUI

% Switch tabs
gvObj.run();
gvObj.view.gui.selectTab(2);
gvObj.view.gui.selectTab('Main');

%% Dynasim Integration %%
