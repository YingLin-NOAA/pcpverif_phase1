#!/bin/ksh -x
# 
# If the image of NOHRSC 24h snow fall is not on the daily ConUS QPF vs. QPE, 
#   use this script to fetch it.  
#

# invoke .profile to set $ZROOT and load GrADS module, in case we are running 
# this script in cron.
. /u/Ying.Lin/.profile 

if [ $# -eq 0 ]; then  
  echo this script needs an argument, yyyymmdd 
else                  
  vday=$1
fi

vyyyy=`echo $vday | cut -c 1-4`
vyearmon=`echo $vday | cut -c 1-6`

# This script sends the North American and Global plots to RZDM daily page 
# by default, since the CPC analysis ending at 12:00 UTC first appears in 
# /dcom at 13:26 UTC the next day.  
# If there are more than one argument, and the 2nd argument is 'nosend', 
# then do not send the plots to EMCRZDM.


RZDMDIR=/home/www/emc/htdocs/mmb/ylin/pcpverif/daily

wrkdir=/stmpp1/Ying.Lin/nohrsc_img_rewget
if [ -d $wrkdir ]; then
  rm -f $wrkdir/*
else
  mkdir -p $wrkdir
fi

cd $wrkdir

wget https://www.nohrsc.noaa.gov/snowfall/data/$vyearmon/sfav2_CONUS_24h_${vday}12.png -O nohrsc_${vday}12_24h.png

err=$?

if [ $err -eq 0 ]; then 
  scp nohrsc_${vday}12_24h.png wd22yl@emcrzdm:$RZDMDIR/$vyyyy/${vday}/.
fi

exit
