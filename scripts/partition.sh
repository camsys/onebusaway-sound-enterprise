#!/bin/bash

USER=prediction
PASSWORD=changeme
HOST=db-u.dev.wmata.obaweb.org
DBNAME=transitime
REST_TIME=0
#MYSQL="mysql --user=$USER --password=$PASSWORD --host=$HOST --tee /tmp/mysql.log
MYSQL="mysql --user=$USER --password=$PASSWORD --host=$HOST $DBNAME"
DAY_TYPE=day
REV_TYPE=rev
DUAL_REV_TYPE=drv
TABLES=(Predictions:day Matches:day AvlReports:day ArrivalsDepartures:day MonitoringEvents:day PredictionAccuracy:day VehicleEvents:day VehicleStates:day Blocks:rev Trips:rev Trip_scheduledTimesList:rev TripPatterns:rev StopPaths:rev StopPath_locations:rev TravelTimesForTrips:rev TravelTimesForStopPaths:rev Block_to_Trip_joinTable:drv)

function build_table()
{
  echo "alter table $1 partition by range (to_days($2)) ("

}

function newest_partition() 
{
  local TABLE=$1
  echo "$($MYSQL -e "show create table $TABLE\G" | grep -B 1 pmax | grep -v pmax | awk '{print $2}')"

}

function newest_partition_value()
{
  local TABLE=$1
  local P=$(newest_partition $TABLE)
  P=${P:1}
  echo "$P"
}

function oldest_partition() 
{
  local TABLE=$1
  # DEBUG MODE ON
  echo "$($MYSQL -e "show create table $TABLE\G" | grep -A 1 RANGE | grep -v RANGE | awk '{print $2}')"
}

function oldest_partition_value()
{
  local TABLE=$1
  local P=$(oldest_partition $TABLE)
  P=${P:1}
  echo "$P"
}
function current_config_rev()
{
  echo "$($MYSQL -q -s -e 'select configRev from ActiveRevisions;')"
}

function update_partition()
{
local TABLE=$1
local TYPE=$2

case $TYPE in
  $DAY_TYPE)
  local START=$(newest_partition_value "$TABLE")
  local INDEX=$(date -d "$START + 1 day" +%Y%m%d)
  # paritions should go out 30 days by default
  local NOW=$(date +%Y%m%d)
  local STOP=$(date -d "$NOW + 31 day" +%Y%m%d)
  local PARTITION_FUNCTION_PRE="(to_days('"
  local PARTITION_FUNCTION_POST="'))"
  ;;
  $REV_TYPE)
   local START=$(newest_partition_value "$TABLE")
   local INDEX=$(expr $START + 1)
   local STOP=$(current_config_rev)
   #partitions should go out 5 revs by default
   STOP=$(expr $STOP + 6)
   local PARTITION_FUNCTION_PRE="("
   local PARTITION_FUNCTION_POST=")"
   ;;
  $DUAL_REV_TYPE)
   local START=$(newest_partition_value "$TABLE")
   local INDEX=$(expr $START + 1)
   local STOP=$(current_config_rev)
   #partitions should go out 5 revs by default
   STOP=$(expr $STOP + 6)
   local PARTITION_FUNCTION_PRE="("
   local PARTITION_FUNCTION_POST=")"
   ;;
  *)
   echo "Unexpected type=$TYPE"
   exit 1;
   ;;
esac
echo "START=$START STOP=$STOP INDEX=$INDEX for TABLE=$TABLE TYPE=$TYPE"
if [ "$INDEX" -gt "$STOP" ]
then
  echo "ERROR:  current index $INDEX is greater than STOP $STOP"
  exit 1;
fi

while [ "$INDEX" -ne "$STOP" ]
do
  # DEBUG MODE ON
  echo "$TABLE reorganize $INDEX from $START to $STOP"
  if [ "$TYPE" == "$DUAL_REV_TYPE" ]
  then
    local IINDEX="$INDEX,$INDEX"
    local MAXVALUE="(MAXVALUE,MAXVALUE)"
    echo "IINDEX is $IINDEX"
    echo "stuff=$PARTITION_FUNCTION_PRE${IINDEX}$PARTITION_FUNCTION_POST"
  else
    local IINDEX="$INDEX"
    local MAXVALUE="MAXVALUE"
  fi
  $MYSQL <<EOF
  LOCK TABLES $TABLE WRITE;
  alter table $TABLE reorganize 
    partition pmax INTO ( 
      partition p$INDEX values less than $PARTITION_FUNCTION_PRE${IINDEX}$PARTITION_FUNCTION_POST ,
      partition pmax values less than $MAXVALUE
    );
  UNLOCK TABLES;
EOF
  case $TYPE in
  $DAY_TYPE)
    INDEX=$(date -d "$INDEX + 1 day" +%Y%m%d)
    ;;
  $REV_TYPE)
    INDEX=$(expr $INDEX + 1)
    ;;
  $DUAL_REV_TYPE)
    INDEX=$(expr $INDEX + 1)
    ;;
  esac
  echo "sleeping for $REST_TIME"
  sleep $REST_TIME
done
  echo "Done."
}

function update_all_partitions()
{
  for TABLE in "${TABLES[@]}"
  do
    # update_parition TABLE_NAME PARTITION_TYPE
    update_partition ${TABLE:0:`expr ${#TABLE} - 4`} ${TABLE:(-3)}
  done
}

