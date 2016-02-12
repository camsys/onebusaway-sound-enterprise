#!/bin/bash -x

if [ -z 6 ]
then
  echo "Usage build.sh oba_current_snapshot oba_relase oba_next_snapshot "
  echo "               transitime_current_snaphot transitme_release "
  echo "               transitme_next_snapshot"
  return 1
fi

OLAST=$1
ORELEASE=$2
ODEV=$3
TLAST=$4
TRELEASE=$5
TDEV=$6

#rm -rf onebusaway-application-modules onebusaway-wmata-enterprise core
#echo "Releasing app mods" && \
#git clone git@github.com:camsys/onebusaway-application-modules && \
#cd onebusaway-application-modules && \
#git checkout unified && \
#mvn --batch-mode release:prepare -DreleaseVersion=${ORELEASE} -DdevelopmentVersi=${ODEV} -Dpushchanges=false && \
#git push --tags && \
mvn release:perform && \
git push && \
mvn clean install && \
cd .. && \
echo "Releasing wmata enterprise" && \
git clone git@github.com:camsys/onebusaway-wmata-enterprise && \
cd onebusaway-wmata-enterprise && \
for file in `find . -name pom.xml`; do sed -i ${file} -e 's!'${OLAST}'!'${ORELEASE}'!g'; done && \
mvn clean deploy && \
git commit -a -m "releasing..." && \
git tag -f -a ${ORELEASE} -m "creating oba tag" && \
git push -f --tags && \
for file in `find . -name pom.xml`; do sed -i ${file} -e 's!'${ORELEASE}'!'${ODEV}'!g'; done && \
mvn clean deploy && \
git commit -a -m "preparing for next release" && \
git push && \
cd .. && \
echo "Releasing Transitime" && \
git clone git@github.com:sheldonabrown/core && \
cd core && \
for file in `find . -name pom.xml`; do sed -i ${file} -e 's!'${TLAST}'!'${TRELEASE}'!g'; done && \
mvn clean deploy && \
git commit -a -m "releasing..." && \
git tag -f -a ${TRELEASE} -m "creating transitime tag" && \
git push -f --tags && \
for file in `find . -name pom.xml`; do sed -i ${file} -e 's!'${TRELEASE}'!'${TDEV}'!g'; done && \
mvn clean deploy && \
git commit -a -m "preparing for next release" && \
git push && \
echo "Finished!"



#mvn --batch-mode release:prepare -DreleaseVersion=${TRELEASE} -DdevelopmentVersion=${TDEV} -Dpushchanges=false && \
#git push --tags origin master && \
#mvn release:perform && \
#git commit -a -m "preparing for development iteration" && \
#git push && \

