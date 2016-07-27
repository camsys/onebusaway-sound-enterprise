#!/bin/bash

#USER=prediction
#PASSWORD=changeme
#HOST=db-u.dev.wmata.obaweb.org
#DBNAME=transitime

USER=root
PASSWORD=changeme
HOST=localhost
DBNAME=transitime

PARTITION_START_DAY="20151010"
REST_TIME=0
#MYSQL="mysql --user=$USER --password=$PASSWORD --host=$HOST --tee /tmp/mysql.log
MYSQL="mysql --user=$USER --password=$PASSWORD --host=$HOST $DBNAME"
DAY_TYPE=day
REV_TYPE=rev
DUAL_REV_TYPE=drv
# array of tables
TABLES=(Predictions Matches AvlReports ArrivalsDepartures MonitoringEvents PredictionAccuracy VehicleEvents VehicleStates Blocks StopPaths StopPath_locations TravelTimesForTrips TravelTimesForStopPaths TripPatterns Trips Block_to_Trip_joinTable Trip_scheduledTimesList )
# MAP of TABLE to Partition TYPE
declare -A TYPE_MAP=( ["Predictions"]="day" ["Matches"]="day" ["AvlReports"]="day" ["ArrivalsDepartures"]="day" ["MonitoringEvents"]="day" ["PredictionAccuracy"]="day" ["VehicleEvents"]="day" ["VehicleStates"]="day" ["Blocks"]="rev" ["Trips"]="rev" ["Trip_scheduledTimesList"]="rev" ["TripPatterns"]="rev" ["StopPaths"]="rev" ["StopPath_locations"]="rev" ["TravelTimesForTrips"]="rev" ["TravelTimesForStopPaths"]="rev" ["Block_to_Trip_joinTable"]="drv")
# MAP of TABLE to Partition COLUMN
declare -A COLUMN_MAP=( ["Predictions"]="avlTime" ["Matches"]="avlTime" ["AvlReports"]="time" ["ArrivalsDepartures"]="time" ["MonitoringEvents"]="time" ["PredictionAccuracy"]="arrivalDepartureTime" ["VehicleEvents"]="time" ["VehicleStates"]="avlTime" ["Blocks"]="configRev" ["Trips"]="configRev" ["Trip_scheduledTimesList"]="Trip_configRev" ["TripPatterns"]="configRev" ["StopPaths"]="configRev" ["StopPaths"]="configRev" ["StopPath_locations"]="StopPath_configRev" ["TravelTimesForTrips"]="configRev" ["TravelTimesForStopPaths"]="configRev" ["Block_to_Trip_joinTable"]="Blocks_configRev,trips_configRev" )
# MAP of TABLE to PRIMARY_KEY changes
declare -A PRIMARY_KEY_MAP=( ["Predictions"]="id, avlTime" ["PredictionAccuracy"]="id, arrivalDepartureTime" ["Block_to_Trip_joinTable"]="Blocks_serviceId,Blocks_configRev,Blocks_blockId,listIndex, trips_configRev" ["TravelTimesForTrips"]="id, configRev" ["TravelTimesForStopPaths"]="id, configRev" )
# MAP of TABLE to CONSTRAINTS that need dropping
declare -A CONSTRAINT_MAP=( ["Blocks"]="Block_to_Trip_joinTable" ["Trips"]="Block_to_Trip_joinTable:TravelTimesForTrips:TripPatterns:Trip_scheduledTimesList" ["TripPatterns"]="Trips:TripPattern_to_Path_joinTable" ["TravelTimesForTrips"]="Trips:TravelTimesForTrip_to_TravelTimesForPath_joinTable" ["StopPaths"]="TripPattern_to_Path_joinTable:StopPath_locations" ["TravelTimesForStopPaths"]="TravelTimesForTrip_to_TravelTimesForPath_joinTable" )
# MAP of TABLE to FOREIGN_KEY columns that need dropping
declare -A FOREIGN_MAP=( ["Block_to_Trip_joinTable"]="FK_abaj8ke6oh4imbbgnaercsowo" )

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
  NUMBER_REGEX='^[0-9]+$'
  if ! [[ $P =~ $NUMBER_REGEX ]]
  then
    echo "1"
  else
    echo "$P"
  fi
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
  $REV_TYPE |  $DUAL_REV_TYPE)
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
  (( $? != 0 )) && exit 1
  case $TYPE in
  $DAY_TYPE)
    INDEX=$(date -d "$INDEX + 1 day" +%Y%m%d)
    ;;
  $REV_TYPE | $DUAL_REV_TYPE)
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
    update_partition ${TABLE} "${TYPE_MAP[$TABLE]}"
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
    # would not work locally so asking MySQL
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
  $REV_TYPE | $DUAL_REV_TYPE)
   #partitions should only store last 5 config revs
   local START=$(oldest_partition_value "$TABLE")
   local INDEX=$(expr $START - 5)
   (( $INDEX < 0 )) && INDEX=0  # floor of 0
   (( $INDEX < $START)) && INDEX=$START # cannot go past begining
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
  echo "alter table $TABLE drop partition p$IINDEX;"
  $MYSQL <<EOF
  alter table $TABLE 
    drop partition p$IINDEX;
