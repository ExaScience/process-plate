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
```
	./Processplate.sh <platedir> <outdir>
```
where
* `<platedir>` holds the image files. The name is supposed to give the
plate's barcode.
* `<outdir>` is where the results will be saved.

CellProfiler: [http://cellprofiler.org](http://cellprofiler.org)
Note that we have used CellProfiler version 2.1.1. This can be installed trough Github but you need to fix a problem of the dependent files having been removed from the CellProfiler website.
To solve this we added a folder with the removed dependencies that you can use to fix the CellProfiler after checkout, for example as follows:
```
    git clone https://github.com/CellProfiler/CellProfiler.git
    git -C ./CellProfiler checkout -b 2.1.1 tags/2.1.1
    mkdir ./CellProfiler/dependencies
    cp CPdependencies/*.jar ./CellProfiler/dependencies
    cp CPdependencies/external_dependencies.py ./CellProfiler
```
CellProfiler by default runs Maven to install or update dependencies. Our scripts skip these updates (for reproducabiity and to save time) but it has to be run at least once to get everything going initially.
Therefore you need to run the following command at least once:
```
    python CellProfiler/CellProfiler.py --build-and-exit
```

