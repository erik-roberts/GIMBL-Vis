# GIMBL-Vis

GIMBL-Vis (GV) is an interactive multi-dimension visualization toolbox. Currently, it can only view results data from Dynasim. Specifically, it will plot the classes from a classify analysis function on the varied parameter axes found from the SaveResults analysis function. Additionally, it can display any type of plot from dynasim for the corresponding simulations.

To use GV:
- Navigate to dynasim output directory and call `gvRunDS`, or call `gvRunDS(output_dir_path)`.
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