function lookup_partition_by_range() {
local INDEX=$1
local TYPE=$2

case $TYPE in
  $DAY_TYPE)
    # MySQL to_days is days since 15821015 but need offset of 578101 to 
    # get to year 0 of pseudo calendar
    ##
    # I couldn't get this to work so I'm asking MySQL
    ##
    #local INDEX_TO_S=$(date -ud "$INDEX" +'%s')
    #local EPOCH=$(date -ud "15821015" +'%s')
    #local EPOCH_TO_S=$(date -ud "15821015 + 578101 day" +'%s')
    #local VALUE=$(( ( $INDEX_TO_S - $EPOCH_TO_S) /60/60/24 ))
    local VALUE="$($MYSQL -q -s -e 'select to_days('$INDEX');')"
    ;;
  $REV_TYPE)
    local VALUE=$INDEX
    ;;
  $DUAL_TYPE)
    local VALUE=$INDEX
    ;;
  *)
    echo "unexpected type in lookup partition=$TYPE with INDEX=$INDEX"
    exit 1;
    ;;
esac
  echo "$VALUE";
}

function prune_partition()
{
  local TABLE=$1
  local TYPE=$2

# in call cases below, we go from oldest to newest to
# keep the partitions sequential

case $TYPE in
  $DAY_TYPE)
  # prune paritions older than 90 days by default
  local START=$(oldest_partition_value "$TABLE")
  local INDEX=$(date -d "$START + 0 day" +%Y%m%d)
  local NOW=$(date +%Y%m%d)
  local STOP=$(date -d "$NOW - 90 day" +%Y%m%d)
  local PARTITION_FUNCTION_PRE="(to_days('"
  local PARTITION_FUNCTION_POST="'))"
  ;;
  $REV_TYPE)
   #partitions should only store last 5 config revs
   local START=$(oldest_partition_value "$TABLE")
   local INDEX=$(expr $START - 5)
   (( $INDEX < 0 )) && INDEX=0  # floor of 0
   (( $INDEX < $START)) && INDEX=$START # can't go past begining
   local STOP=$(current_config_rev)
   local PARTITION_FUNCTION_PRE="("
   local PARTITION_FUNCTION_POST=")"
   ;;
  $DUAL_REV_TYPE)
   #partitions should only store last 5 config revs
   local START=$(oldest_partition_value "$TABLE")
   local INDEX=$(expr $START - 5)
   (( $INDEX < 0 )) && INDEX=0  # floor of 0
   (( $INDEX < $START)) && INDEX=$START # can't go past begining
   local STOP=$(current_config_rev)
   local PARTITION_FUNCTION_PRE="("
   local PARTITION_FUNCTION_POST=")"
   ;;
  *)
   echo "Unexpected type=$TYPE"
   exit 1;
   ;;
esac
if [ "$INDEX" -gt "$STOP" ]
then
  echo "ERROR:  current index $INDEX is greater than STOP $STOP"
  exit 1;
fi

while [ "$INDEX" -ne "$STOP" ]
do
  # DEBUG MODE ON
  if [ "TYPE" == $DUAL_REV_TYPE ]
  then
    local IINDEX="$INDEX,$INDEX"
  else
    local IINDEX="$INDEX"
  fi
  echo "$TABLE prune $INDEX from $START to $STOP"
#  $MYSQL <<EOF
#  alter table $TABLE reorganize 
#    drop partition p$(lookup_partition_by_range $IINDEX $TYPE);
#EOF
  echo "alter table $TABLE drop partition p$IINDEX;"
  $MYSQL <<EOF
  alter table $TABLE 
    drop partition p$IINDEX;
EOF
  case $TYPE in
  $DAY_TYPE)
    INDEX=$(date -d "$INDEX + 1 day" +%Y%m%d)
    ;;
  $REV_TYPE)
    INDEX=$(expr $INDEX + 1)
    ;;
  $DUAL_REV_TYPE)
    INDEX=$(expr $INDEX + 1)
    ;;
  esac
  echo "sleeping for $REST_TIME"
  sleep $REST_TIME
done
  echo "Done."
  
}

function prune_all_partitions()
{
  for TABLE in "${TABLES[@]}"
  do
    # prune_parition TABLE_NAME PARTITION_TYPE
    prune_partition ${TABLE:0:`expr ${#TABLE} - 4`} ${TABLE:(-3)}
  done

}

function create_all_partitions()
{
# time
local TABLES=(Predictions Matches AvlReports ArrivalsDepartures)
local COLUMS=(avlTime avlTime time time)
local SQL=""

local ICOUNT=1
for TABLE in ${TABLES[@]}; do
  
# build table statement
  SQL=$(build_table $TABLE $COLUMNS[$ICOUNT])
# build p partions
  SQL="$SQL $(build_partitions $TABLE $START $END)"
# build p max
  SQL="$SQL $(build_pmax)"
# close statement
  SQL="$SQL );"
  echo "$SQL"
  let "icount += 1"
done

# configRev
# travelTimes

}

CMD=$1
echo "command = $CMD"

case $CMD in
"create")
  create_all_partitions "20151101" "20161231"
  ;;
"update")
  update_all_partitions
  ;;
"prune")
  prune_all_partitions
  ;;
*)
  echo "Unsupported command = $CMD"
  echo "usage $0 command [args]"
  echo "where command can be:"
  echo "  create    -- create the partitions"
  echo "  update    -- update existing partitions"
  echo "  prune     -- prune partitions"
  ;;
esac

