![GIMBL-Vis](/docs/gvLogo.jpg)

## Introduction
GIMBL-Vis (GV) is an extensible interactive multi-dimensional visualization toolbox.

Currently, it supports interaction with numeric or cell array data from the Matlab workspace or saved mat files, as well as with tabular data from saved spreadsheets of various formats. Imported data may already be in the form of high dimensional arrays, or converted from a 2D tabular form.

GV integrates with the [Dynasim](https://github.com/DynaSim/DynaSim) toolbox for modeling and simulating dynamical systems. Specifically, GV can be used to view the results from analysis functions, where each simulation is plotted as a point in a space spanned by combinations of the varied-parameter axes, by using the Plot plugin. Additionally, GV can simultaneously display previosuly-generated plots from Dynasim for the corresponding simulations using the Image plugin.

### Concepts
GV uses the `gv` class. One calls the `gv` class constructor like a function, e.g. `obj = gv();`. This will create an object of the `gv` class. Creating this object is like opening an application on your computer, e.g. Matlab. It will open a new GV GUI window. At this point, one can continue using the Matlab command window to modify the application state (i.e. `gv` object state), or switch to interacting with the GUI window. Each `gv` object that is called will open a new GV GUI window with its own data store.

GV permits the loading, importing, and merging of different datasets into the same GV session. Each separate set of axes is called a `hypercube` in GV. For example, one may load data from a work project into one `hypercube`, and load completely different data from a personal project into another `hypercube`. One can 'merge' new data into a given `hypercube`. The first dimension of each `hypercube` is reserved for different datasets within the hypercube axes. For example, one dataset may be numerical, while another may be categorical strings. Data may be merged as a new dataset into the first dimension or into an existing entry of the first dimension to expand the other dimensions.

Valid `hypercube` names are valid matlab field names: they must begin with a letter, and can contain letters, digits, and underscores. The maximum length of a `hypercube` name is the value that the `namelengthmax` function returns.

<!-- In future implementation:
One can zoom in on a region of high dimensional space by taking a subset of a `hypercube`. This has the effect of changing the axis limits of the `hypercube`. One can `reset` the `hypercube` to return to the original limits. If one doesn't intend to restore the original limits, the excess data can be removed from memory with a `trim` operation. -->

## Installation and Usage Instructions
To install and setup GV:
- Download the [zip file](https://github.com/erik-roberts/GIMBL-Vis/archive/master.zip) or clone the [git repository](https://github.com/erik-roberts/GIMBL-Vis.git) for GIMBL-Vis
- Do the same for the [MultiDimensional Dictionary (MDD)](https://github.com/davestanley/MultiDimensionalDictionary) class.
- Add the GIMBL-Vis and MDD folders to your matlab path
  - If you don't already have one, create a file named `startup.m` in the following folder:
    - If using Mac/Linux, use this folder: `<home folder>/Documents/MATLAB`
    - If using Windows, use this folder: `<home folder>\Documents\MATLAB`
  - Put the following line in the `startup.m` file: `addpath(genpath(fullfile('your', 'custom', 'path', 'to', 'GIMBL-Vis')))` if your path to GIMBL-Vis is "your/custom/path/to/GIMBL-Vis".

To Use GV:
- Plotting
  - Select panel
    - In the Select panel, check the view boxes corresponding to dimensions to be viewed
    - The sliders in the Select panel enable slicing through the remaining dimensions
    - All sliders can be moved with a mouse scroll wheel
    - With 1 or 2 variables being viewed, slicing will not change the current visualization since all of the correponding data is being viewed. However, it would affect the vis when more dimensions are added to the view
    - Values can be locked by checking the corresponding lock box
    - GV will automatically iterate through non-disabled sliders by clicking the iterate button
      - Time between iterations in seconds is set in the delay box
  - Plot panel
    - At any time, the "Open Plot Window" button in the Plot panel restores the plot window
    - Click "Make Legend" in the Plot panel to see a legend
    - The plot markers can be manually resized by unchecking the autosize box and using the slider
  - Plot Window
    - The data cursor will display the exact values and SimID of a given selected marker
    - With the focus on the plot window, option + left click on a point to set the corresponding sliders to that point
- Images
  - Dynasim images may be viewed by clicking the "Open Image Window" button
  - Enter the image directory (e.g., the DynaSim default is "./plots")
  - The available types of images will populate the dropdown menu
  - Use a regular expression to capture image prefixes and the simulation ID as an index
    - Try: `^([^_]*)_sim(\d+)__`
  - To view images, simply move the mouse over the plot markers in the plot window. The corresponding image will be shown in the image window.
  - To step through the types of images using the keyboard, make the image window the focus and click the "i" key. The image will update when the mouse moves over the plot window points again.

To Use GV with Dynasim:
 - Import DS data
   - Navigate to Dynasim output directory and call `gvr`, or call `gvr(output_dir_path)`. `gvr()` is an alias for `gv.Run()`.
   - Use the GV gui, click on "File > Import Multidimensional Data", and select the studyinfo.mat file

## Warnings to User
- Never call static/class methods (Uppercase methods) on objects--usually there is an equivalent object method (lowercase) that should be used instead. E.g. `gv.Run` and `obj=gv(); obj.run()` are fine. `obj=gv(); obj.Run()` should be avoided.

## Citation
If you use GIMBL-Vis for your published research, please cite this [poster](https://erik-roberts.github.io/GIMBL-Vis-Docs/poster.html) abstract:

Roberts EA, Kopell NJ. (2017) GIMBL-Vis: A GUI-Based Interactive Multidimensional Visualization Toolbox for Matlab. BMC Neuroscience 2017, 18(Suppl 1):P136.
