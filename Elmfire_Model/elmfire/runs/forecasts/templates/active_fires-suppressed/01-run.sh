#!/bin/bash

. ./99-post_funcs.sh --source-only

STARTSEC=`date +%s`

progress_message "Start"

LOCAL_SCRATCH=$(pwd)
ELMFIRE_VER=${ELMFIRE_VER:-2024.0831}
ELMFIRE_INSTALL_DIR=${ELMFIRE_INSTALL_DIR:-$ELMFIRE_BASE_DIR/build/linux/bin}
ELMFIRE=$ELMFIRE_INSTALL_DIR/elmfire_$ELMFIRE_VER
FIRE_NAME=`echo $LOCAL_SCRATCH | rev | cut -d/ -f1 | rev | cut -d_ -f1`
DATE_START=`echo $LOCAL_SCRATCH | rev | cut -d/ -f1 | rev | cut -d_ -f2`
TIME_START=`echo $LOCAL_SCRATCH | rev | cut -d/ -f1 | rev | cut -d_ -f3`
TIMESTAMP_START="${DATE_START}_${TIME_START}"
FORECAST_DIR=$ELMFIRE_BASE_DIR/runs/forecasts/runs/$FIRE_NAME/${FIRE_NAME}_$TIMESTAMP_START
mkdir -p $FORECAST_DIR 2> /dev/null

SOCKETS=`lscpu | grep 'Socket(s)' | cut -d: -f2 | xargs`
CORES_PER_SOCKET=`lscpu | grep 'Core(s) per socket' | cut -d: -f2 | xargs`
let "NP = SOCKETS * CORES_PER_SOCKET"
./98-set_adj.sh

progress_message "Launching ELMFIRE"
mpirun --mca btl tcp,self --map-by core --bind-to core --oversubscribe -np $NP $ELMFIRE elmfire.data >& elmfire.out

progress_message "ELMFIRE complete, starting postprocess routines"

ACRES_UNIQ=`tail -n +2 fire_size_stats.csv | cut -d, -f7 | sort | uniq | wc -l`
if [ "$ACRES_UNIQ" -gt 1 ]; then
   ./02-postprocess.sh >& log_postprocess.txt
   #./04-smoke.sh >& log_smoke.txt
   progress_message "Postprocessing complete, cleaning up"
else
   progress_message "No non-zero fire sizes to post process"
fi

rm -f *.bsq *.hdr *.aux.xml crown-fire*.tif flame-length*.tif hours-since-burned*.tif spread-rate*.tif

cp -f -r * $FORECAST_DIR
cd $FORECAST_DIR
tar -cf ${FIRE_NAME}_$TIMESTAMP_START.tar ./* && mv ${FIRE_NAME}_$TIMESTAMP_START.tar $CLOUDFIRE_BASE_DIR/microservices/elmfire/srv/

rm -f -r $LOCAL_SCRATCH

ENDSEC=`date +%s`
let "RUNTIME = ENDSEC - STARTSEC"
echo "Wall clock time:  $RUNTIME s"
progress_message "ELMFIRE run is complete"

exit 0
