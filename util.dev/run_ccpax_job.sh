#!/bin/sh
set -x
# this script needs to be in /bin/sh, otherwise the two ecf scripts below -
# even though they are in bsh - cannot find the command 'module' in 
# "module load prod_util".  
export ZROOT=/meso/save/Ying.Lin
export HOMEverf_precip=$ZROOT/pcpverif/v3.4.0
# Having trouble with the modules/copygb with verfgen_03h.  running them
# directly from cron.
$HOMEverf_precip/ecf/jverf_precip_verfgen_24h_new_ccpa.ecf
$HOMEverf_precip/ecf/jverf_precip_verfgen_03h_new_ccpa.ecf
# Rename the vsdb files/records to nam[gfs]ccpax:
$HOMEverf_precip/util.dev/rename_vsdb.ksh
# Compare CCPA/CCPAX/Stage IV 24h against 24h gauge amounts:
$HOMEverf_precip/scripts/g2p_verif.ksh
# Make CCPA/CCPAX/ST4 24h total vs. daily gauge scatter plot
$HOMEverf_precip/util.dev/python/run_pyplots.ksh
exit