EOF
  (( $? != 0 )) && exit 1
  case $TYPE in
  $DAY_TYPE)
    INDEX=$(date -d "$INDEX + 1 day" +%Y%m%d)
    ;;
  $REV_TYPE | $DUAL_REV_TYPE)
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
    prune_partition ${TABLE} ${TYPE_MAP[$TABLE]}
  done

}

function add_drop_primary_key()
{
if [ -z "$2" ]
then
  echo "No KEY variable defined for $TABLE, exiting add_drop_primary_key"
  return
fi
local TABLE=$1
local KEY=$2
  echo "add_drop $TABLE $KEY"

  $MYSQL <<EOF
alter table $TABLE drop primary key, add primary key($KEY);
EOF
  (($? != 0)) && exit 1


}

function find_constraint_name()
{
local TABLE=$1
local REFERENCED_TABLE=$2

  echo "$($MYSQL -q -s -e 'select distinct constraint_name from information_schema.key_column_usage where table_name="'$TABLE'" and referenced_table_name="'$REFERENCED_TABLE'";')"

}

function drop_foreign_key() 
{
if [ -z "$1" ]
then
  echo "missing TABLE for drop_foreign_key"
  return
fi
if [ -z "$2" ]
then
  echo "missing FOREIGN_KEY for drop_foreign_key on table $1"
  return
fi

local FOREIGN_KEY="$2"

local KEY_FOUND="$($MYSQL -e "show create table $TABLE\G" | grep -ic "$FOREIGN_KEY")"

if [ "$KEY_FOUND" -eq 0 ]
then
  echo "key $FOREIGN_KEY no longer exists on table $TABLE: $KEY_FOUND"
  return
fi

echo "dropping $FOREIGN_KEY on $TABLE"

$MYSQL <<EOF
alter table $TABLE drop key $FOREIGN_KEY;
EOF
(($? != 0)) && exit 1

}


function drop_constraint_recursive()
{
if [ -z "$1" ]
then
  echo "missing TABLE for drop_constraint"
  return
fi
if [ -z "$2" ]
then
  echo "missing REFERENCED_TABLE for drop_constraint on table $1"
  return
fi

local DELIMITER=$(expr index "$1" :)
if [ $DELIMITER -gt 0 ]
then
# we have a list, recurse
  drop_constraint ${1%%:*} $2
  drop_constraint_recursive ${1#*:} $2
else
  drop_constraint $1 $2
fi

}
function drop_constraint()
{
local TABLE=$1
local REFERENCED_TABLE=$2

local CONSTRAINT_NAME=$(find_constraint_name $TABLE $REFERENCED_TABLE)
echo "CONSTRAINT_NAME=$CONSTRAINT_NAME"

if [ -z "$CONSTRAINT_NAME" ]
then
  echo "no constraints for $TABLE"
  return
fi

if [ -n "${FOREIGN_MAP[$TABLE]}" ]
then
  echo "$(drop_foreign_key $TABLE "${FOREIGN_MAP[$TABLE]}")"
fi

local CONSTRAINT_FOUND="$($MYSQL -q -s -e 'select constraint_name from information_schema.key_column_usage where table_name = "'$TABLE'" and table_schema="'$DBNAME'"\G' | grep -ic $CONSTRAINT_NAME)"

if [ "$CONSTRAINT_FOUND" -eq 0 ]
then
  echo "constraint $CONSTRAINT_NAME no longer exists on table $TABLE: $CONSTRAINT_FOUND"
  return
fi

echo "dropping constraint $CONSTRAINT_NAME on $TABLE referencing $REFERENCED_TABLE"

$MYSQL <<EOF
alter table $TABLE drop foreign key $CONSTRAINT_NAME;
EOF
(($? != 0)) && exit 1
}

function create_partition_range()
{
local TABLE=$1
local TYPE=$2
local ALTER_SQL=""
local PMAX_SQL=""
local SQL=""

case $TYPE in
  $DAY_TYPE)
  local START=$PARTITION_START_DAY
  local INDEX=$START
  # paritions should go out 30 days by default
  local NOW=$(date +%Y%m%d)
  local STOP=$(date -d "$NOW + 31 day" +%Y%m%d)
  local RANGE_FUNCTION_PRE="(to_days("
  local RANGE_FUNCTION_POST="))"
  local PARTITION_FUNCTION_PRE="(to_days('"
  local PARTITION_FUNCTION_POST="'))"
  ;;
  $REV_TYPE)
   local START=0
   local INDEX=$START
   local STOP=$(current_config_rev)
   #partitions should go out 5 revs by default
   STOP=$(expr $STOP + 6)
   local RANGE_FUNCTION_PRE="("
   local RANGE_FUNCTION_POST=")"
   local PARTITION_FUNCTION_PRE="("
   local PARTITION_FUNCTION_POST=")"
  ;;
  $DUAL_REV_TYPE)
   local START=0
   local INDEX=$START
   local STOP=$(current_config_rev)
   #partitions should go out 5 revs by default
   STOP=$(expr $STOP + 6)
   local RANGE_FUNCTION_PRE="COLUMNS("
   local RANGE_FUNCTION_POST=")"
   local PARTITION_FUNCTION_PRE="("
   local PARTITION_FUNCTION_POST=")"
   ;;
  *)
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
  if [ "$TYPE" == "$DUAL_REV_TYPE" ]
  then
    local IINDEX="$INDEX,$INDEX"
    local MAXVALUE="(MAXVALUE,MAXVALUE)"
  else
    local IINDEX="$INDEX"
    local MAXVALUE="MAXVALUE"
  fi
  read -r -d '' LINE_SQL <<EOF
      partition p$INDEX values less than $PARTITION_FUNCTION_PRE${IINDEX}$PARTITION_FUNCTION_POST,

