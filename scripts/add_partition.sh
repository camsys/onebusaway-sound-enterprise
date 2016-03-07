#!/bin/bash

function build_table()
{
  echo "alter table $1 partition by range (to_days($2)) ("

}

function build_partitions()
{
TABLE=$1
START=20151101
DAY=$(date -d "$START + 1 day" +%Y%m%d)
NOW=$(date +%Y%m%d)
FUTURE=$(date -d "$NOW + 30 day" +%Y%m%d)
FUTURE=$(date -d "$START + 2 day" +%Y%m%d)
while [ "$DAY" -lt "$FUTURE" ]
do
  echo "alter table $TABLE reorganize partition pmax INTO ( partition p$DAY values less than (to_days('$DAY')) engine = InnoDB"
  DAY=$(date -d "$DAY + 1 day" +%Y%m%d)
  echo "sleeping for 30"
  sleep 30
done
  echo ""
}

# time
TABLES=(Predictions Matches AvlReports ArrivalsDepartures)
COLUMS=(avlTime avlTime time time)

ICOUNT=1
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


