/*
* first pass at a sql script to vaccuum transitime db
*/
create index timeProcessedIndex on AvlReports (timeProcessed);
create index configRevIndex on Block_to_Trip_joinTable (blocks_configRev);
create index configRevIndex on Block (configRev);
create index configRevIndex on CalendarDates (configRev);


create index configRevIndex on Calendars (configRev);


create index configRevIndex on FareAttributes (configRev);
create index configRevIndex on FareRules (configRev);
create index configRevIndex on Frequencies (configRev);
create index configRevIndex on Matches (configRev);
create index predictedTimeIndex on PredictionAccuracy (predictedTime);
create index configRevIndex on Predictions (configRev);
create index configRevIndex on Routes (configRev);
create index configRevIndex on Transfers (configRev);
create index configRevIndex on Trip_scheduledTimesList (Trip_configRev);
create index configRevIndex on TripPattern_to_Path_joinTable (TripPatterns_configRev);
create index configRevIndex on Stops (configRev);
create index configRevIndex on TripPatterns (configRev);
create index configRevIndex on TravelTimesForStopPaths (configRev);
create index configRevIndex on Trips (configRev);
create index configRevIndex on StopPath_locations (configRev);


// find the configRef to clean
delete from ArrivalsDepartures where configRev in (select configRev from ConfigRevision where processedTime < '2015-12-20');
delete from AvlReports where timeProcessed < DATE_ADD(now(), INTERVAL -90 DAY);
delete from Block_to_Trip_joinTable where blocks_configRev in (select configRev from ConfigRevision where processedTime < '2015-12-20');
delete from Blocks where configRev in (select configRev from ConfigRevision where processedTime < '2015-12-20');

delete from CalendarDates where configRev in (select configRev from ConfigRevision where processedTime < '2015-12-20');
delete from Calendars where configRev in (select configRev from ConfigRevision where processedTime < '2015-12-20');
delete from FareAttributes where configRev in (select configRev from ConfigRevision where processedTime < '2015-12-20');
delete from FareRules where configRev in (select configRev from ConfigRevision where processedTime < '2015-12-20');
delete from Frequencies where configRev in (select configRev from ConfigRevision where processedTime < '2015-12-20');
delete from Matches where configRev in (select configRev from ConfigRevision where processedTime < '2015-12-20');
delete from PredictionAccuracy where arrivalDepartureTime < DATE_ADD(now(), INTERVAL -90 DAY);
delete from Predictions where configRev in (select configRev from ConfigRevision where processedTime < '2015-12-20');
delete from Routes where configRev in (select configRev from ConfigRevision where processedTime < '2015-12-20');

delete from Transfers where configRev in (select configRev from ConfigRevision where processedTime < '2015-12-20');

delete from Trip_scheduledTimesList where Trip_configRev in (select configRev from ConfigRevision where processedTime < '2015-12-20');
delete from TripPattern_to_Path_joinTable where TripPatterns_configRev in (select configRev from ConfigRevision where processedTime < '2015-12-20');

delete from VehicleEvents where time < DATE_ADD(now(), INTERVAL -90 DAY);
delete from Stops where configRev in (select configRev from ConfigRevision where processedTime < '2015-12-20');


delete from TripPatterns where configRev in (select configRev from ConfigRevision where processedTime < '2015-12-20');

delete from TravelTimesForTrip_to_TravelTimesForPath_joinTable where TravelTimesForTrips_id in ((select id from TravelTimesForTrips where configRev in (select configRev from ConfigRevision where processedTime < '2015-12-20';)));

delete from TravelTimesForStopPaths where configRev in (select configRev from ConfigRevision where processedTime < '2015-12-20');

delete from Trips where configRev in (select configRev from ConfigRevision where processedTime < '2015-12-20');

delete from StopPath_locations where StopPath_configRev in (select configRev from ConfigRevision where processedTime < '2015-12-20');
delete from StopPaths where configRev in (select configRev from ConfigRevision where processedTime < '2015-12-20');



delete from Agencies where configRev in (select configRev from ConfigRevision where processedTime < '2015-12-20');
delete from TravelTimesForTrips where configRev in (select configRev from ConfigRevision where processedTime < '2015-12-20');

select configRev from ConfigRevision where processTime < '2016-01-10 00:00:00';
