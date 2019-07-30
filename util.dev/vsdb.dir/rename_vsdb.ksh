#!/bin/ksh
set -x

if [ $# -eq 1 ]; then
  day=$1
else
  today=`date +%Y%m%d`
  day=`/nwprod/util/ush/finddate.sh $today d-8`
fi

olddir=/ptmpp1/Ying.Lin/verf.dat.v3.4.0/vsdb
newdir=/meso/save/Ying.Lin/vsdb.ccpax
tempestdir=/export-4/tempest/wd22yl/vsdb
for mod in nam gfs
do 
  if [ ! -d $newdir/$mod{ccpax} ]; then mkdir -p $newdir/${mod}ccpax ; fi
done

cd $olddir/nam
file=nam_${day}.vsdb
newfile=namccpax_${day}.vsdb
if [ -s $file ]; then
  cat $file | sed 's/NAM/NAMCCPAX/' > $newdir/namccpax/$newfile
  scp $newdir/namccpax/$newfile wd22yl@tempest:$tempestdir/namccpax/.
fi

cd $olddir/gfs
file=gfs_${day}.vsdb
newfile=gfsccpax_${day}.vsdb
if [ -s $file ]; then
  cat $file | sed 's/GFS/GFSCCPAX/' > $newdir/gfsccpax/$newfile
  scp $newdir/gfsccpax/$newfile wd22yl@tempest:$tempestdir/gfsccpax/.
fi

exit
