This README file was generated on 2026-02-20 by Antoine ALLARD.

History:
- 2026-02-20: improve robustness of .txt file opening. edit of README to specify metadata required in .txt. Enable export txt of data compatible with JPK DP.
- 2026-03-13: correction to load data of size (n,m); add url link to paper and readme; add popup if unable to read data; fix pixel value.
- 2026-03-17: fix VarName problem with loading forces (use start time); add ROI for statistics; improve map and histo display with min and max as initial values
- 2026-09-24: fix opening of images larger than 200x200; clarify installation process in readme.

Remains to be done:
- check forces for data of size (n,m);
 
# GENERAL INFORMATION
 
## Dataset title: CellMAP: an open-source software tool to batch-process cell topography and elasticity maps collected by atomic force microscopy
 
## DOI: https://doi.org/10.1186/s12859-025-06060-0
## To cite this software: Allard, A., Liboz, M., Crépin, R. et al. CellMAP: an open-source software tool to batch-process cell topography and stiffness maps collected with an atomic force microscope. BMC Bioinformatics 26, 38 (2025). https://doi.org/10.1186/s12859-025-06060-0

 
## Contact email: antoine.allard@u-bordeaux.fr
 
 
# METHODOLOGICAL INFORMATION 
 
## System Requirements
- CellMAP requires MATLAB (R2020b or above), or Matlab Runtime, a freely accessible software that can be downloaded online. 
- To fasten loading of force curves, a free file archiver (such as 7-Zip) is recommended.

# Installation

## Option 1 — MATLAB App (recommended if you have MATLAB)

**Requirements:** MATLAB R2020b or newer.

1. Download `CellMAP.mltbx` from the [latest Release](https://github.com/AntoinePBAllard/CellMAP/tree/main/release).
2. Double-click the downloaded file.
3. MATLAB automatically detects whether this is an update and cleanly replaces any previous version — no manual uninstall needed.

> ⚠️ If you installed CellMAP before version 1.2 and now see two entries under *Add-Ons → Manage Add-Ons*, uninstall both, then reinstall the latest version. This cleanup is only needed once.

## Option 2 — Standalone version (no MATLAB license required)

**Requirements:** Windows only.

1. Download `CellMAP_installer.exe` from the [latest Release](https://github.com/AntoinePBAllard/CellMAP/tree/main/release/build).
2. Run the installer: it installs CellMAP and, if needed, the matching MATLAB Runtime automatically.

## Description of sources and methods used to collect and generate data:
- CellMAP is currently implemented to process AFM maps (*.txt files) and manipulate force curves (*.jpk-qi-data) that have been generated using a Nanowizard AFM (JPK-Bruker) and pre-processed using JPK Data Processing software tool.
 
# DATA & FILE OVERVIEW
 
## File hierarchy convention:
- Data should be organized as shown in the example folder “Test cells”. Within one master folder, create sub-folders for the different objects you want to merge (same cell line, same condition, etc.). While the presence of force curves is optional, each sub-folder should contain at least maps (*.txt).
- The .txt file should contain a header with at least the following lines:
	# channel:
	# start date:
For instance:
# channel: [3] Contact Point
# start date: Wed Nov 12 12:38:46 CET 2025
```

If force curves are provided, the **start date must match**.

---

## 3. Start a session

In CellMAP:

**File → New Session**

Select the master dataset folder.

CellMAP automatically loads:

* all subfolders
* AFM maps
* optional force curves

---

# Main Interface

The GUI contains several panels:

## Parameters

Select:

* Cell number
* Data type
* Processing stage

Examples of data types:

* Contact Point
* Young Modulus
* Indentation

---

## Mapping

Display 2D AFM maps with adjustable:

* color scale
* min/max limits
* spatial inspection

---

## Distribution

Histogram visualization with configurable:

* bin width
* limits
* normalization (`pdf`, `cdf`, etc.)

---

## Statistics

Provides:

* mean
* median
* standard deviation
* ROI statistics

---

## ROI Manager

ROI tools allow:

* selecting regions of interest
* computing local statistics
* comparing cell subregions

---

# Force Curve Analysis

When force curves are loaded, CellMAP can display:

* force-indentation curves
* local indentation
* spatially linked force measurements

Additional tools:

* inspect individual datapoints
* delete bad datapoints
* locate histogram bins on map

---

# Export Options

CellMAP supports:

## Session Export

Save current workflow:

```text
.dat
```

Reload later with:

```text
File → Load Session
```

---

## Pipeline Recording

Record all processing operations.

Useful for:

* reproducibility
* batch automation
* standardized analysis

---

## Data Export

Export processed data as:

```text
.txt
```

Compatible with external analysis tools.

---

# Performance Tips

For faster loading of force curves, install:

* 7-Zip
* or another external unzip utility

This can accelerate extraction by approximately **3×** compared to MATLAB’s internal unzip.

---

# Known Issues

* Force curve loading for some `(n,m)` datasets still requires validation.

---

# Changelog

## v1.2 (2026-06-22)

* Added ROI Manager

## v1.1

* Added ROI statistics
* Improved histogram display
* Fixed force loading issues

## v1.0

Initial release

---

# Contact

**Antoine Allard**
Université de Bordeaux
Email: [antoine.allard@u-bordeaux.fr](mailto:antoine.allard@u-bordeaux.fr)
