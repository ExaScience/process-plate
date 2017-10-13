# process-plate
## Example Unix bash script and pipeline to process a HCI plate

The script - ProcessPlate.sh - processes a directory with images from 
a HCI screen. This is done in a number of steps: 
* CSV files are generated to drive the actual processing.
* Illumination data is generated (used in the following step).
* Analysis is done: around 1400 features per cell are extracted.
* Normalization of the results.

The repository includes CellProfiler pipelines to do the illumination
and feature extraction.

You may want to adapt the generateCSV.sh auxiliary script to adapt
to the image filenames being used in your setup. For example, the script
currently expects images for a standard 384 well plate (wells A01 
to P24) and particular naming scheme.

To use: place the files at the root of your CellProfiler directory and 
call:
	./Processplate.sh <platedir> <outdir>
Where
* <platedir> holds the image files. The name is supposed to give the
plate's barcode.
* <outdir> is where the results will be saved.

CellProfiler: [http://cellprofiler.org](http://cellprofiler.org)
