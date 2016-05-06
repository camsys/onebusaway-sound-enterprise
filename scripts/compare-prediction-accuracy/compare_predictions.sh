# Usage: ./compare_predictions.sh [-r [routeId]] [-t [tripId]] [-s [stopId]] [-v [vehicleId]] [begin] [end]
# Route, trip, stop, and vehicle options can be used in combination or not all.
# For example: 
# ./compare_predicitions.sh -v 8062 '2016-05-05 10:45:00' '2016-05-05 12:00:00'
# This will:
# - download the Predictions and ArrivalsDepartures databases from two servers (X and Y) 
# - export to sqlite
# - build PredictionAccuracy tables and a CombinedAccuracy table (predictions from both
#   sources joined by avlTime when prediction made and stop/trip)
# - report on summary statistics over the PredictionAccuracy and CombinedAccuracy tables

# Notes:
# No validation is performed on inputs.
# The times used to restrict ArrivalsDepartures (actual Arrival/Departure time) and Prediction
# (creationTime) don't exactly line up -- i.e., if we restrict both to 9:00-10:00, we will get
# arrival/departures that are earlier than all the predictions and predictions that never
# see an arrival departure. Ideally we would use predictionTime for predictions, ie the time
# an arrival/departure is predicted. Unfortunately predictionTime is not indexed and this would
# be very expensive. For now, simply use a large enough time range to get the arrivals/departures
# you are interested in.
# The only sqlite-specific part of the SQL code is date arithmetic. 

X_HOST=db.dev.wmata.obaweb.org
X_USER=transitime
X_PASS=changeme

Y_HOST=db-ro.prod.wmata.obaweb.org
Y_USER=transitime
Y_PASS=transitimeprod

# Get parameters from command line

where=""

while getopts "r:t:v:s:" opt; do
  case $opt in
    r)
      where="$where and routeId='$OPTARG'"
      ;;
    t)
	  where="$where and tripId='$OPTARG'";
	  ;;
	s)
      where="$where and stopId='$OPTARG'"
      ;;
    v)
	  where="$where and vehicleId='$OPTARG'"
	  ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

shift $((OPTIND-1))

# Construct where clause
# Name of time field will be added later
begin=$1
end=$2
if [ -z "$begin" ] || [ -z "$end" ]
then
	echo "Must supply positional parameters for start and end."
	exit 1
fi
where="between '$begin' and '$end' $where"

# from http://forums.mysql.com/read.php?145,68269,92627
function mysql2sqlite() {
	grep -v ' KEY "' |
	grep -v ' UNIQUE KEY "' |
	sed -e 's/AUTO_INCREMENT//g' |
	perl -e 'local $/;$_=<>;s/,\n\)/\n\)/gs;print "begin;\n";print;print "commit;\n"' |
	perl -pe '
		if (/^(INSERT.+?)\(/) {
			$a=$1;
			s/\\'\''/'\'\''/g;
			s/\\n/\n/g;
			s/\),\(/\);\n$a\(/g;
		}
	' |
	sqlite3 $1
}

function exportdb() {
	mysqldump --compatible=ansi --skip-extended-insert --compact \
	-h $1 -u $2 -p$3 transitime $4 \
	--where "$5 $where" \
	| mysql2sqlite $6
}

# Remove old databases

for db in x.db y.db combined_accuracy.db
do
	if [ -e "$db" ]; then rm $db; fi
done

# Dump tables

exportdb $X_HOST $X_USER $X_PASS ArrivalsDepartures time x.db
exportdb $X_HOST $X_USER $X_PASS Predictions creationTime x.db
exportdb $Y_HOST $Y_USER $Y_PASS ArrivalsDepartures time y.db
exportdb $Y_HOST $Y_USER $Y_PASS Predictions creationTime y.db

# Create prediction accuracy tables

sqlite3 x.db <create_predictionaccuracy.sql     
sqlite3 y.db <create_predictionaccuracy.sql

# Create combined accuracy

sqlite3 combined_accuracy.db <compare_accuracy.sql



