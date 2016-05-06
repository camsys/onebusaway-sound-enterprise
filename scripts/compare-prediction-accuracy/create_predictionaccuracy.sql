CREATE TABLE "PredictionAccuracy" (
  "arrivalDepartureTime" datetime DEFAULT NULL,
  "predictedTime" datetime NOT NULL,
  "predictionAccuracyMsecs" int(11) DEFAULT NULL,
  "predictionReadTime" datetime DEFAULT NULL,
  "routeId" varchar(60) DEFAULT NULL,
  "stopId" varchar(60) DEFAULT NULL,
  "gtfsStopSeq" integer,
  "tripId" varchar(60) DEFAULT NULL,
  "vehicleId" varchar(60) DEFAULT NULL,
  "isArrival" integer,
  "predictionLength" integer
);

insert into PredictionAccuracy
  (arrivalDepartureTime, predictedTime,
    predictionAccuracyMsecs, predictionReadTime, routeId, stopId,
    gtfsStopSeq, tripId, vehicleId, isArrival, predictionLength)

select ad.time as arrivalDepartureTime,
  p.predictionTime as predictedTime,
  strftime("%s.%f", p.predictionTime)*1000 - strftime("%s.%f",ad.time)*1000 as predictionAccuracyMsecs,
  p.avlTime as predictionReadTime,
  p.routeId, p.stopId, p.gtfsStopSeq, p.tripId, p.vehicleId, p.isArrival,
  strftime("%s.%f", ad.time)*1000 - strftime("%s.%f", p.avlTime)*1000
from Predictions p join ArrivalsDepartures ad on
  (p.gtfsStopSeq = ad.gtfsStopSeq and p.tripId = ad.tripId and p.vehicleId = ad.vehicleId
    and strftime("%s.%f", ad.avlTime) - strftime("%s.%f", p.avlTime) between 0 and 1800
    and p.isArrival = ad.isArrival);