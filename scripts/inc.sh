#!/bin/bash -x
START=20151101
DAY=$(date -d "$START + 1 day" +%Y%m%d)
NOW=$(date +%Y%m%d)
FUTURE=$(date -d "$NOW + 30 day" +%Y%m%d)
FUTURE=$(date -d "$START + 2 day" +%Y%m%d)
while [ "$DAY" -lt "$FUTURE" ]
do
  echo "$DAY"
  echo "alter table Matches reorganize partition pmax INTO ( partition p$DAY values less than (to_days('$DAY')) engine = InnoDB,  partition pmax values less than maxvalue engine = InnoDB );" | mysql -u prediction -pchangeme -h db.dev.wmata.obaweb.org transitime
  DAY=$(date -d "$DAY + 1 day" +%Y%m%d)
  echo "sleeping for 30"
  sleep 30
done
