#!/bin/ksh
set -x
if [ $# -ge 1 ]; then
  day=$1
else
  day=`date -u +%Y%m%d`
fi

archdir=/meso/noscrub/Ying.Lin/cmcqpf.arch
if ! [ -d $archdir/$day ]; then
  mkdir -p $archdir/$day
fi

SITEGLB=http://dd.weather.gc.ca/model_gem_global/25km/grib2/lat_lon
SITERGL=http://dd.weather.gc.ca/model_gem_regional/10km/grib2
cd $archdir/$day

typeset -R3 -Z fhr

# Get global:
fhr=006
while [ $fhr -le 084 ]
do
  for cyc in 00 12
  do 
    glbfile=CMC_glb_APCP_SFC_0_latlon.24x.24_${day}${cyc}_P${fhr}.grib2
    wget -N $SITEGLB/$cyc/$fhr/$glbfile
    if [ -s $glbfile ]
    then 
     mv $glbfile cmcglb_${day}${cyc}.$fhr
     fi
  done
  let fhr=fhr+6
done

# Get regional:
fhr=006
while [ $fhr -le 048 ]
do
  for cyc in 00 12
  do 
    regfile=CMC_reg_APCP_SFC_0_ps10km_${day}${cyc}_P${fhr}.grib2
    wget -N $SITERGL/$cyc/$fhr/$regfile
    if [ -s $regfilefhr ]
    then
      mv $regfile cmc_${day}${cyc}.$fhr
    fi
  done
  let fhr=fhr+6
done

exit

