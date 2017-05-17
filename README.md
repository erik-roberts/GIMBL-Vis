![GIMBL-Vis](/docs/gvLogo.jpg)

## Introduction
GIMBL-Vis (GV) is an interactive multi-dimensional visualization toolbox.

Currently, it supports interaction with numeric or cell array data from the Matlab workspace or saved mat files, as well as with tabular data from saved spreadsheets. Imported data may already be in the form of high dimensional arrays, or converted from a 2D tabular form.

GV integrates with the [Dynasim](https://github.com/DynaSim/DynaSim) toolbox for modeling and simulating dynamical systems. Specifically, GV can be used to view the results from analysis functions, where each simulation is plotted as a point in a space spanned by combinations of the varied-parameter axes. Additionally, GV can simultaneously display previosuly-generated plots from Dynasim for the corresponding simulations.

### Concepts
GV uses a `gv` class. One calls the `gv` class constructor like a function, e.g. `obj = gv();`. This will create an object of the `gv` class. Creating this object is like opening an application on your computer, e.g. Matlab. It will open a new GV GUI window. At this point, one can continue using the Matlab command window to modify the application state (i.e. `gv` object state), or switch to interacting with the GUI window. Each `gv` object that is called will open a new GV GUI window with its own data store.

GV permits the loading, importing, and merging of different datasets into the same GV session. Each separate set of axes is called a `hypercube` in GV. For example, one may load data from a work project into one `hypercube`, and load completely different data from a personal project into another `hypercube`. One can 'merge' new data into a given `hypercube`. The first dimension of each `hypercube` is reserved for different datasets within the hypercube axes. For example, one dataset may be numerical, while another may be categorical strings. Data may be merged as a new dataset into the first dimension or into an existing entry of the first dimension to expand the other dimensions.

One can zoom in on a region of high dimensional space by taking a subset of a `hypercube`. This has the effect of changing the axis limits of the `hypercube`. One can `reset` the `hypercube` to return to the original limits. If one doesn't intend to restore the original limits, the excess data can be removed from memory with a `trim` operation.

## Installation and Usage Instructions:
To use GV:
- Download the zip file or clone the git repository
- Add the GIMBL-Vis folder to your matlab path
  - If you don't already have one, create a file named `startup.m` in the following folder:
    - If using Mac/Linux, use this folder: `<home folder>/Documents/MATLAB`
    - If using Windows, use this folder: `<home folder>\Documents\MATLAB`
  -Put the following in the `startup.m` file:
    - Add this line: `addpath(genpath(fullfile('your', 'custom', 'path', 'to', 'gimbl-vis')))` if your path to Dynasim is your/custom/path/to/dynasim.

To Use GV with Dynasim:
- Navigate to Dynasim output directory and call `gvRunDS`, or call `gvRunDS(output_dir_path)`.
  - for large simulations, this may take a few minutes
  - gvRunDS calls gvLoadDS, which creates a gvData.mat file in the output directory.
  - After creating this mat file, subsequent calls to gvRunDS should be instantaneous
- Plotting
  - Check the view boxes corresponding to dimensions to be viewed
  - At any time, the "Open Plot" button restores the plot panel
  - The sliders enable slicing through the remaining dimensions
  - All sliders can be moved with a mouse scroll wheel
  - With 1 or 2 variables being viewed, the sliders and value edit boxes are disabled since all of the correponding data is viewed, so slicing would not achieve anything.
  - Click "Make Legend" to see a legend
  - Values can be locked by checking the corresponding lock box
  - GV will automatically iterate through non-disabled sliders by clicking the iterate button
  - Time between iterations in seconds is set in the delay box
  - The plot markers can be manually resized by unchecking the autosize box and using the slider
  - The data cursor will display the exact values and SimID of a given selected marker
- Images
  - Dynasim images may be viewed by clicking the "Open Image" button
  - These images must be stored in the "output_dir/plots" directory
  - The available types of images will populate the dropdown menu
    - These different types are the prefixes of the various images
  - The images must have 'sim#' in the name for GV to find them
  - To view images, simply move the mouse over the plot markers in the plot panel. The corresponding image will be shown in the image panel.

## Implementation Details
Internally, `gv` objects store each `hypercube` dataset inside a field of the `mdData` structure property (i.e. object variable). The field name corresponds to the `hypercube` name. Each `hypercube` dataset is stored in a `gvArray`, which is a subclass of the MultiDimensional Dictionary ([MDD](https://github.com/davestanley/MultiDimensionalDictionary)) class. The default `MDDAxis` objects inside of `MDD` are replaced with a `gvArrayAxis` subclass for `gvArrays`.
