#!/bin/bash

if [ $# -ne 3 ]; then
  echo 1>&2 "Usage: $0 <platedir> <barcode> <outdir>: Normalize the plate in directory <platedir>. Generate outout in <outdir>"
  exit 2
fi

set -e

# set and export used variables
export PLATE_DIR=$(readlink -f $1)
export BARCODE=$2
OUTDIR=$(readlink -f $3)

# ensure output directory exists
mkdir -p $OUTDIR

# go to the dir where the fun happens...
CODEDIR=/CP/code
cd $CODEDIR

# creates the cache files in subdir profiling_params in <platedir>
echo ">>>>>> creating cache files"
python -m cpa.profiling.cache -r $PLATE_DIR

# create normalizations (output in same subdir as previous step)
echo ">>>>>> creating normalizations - dummy"
python -m cpa.profiling.normalization -m DummyNormalization ${PLATE_DIR} "Metadata_Well LIKE '_23'"
echo ">>>>>> creating normalizations - robustStd"
python -m cpa.profiling.normalization -m RobustStdNormalization ${PLATE_DIR} "Metadata_Well LIKE '_23'"


# create QC file
echo ">>>>>> creating QC file"
python -m cpa.profiling.query_image_table $PLATE_DIR "select Metadata_Barcode, Metadata_Well, sum(Metadata_isLowIntensity) as Metadata_isLowIntensity from _image_table group by Metadata_Barcode, Metadata_Well" -o $OUTDIR/${BARCODE}_qc.csv

# create profiles for DummyNormalization
echo ">>>>>> creating Dummy median"
python -m cpa.profiling.profile_mean --method=median --normalization=DummyNormalization --ignore_colmask -o $OUTDIR/${BARCODE}-dummy-median.csv -c -g $PLATE_DIR Well
echo ">>>>>> creating Dummy mean+deciles"
python -m cpa.profiling.profile_mean --method=mean+deciles --normalization=DummyNormalization --ignore_colmask -o $OUTDIR/${BARCODE}-dummy-mean+deciles.csv -c -g $PLATE_DIR Well

# create profiles for HC normalization
echo ">>>>>> creating HC std-median"
python -m cpa.profiling.profile_mean --method=median --normalization=RobustStdNormalization --ignore_colmask -o $OUTDIR/${BARCODE}-robust_std-median.csv -c -g $PLATE_DIR Well
echo ">>>>>> creating HC mean+deciles"
python -m cpa.profiling.profile_mean --method=mean+deciles --normalization=RobustStdNormalization --ignore_colmask -o $OUTDIR/${BARCODE}-robust_std-mean+deciles.csv -c -g $PLATE_DIR Well

echo ">>>>>> done"
