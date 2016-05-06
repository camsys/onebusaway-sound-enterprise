attach database 'x.db' as x;
attach database 'y.db' as y;

create table CombinedAccuracy(x_accuracy integer, y_accuracy integer, horizon integer);

insert into CombinedAccuracy
select
	xpa.predictionAccuracyMsecs,
	ypa.predictionAccuracyMsecs,
	xpa.predictionLength
from  x.PredictionAccuracy xpa join y.predictionAccuracy ypa
on
	(xpa.gtfsStopSeq=ypa.gtfsStopSeq
		and xpa.isArrival=ypa.isArrival 
		and xpa.predictionReadTime=ypa.predictionReadTime
		and xpa.tripId = ypa.tripId);

.print X total predictions
select count(*) from x.PredictionAccuracy;

.print X average normalized error
select avg(abs(predictionAccuracyMsecs*1.0 / predictionLength)) from x.PredictionAccuracy;

.print Y total predictions
select count(*) from y.PredictionAccuracy;

.print Y average normalized error
select avg(abs(predictionAccuracyMsecs*1.0 / predictionLength)) from y.PredictionAccuracy;

.print Total combined predictions
select count(*) from CombinedAccuracy;

.print X better than Y
select sum(abs(x_accuracy) < abs(y_accuracy)) from CombinedAccuracy;

.print Y better than X
select sum(abs(y_accuracy) < abs(x_accuracy)) from CombinedAccuracy;