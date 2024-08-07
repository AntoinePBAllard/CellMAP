README File --- General --- Version: 0.1 (2024-03-15) 
 
This README file was generated on 2024-03-15 by Antoine ALLARD.
Last updated: 2024-03-15.
 
# GENERAL INFORMATION
 
## Dataset title: CellMAP: an open-source software tool to batch-process cell topography and elasticity maps collected by atomic force microscopy
 
## DOI: TBD
 
## Contact email: antoine.allard [at] u-bordeaux.fr
 
 
# METHODOLOGICAL INFORMATION 
 
## System Requirements
- CellMAP requires MATLAB (R2020b or above), or Matlab Runtime, a freely accessible software that can be downloaded online. 
- Two types of installation are possible. 
	- For Matlab license owners, run it, click on Apps from the toolbar, “Install App” and select CellMAP.mlappinstall. After completion, a new icon called CellMAP will been added in the Apps list. 
	- For a Matlab license-free use of CellMAP, Matlab Runtime should be installed, and execute the standalone application CellMAP.exe.

## Description of sources and methods used to collect and generate data:
- CellMAP is currently implemented to process AFM maps (*.txt files) and manipulate force curves (*.jpk-qi-data) that have been generated using a Nanowizard AFM (JPK-Bruker) and pre-processed using JPK Data Processing software tool.
 
 
# DATA & FILE OVERVIEW
 
## File hierarchy convention:
- Data should be organized as shown in the example folder “Test files”. Within one master folder, create sub-folders for the different objects you want to merge (same cell line, same condition, etc.). While the presence of force curves is optional, each sub-folder should contain at least maps (*.txt).
 

## Methods for processing the data: 

# Import/Export
- Two options are available in the “File” menu: “New session” and “Load session”. The latter enables the user to reload a previous workflow. If for the first time, click on the “New session” item. Select the folder that contains the sub-folders you wish to analyze, organized as described above (see System Requirements). All sub-folders will also be loaded by the CellMAP (e.g. a dataset in which each sub-folder corresponds to a distinct cell). When force data are available (*.jpk-qi-data extension), a dialog box enables the user to load these force curves.
- After importation, the session starts and you will be able to work on the displayed data. At any time, you can “Export” your “Session” as it is. A *.dat file is saved and can be reloaded in CellMAP later (“File/Load session”). Another useful “Add-on” is the possibility to “Record” your “Pipeline”, which means that CellMAP will record all procedures applied to your current dataset. After completion, “Stop recording” saves this workflow, which can easily be loaded to process another dataset the exact same way. “Data” can be exported as *.txt files, which enables the user to work with processed data outside CellMAP. Files will be available in the working folder.

# Initial settings
- After completion of the loading step, available data are displayed in the “Parameters” panel (Figure 3). The following procedure is a first guide to handle raw data. AFM maps and their characteristics are automatically updated in the “Mapping”, “Distribution”, “Geometry” and “Statistics” panels. We here describe the use of the “Parameters” panel, which enables the user to select and visualize one dataset. All loaded cells are numbered and accessible using the spinner “Cell n°”. In the given example, at least two “Types of data” are available with the drop-down button (e.g. contact point, Young modulus). Their unit can be changed using the “Convert” button, allowing, for instance, the user to convert Young’s modulus from “kPa” to “Pa” (type “1e3” in the dialog box, 1kPa = 1×103 Pa). If force curves have been loaded, a new data called “Indentation” is available, hereafter denoted δmax (Figure 1). This quantity represents the maximal indentation measured.
- At this step, only “Raw” data are available in the “Process” drop-down button. This will be later updated (see Data
Processing). At any time, a “Cell”, “Type of data” or “Process” can be removed using the corresponding “Delete” button, upon validation to prevent misclicking.
- The following steps present how to the display data from AFM experiments (“Mapping” and “Distribution” panels, Figure 3). Unless specified explicitly, these does not affect data. Color scale of maps can be adjusted via the corresponding edit boxes. If no image is visible, the color bar might not be properly adjusted: values displayed in the “Statistics” panel, or the use of the histogram in the “Distribution” panel may guide the choice of appropriate parameters. Similarly, the settings of the displayed histogram is editable using “Bin width” and limit boxes. The “Hold color scale” and “Hold histogram limits” tick buttons enable keeping respectively the “Mapping” and “Distribution” parameters constant while browsing from one cell to another. If not selected, parameters will be adjusted automatically. Regarding these histograms, the type of “Normalization” can be specified, whose the names (i.e. pdf, cdf,...) are formally defined in Matlab online documentation (see Normalization properties from histogram function).
- “Data cursor” adds the option to display the value at a user-defined coordinate (x,y), as well as the horizontal and vertical line profiles around this point. Selection of this point can be changed using (i) the bottom and left sliders or (ii) the arrow from your keyboard (a click on the map might be needed). If previously loaded, the force-indentation curve at this space coordinate is shown in a separate window, which also contains the possibility to “Delete data point”: this removes permanently the corresponding data point. Lastly, we added the option (called “Find on the map”) to localise spatially all data points corresponding to a user-defined histogram bin: it is picked by (i) using the top slider or (ii) scrolling with the mouse.
