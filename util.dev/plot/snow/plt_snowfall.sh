#!/bin/sh
set -x
# Make 24h snowfall plots from 
#   1) NOHRSC snowfall analysis 
#   2) FV3GFS 00/12Z cycle runs (out to 96h)
#   3) FV3SARDA 00/12Z cycle runs out to 60hr
#   4) and 5) FV3SAR and FV3NEST 00 cycle runs out to 60hr

# optional argument: vday (yyyymmdd)
NDATE=/nwprod/util/exec/ndate
SCRIPT=/meso/save/Ying.Lin/pcpverif/nextjif/util.dev/plot/snow

if [ $# -eq 0 ]; then    
  today12z=`date -u +%Y%m%d`12
  vdate=`$NDATE -24 $today12z`
else                      
  vdate=${1}12
fi  

vmonth=${vdate:0:6}  # for wget nohrsc file
vday=${vdate:0:8}    # for wrkdir

wrkdir=/ptmpp1/Ying.Lin/plt_snowfall.$vday
if [ -d $wrkdir ]; then
  rm -f $wrkdir/*
else
  mkdir -p $wrkdir
fi

cd $wrkdir
# get NOHRSC 24h snowfall analysis, rename: 
wget -N https://www.nohrsc.noaa.gov/snowfall/data/${vmonth}/sfav2_CONUS_24h_${vdate}_grid184.grb2

if [ -s sfav2_CONUS_24h_${vdate}_grid184.grb2 ]; then 
  mv sfav2_CONUS_24h_${vdate}_grid184.grb2 nohrsc_asnow.$vdate.24h.grb2
  python $SCRIPT/plt_nohrsc_asnow.py nohrsc_asnow.$vdate.24h.grb2
fi

# Now plot model SNOD.  Cycle back for forecast hours of 24,36,48,60,72,84h
# (all valid at $vdate)


for fhr in 24 36 48 60 72 84 96 108 120 132 144 156 168 180
do
  # regional FV3 runs only go out to 60h; fv3nest/fv3sar run on 00Z cyc only:
  if [ $fhr -gt 60 ]; then
    models="fv3gfs"
  elif [ $fhr -eq 36 -o $fhr -eq 60 ]; then
    models="fv3gfs fv3nest fv3sar fv3sarda"
  else
    models="fv3gfs fv3sarda"
  fi
  let fhr0=fhr-24  # starting time of the 24h accumulation.

  #fv3gfs use 3-digit forecast hour in file name, regionals use 2-digits.
  chr_3=`printf "%0*d\n" 3 $fhr`
  chr0_3=`printf "%0*d\n" 3 $fhr0`
  chr_2=`printf "%0*d\n" 2 $fhr`
  chr0_2=`printf "%0*d\n" 2 $fhr0`


  modcycle=`$NDATE -$fhr $vdate`
  cycday=${modcycle:0:8}
  cyc=${modcycle:8:2}

  for model in $models 
  do
    #fv3gfs use 3-digit forecast hour in file name, regionals use 2-digits.
    if [ $model = fv3gfs ]; then
      PFX=/gpfs/dell1/nco/ops/com/gfs/para/gfs.${cycday}/${cyc}/gfs.t${cyc}z.pgrb2.0p25
      file1=${PFX}.f${chr0_3}
      file2=${PFX}.f${chr_3}
    else # regional models have similar dir path/file names. 
      if [ $model = fv3nest ]; then
        PFX=/gpfs/dell1/ptmp/Benjamin.Blake/com/fv3nest/para/fv3nest.${cycday}/${cyc}/fv3nest.t${cyc}z.conus
      elif [ $model = fv3sar ]; then
        PFX=/gpfs/dell1/ptmp/Benjamin.Blake/com/fv3sar/para/fv3sar.${cycday}/${cyc}/fv3sar.t${cyc}z.conus
      elif [ $model = fv3sarda ]; then
        PFX=/gpfs/dell2/ptmp/Eric.Rogers/com/fv3sar/para/fv3sar.${cycday}/${cyc}/fv3sar.t${cyc}z.conus
      fi

      file1=${PFX}.f${chr0_2}.grib2
      file2=${PFX}.f${chr_2}.grib2

    fi # set up file name for each model.  
    
    if [ -s $file1 -a -s $file2 ]; then
      python $SCRIPT/plt_model_snod.py $model $file1 $file2      
    fi
  done # make plot for each model
done   # make plot for each forecast hour (plot is for SNOD(fhr-fhr0)

exit

   



  
   