EOF
  RANGE_SQL="$RANGE_SQL
$LINE_SQL"
  case $TYPE in
  $DAY_TYPE)
    INDEX=$(date -d "$INDEX + 1 day" +%Y%m%d)
    ;;
  $REV_TYPE |  $DUAL_REV_TYPE)
    INDEX=$(expr $INDEX + 1)
    ;;
  esac
  sleep $REST_TIME
done
ALTER_SQL="alter table $TABLE partition by range $RANGE_FUNCTION_PRE${COLUMNS}$RANGE_FUNCTION_POST ("
PMAX_SQL="partition pmax values less than $MAXVALUE);"

SQL="$ALTER_SQL$RANGE_SQL
$PMAX_SQL"
echo "$SQL"
}

function count_partitions() 
{
local TABLE=$1
  echo "$($MYSQL -e "show create table $TABLE\G" | grep -ic "partition p")"
}
function create_partition()
{
local TABLE=$1
local TYPE=$2
local COLUMNS=$3

if [ $(count_partitions $TABLE) -gt 0 ]
then
  echo "Table $TABLE already has partitions, exiting"
  return
fi

if [ -n "${PRIMARY_KEY_MAP[$TABLE]}" ]
then
  add_drop_primary_key $TABLE "${PRIMARY_KEY_MAP[$TABLE]}"
else
  echo "missing primary key map for $TABLE:${PRIMARY_KEY_MAP[$TABLE]}"
fi

if [ -n "${CONSTRAINT_MAP[$TABLE]}" ]
then
  drop_constraint_recursive "${CONSTRAINT_MAP[$TABLE]}" $TABLE
fi

SQL=$(create_partition_range $TABLE $TYPE)
echo "$SQL"
$MYSQL <<EOF
$SQL
EOF
if [ $? -ne 0 ]
then
  echo "alter failed, possibly due to FOREIGN KEYS.  If any are still present they will be listed below:"
  echo "$($MYSQL -q -s -e 'select * from information_schema.key_column_usage where (table_name = "'$TABLE'" or referenced_table_name = "'$TABLE'") and constraint_name <> "'PRIMARY'" and table_schema="'transitime'"\G')"
  exit 1
fi

}

function create_all_partitions()
{

#  create_partition "Predictions" $DAY_TYPE ${COLUMN_MAP["Predictions"]}
#  create_partition "Blocks" $REV_TYPE ${COLUMN_MAP["Blocks"]}
for TABLE in ${TABLES[@]}; do
  create_partition ${TABLE} "${TYPE_MAP[$TABLE]}" "${COLUMN_MAP[$TABLE]}"
  echo "Sleeping for $REST_TIME"
  sleep $REST_TIME
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
  echo "  create    -- create the partitions from a base database"
  echo "  update    -- update existing partitions to include current ranges"
  echo "  prune     -- prune partitions to drop old ranges"
  ;;
esac
