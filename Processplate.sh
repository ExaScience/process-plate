#!/bin/bash

if [ $# -ne 2 ]; then
  echo 1>&2 "Usage: $0 <platedir> <outdir>: process the plate in directory <platedir>. Generate outout in <outdir>"
  exit 2
fi

PLATEDIR=$(readlink -f $1)
BASEOUT=$(readlink -f $2)

echo "Platedir: $PLATEDIR"
echo "Output: $BASEOUT"

BARCODE=`basename $PLATEDIR`

CSVDIR=$BASEOUT/csv
ILLUMDIR=$BASEOUT/illum
OUTPUTRAW=$BASEOUT/output_raw
OUTPUTNORMALIZED=$BASEOUT/output_normalized

rm -rf OUTPUTRAW

mkdir -p $CSVDIR
mkdir -p $ILLUMDIR
mkdir -p $OUTPUTRAW
mkdir -p $OUTPUTNORMALIZED

rm -rf /scratch/images
rm -rf /scratch/csv
rm -rf /scratch/illum
rm -rf /scratch/output_raw
rm -rf /scratch/output_normalized

ln -f -s $PLATEDIR /scratch/images
ln -f -s $CSVDIR /scratch/csv
ln -f -s $ILLUMDIR /scratch/illum
ln -f -s $OUTPUTRAW /scratch/output_raw
ln -f -s $OUTPUTNORMALIZED /scratch/output_normalized

CPARGS="-b --do-not-fetch -c -r --jvm-heap-size=2g"

#=============================================
# General Sanity Checks and Setup
#=============================================

# ensure images exist in /platedir
IMAGESEXIST=$(ls $PLATEDIR | wc -l)

if [ $? -gt 0 ]; then
    echo "Error accessing images directory. Did you specify the right volume for /platedir - exiting job"
    exit 1
fi

if [ "$IMAGESEXIST" -eq 0 ]; then
    echo "Error: no files in /platedir. Did you specify the right volume for /platedir? - exiting job"
    exit 2
fi

#=============================================
# Processing
#=============================================

# 0. generate CSV file for plate
echo "0 - Generating CSV file"
    . ./generateCSV.sh \
        /scratch/images \
        $BARCODE \
        /scratch/illum/$BARCODE \
        /scratch/csv

# 1. generate illumination data
echo "1 - Running Illumination Pipeline"
    python ./CellProfiler/CellProfiler.py $CPARGS \
        -p ./illum_loaddata_2.1.1.-janssen.cppipe \
        --data-file=/scratch/csv/illumination_$BARCODE.csv \
        -o /scratch/illum/$BARCODE

# 2. generate analysis output
echo "2 - Running Analysis Pipeline"
    python ./CellProfiler/CellProfiler.py $CPARGS \
        -p ./analysis_loaddata_2.1.1.-janssen.cppipe \
        --data-file=/scratch/csv/analysis_$BARCODE.csv \
        -o /scratch/output_raw/$BARCODE/process_1

# 3. generate normalized data
    . ./normalizePlate.sh \
        /scratch/output_raw/$BARCODE \
        $BARCODE \
        /scratch/output_normalized/$BARCODE

# Done
echo "Done at `date`"

