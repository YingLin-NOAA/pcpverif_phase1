#!/bin/ksh
set -x
# This is for testing an verification implementation parallel (not model para -
# which would be in regular VSDB repository on tempest).  
#
# Argument for this script:  $day1, $day2
# 
# 1) Go to /com/verf/para/vsdb/precip, copy over all VSDBs for $day1 - $day2
#    to working directory,
#    rename model/model_$day.vsdb to modelv/modelv_$day.vsdb
# 2) Copy over prod VSDBs for $day1 - $day2 to working directory
#
if [ $# -ne 2 ]; then
  echo script needs two arguments, day1 day2
  exit
fi
day1=$1
day2=$2
paravsdb=/com/verf/para/vsdb/precip
prodvsdb=/com/verf/prod/vsdb/precip

wrkdir=/stmpp1/Ying.Lin/vsdb.compare
if [ -d $wrkdir ]; then
  cd $wrkdir
  rm -rf *
else
  mkdir $wrkdir
fi

cd $paravsdb
for model in `ls -1`
do
  # Make a directory (with a 'v' appended to the model name) if VSDB for
  # day2 exists.  This is to avoid creating a lot of empty subdirectories
  # for obsolete models lingering on /com/verf/prod[para]/vsdb/precip.
  # We're checking for the existence of day2 vsdb instead of day1, in case
  # there was a problem earlier on in either prod or para that got fixed
  # later.  E.g., for v3.5.0, cmc/cmcglb QPF files were missing for some
  # days on /dcom and got fixed later. 
  if [ -s $paravsdb/$model/${model}_${day2}.vsdb ]; then
    mkdir $wrkdir/${model}v
    cd $paravsdb/$model
  else
    continue  # not a directory. Skip to the next model.  
  fi

  MODEL=`echo $model | tr a-z A-Z`
  day=$day1
  while [ $day -le $day2 ]
  do 
    vsdbfile=${model}_$day.vsdb
    if [ -s $vsdbfile ]; then
      newvsdbfile=${model}v_$day.vsdb
      sed 's/'$MODEL'/'$MODEL'V/g' $vsdbfile > $wrkdir/${model}v/$newvsdbfile
    fi
    day=`/nwprod/util/ush/finddate.sh $day d+1` 
  done
done

# Now simply copy over prod vsdbs:
cd $prodvsdb
for model in `ls -1`
do
  if [ -s $prodvsdb/$model/${model}_${day2}.vsdb ]; then
    mkdir $wrkdir/${model}
    cd $prodvsdb/$model
  else
    continue  # not a directory. Skip to the next model.  
  fi

  day=$day1
  while [ $day -le $day2 ]
  do 
    vsdbfile=${model}_$day.vsdb
    if [ -s $vsdbfile ]; then
      cp $vsdbfile $wrkdir/${model}/.
    fi
    day=`/nwprod/util/ush/finddate.sh $day d+1` 
  done
done

exit
 
 
