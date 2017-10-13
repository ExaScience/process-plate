#!/bin/bash

# Example run:
# ./generateCSV.sh /scratch/images 110000123456 /scratch/illum/110000123456 /scratch/csv

if [ $# -ne 4 ]; then
  echo "Usage: ./generateCSV.sg <platedir> <barcode> <illumdir> <outdir>: Process images for the plate in <platedir> with barcode <barcode>. Generate outout in <outdir>. CSV specifies <platedir> and <illumdir> as locations where images and illumination data are found when running cellprofiler."
  exit 2
fi

set -e

# save IFS
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

DIR=$(readlink -f "$1")
BARCODE=$2
ILLUMDIR=$3
OUTDIR=$(readlink -f $4)

# Make sure output directory exists
mkdir -p $OUTDIR

# Output CSV files
ILLUMCSV="$OUTDIR/illumination_$BARCODE.csv"
echo "\"PathName_OrigHoechst\",\"PathName_OrigAlexa568\",\"PathName_OrigCellMask\",\"FileName_OrigHoechst\",\"FileName_OrigAlexa568\",\"FileName_OrigCellMask\",\"Metadata_Barcode\",\"Metadata_Site\",\"Metadata_Well\",\"Metadata_WellColumn\",\"Metadata_WellRow\"" > $ILLUMCSV
ANALYSISCSV="$OUTDIR/analysis_$BARCODE.csv"
echo "\"PathName_IllumHoechst\",\"PathName_IllumAlexa568\",\"PathName_IllumCellMask\",\"PathName_OrigHoechst\",\"PathName_OrigAlexa568\",\"PathName_OrigCellMask\",\"FileName_IllumHoechst\",\"FileName_IllumAlexa568\",\"FileName_IllumCellMask\",\"FileName_OrigHoechst\",\"FileName_OrigAlexa568\",\"FileName_OrigCellMask\",\"Metadata_Barcode\",\"Metadata_Site\",\"Metadata_Well\",\"Metadata_WellColumn\",\"Metadata_WellRow\"" > $ANALYSISCSV


# Output error file
ERRORFILE="$OUTDIR/test_errors_$BARCODE.txt"
echo "Missing files" > $ERRORFILE

MISSING=0
TIME="T0001"
ACTIONC13="L01A01"
ACTIONC2="L01A02"
ZINDEX="Z01"
for ROW in A B C D E F G H I J K L M N O P ; do
  for COLUMN in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24; do
    for SITE in 001 002 ; do
      FILEMISSING=0

      CH1="${BARCODE}_${ROW}${COLUMN}_${TIME}F${SITE}${ACTIONC13}${ZINDEX}C01.tif"
      if [ ! -e "$DIR/$CH1" ] ; then let FILEMISSING+=1 ; fi

      CH2="${BARCODE}_${ROW}${COLUMN}_${TIME}F${SITE}${ACTIONC2}${ZINDEX}C02.tif"
      if [ ! -e "$DIR/$CH2" ] ; then let FILEMISSING+=1 ; fi

      CH3="${BARCODE}_${ROW}${COLUMN}_${TIME}F${SITE}${ACTIONC13}${ZINDEX}C03.tif"
      if [ ! -e "$DIR/$CH3" ] ; then let FILEMISSING+=1 ; fi

      if [ $FILEMISSING -ge 1 ] ; then
        echo "$FILEMISSING files missing for ${BARCODE}_${ROW}${COLUMN}" >> $ERRORFILE ; let MISSING+=$FILEMISSING ;
      else
        echo "\"$DIR\",\"$DIR\",\"$DIR\",\"$CH1\",\"$CH2\",\"$CH3\",\"$BARCODE\",\"${SITE}\",\"${ROW}${COLUMN}\",\"${COLUMN}\",\"${ROW}\"" >> $ILLUMCSV
        echo "\"$ILLUMDIR\",\"$ILLUMDIR\",\"$ILLUMDIR\",\"$DIR\",\"$DIR\",\"$DIR\",\"${BARCODE}_IllumHoechst.mat\",\"${BARCODE}_IllumAlexa568.mat\",\"${BARCODE}_IllumCellMask.mat\",\"${CH1}\",\"${CH2}\",\"${CH3}\",\"${BARCODE}\",\"${SITE}\",\"${ROW}${COLUMN}\",\"${COLUMN}\",\"${ROW}\"" >> $ANALYSISCSV
      fi
    done
  done
done

# restore $IFS
IFS=$SAVEIFS
