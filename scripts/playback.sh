#!/bin/bash -x

USER=prediction
PASSWORD=changeme
HOST=db.dev.wmata.obaweb.org
DBNAME=transitime
GTFS_SERVER=admin.prod.wmata.obaweb.org:8080
FEED=http://${GTFS_SERVER}/api/bundle/staged/list
TRACE_DIR=/opt/transitime/trace
mkdir $TRACE_DIR
RAW_GTFS_DIR=/opt/transitime/raw_gtfs
mkdir $RAW_GTFS_DIR
TRACE_GTFS_DIR=/opt/transitime/trace_gtfs
mkdir $TRACE_GTFS_DIR
TRANSFORM_JARFILE=/opt/transitime/core/onebusaway-gtfs-transformer-cli-1.3.6.jar
if [ ! -f $TRANSORM_JARFILE ]
then
  wget http://developer.onebusaway.org/nexus/content/groups/public/org/onebusaway/onebusaway-gtfs-transformer-cli/1.3.6/onebusaway-gtfs-transformer-cli-1.3.6.jar -O $TRANSFORM_JARFILE
fi

CMD=$1

function create_csv() {
START=$1
END=$2
VEHICLE=$3

echo "$START $END $VEHICLE"
mysql --batch --user=$USER --password=$PASSWORD --host=$HOST $DBNAME >$TRACE_DIR/trace.csv <<EOF 
select 
  vehicleId, 
  time, 
  assignmentId, 
  assignmentType, 
  heading, 
  lat as latitude, 
  lon as longitude  
from 
  AvlReports  
where 
  time between "$START" and "$END"  
  and vehicleId="$VEHICLE";
EOF

}

function download_gtfs() {
cd $RAW_GTFS_DIR
rm -rf *.txt
for AGENCY in 1
do
  FEED_FILE=${RAW_GTFS_DIR}/${AGENCY}_latest.txt
  LATEST=`wget -q ${FEED} -O ${FEED_FILE}`
  DATASET_ID=`cat ${FEED_FILE}  | sed -e 's!{!!g' -e 's!}!\n!g' -e 's!\[!\n!g' -e 's!\]!\n!g' -e 's!,!\n!g' | grep '"id"' | awk -F: '{print $2}' | sed -e 's!"!!g'`
  FILENAME=`wget -q -O - http://${GTFS_SERVER}/api/bundle/archive/list-by-id/${DATASET_ID} | sed -e 's!,!\n!g' | grep outputs/final/${AGENCY}_ | grep -v outputs/outputs | sed -e 's!"!!g'`
  wget -q http://${GTFS_SERVER}/api/bundle/archive/get-by-id/${DATASET_ID}/${FILENAME} -O ${AGENCY}_gtfs.zip;
  unzip ${AGENCY}_gtfs.zip || exit 1;
done
}
function retain_block() {
BLOCKID=$1
  java \
  -jar \
  $TRANSFORM_JARFILE \
  --transform='{"op":"retain", "match":{"file":"trips.txt", "block_id":"'$BLOCKID'"}}' \
  $RAW_GTFS_DIR $TRACE_GTFS_DIR
}

function playback() {
  java \
  -Dtransitime.core.agencyId=1 \
  -Dtransitime.db.dbName=transitime \
  -Dtransitime.core.maxPredictionTimeForDbSecs=3600 \
  -Dtransitime.core.matchHistoryMaxSize=40 \
  -Dtransitime.avl.maxSpeed=45 \
  -Dtransitime.avl.allowableNoAvl=10 \
  -Dtransitime.logging.dir="/opt/transitime/logs" \
  -Dlogback.configuration=/opt/transitime/core/logback.xml \
  org.transitime.avl.PlaybackModule $TRACE_GTFS_DIR $TRACE_DIR \
  -jar \
  /home/dev/src/wmata/transitime-sheldonabrown/transitime/target/playback.jar
}

case $CMD in
"csv")
  create_csv "$2" "$3" "$4"
  ;;
"gtfs")
  download_gtfs
  retain_block "$2"
  ;;
"playback")
  playback
  ;;
*)
  echo "usage $0 command [args]"
  echo "where command can be:"
  echo "  csv startDate endDate vehicleId -- create csv from db"
  echo "  gtfs block_id - trim the relevant GTFS"
  ;;
esac