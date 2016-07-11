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

BUILD_OBA=TRUE
BUILD_WMATA=TRUE
BUILD_SOUND=FALSE
BUILD_T=TRUE
rm -rf onebusaway-application-modules onebusaway-wmata-enterprise onebusaway-sound-enterprise core
if [ "$BUILD_OBA" == "TRUE" ]
then
echo "Releasing app mods" && \
git clone git@github.com:camsys/onebusaway-application-modules && \
cd onebusaway-application-modules && \
git checkout unified && \
mvn --batch-mode release:prepare -DreleaseVersion=${ORELEASE} -DdevelopmentVersion=${ODEV} -Dpushchanges=false && \
git push --tags && \
mvn release:perform && \
git push && \
mvn clean install || exit 1
cd ..
fi
if [ "$BUILD_WMATA" == "TRUE" ]
then
echo "Releasing wmata enterprise" && \
git clone git@github.com:camsys/onebusaway-wmata-enterprise && \
cd onebusaway-wmata-enterprise && \
for file in `find . -name pom.xml`; do sed -i ${file} -e 's!'${OLAST}'!'${ORELEASE}'!g'; done && \
mvn clean deploy || exit 1
git commit -a -m "releasing..." && \
git tag -f -a ${ORELEASE} -m "creating oba tag" && \
git push -f --tags && \
for file in `find . -name pom.xml`; do sed -i ${file} -e 's!'${ORELEASE}'!'${ODEV}'!g'; done && \
mvn clean deploy || exit 1
git commit -a -m "preparing for next release" && \
git push && \
cd ..
fi
if [ "$BUILD_SOUND" == "TRUE" ]
then
echo "Releasing sound enterprise" && \
git clone git@github.com:camsys/onebusaway-sound-enterprise && \
cd onebusaway-sound-enterprise && \
for file in `find . -name pom.xml`; do sed -i ${file} -e 's!'${OLAST}'!'${ORELEASE}'!g'; done && \
mvn clean deploy || exit 1
git commit -a -m "releasing..." && \
git tag -f -a ${ORELEASE} -m "creating oba tag" && \
git push -f --tags && \
for file in `find . -name pom.xml`; do sed -i ${file} -e 's!'${ORELEASE}'!'${ODEV}'!g'; done && \
mvn clean deploy || exit 1
git commit -a -m "preparing for next release" && \
git push && \
cd ..
fi
if [ "$BUILD_T" == "TRUE" ]
then
echo "Releasing Transitime" && \
git clone git@github.com:sheldonabrown/core && \
cd core && \
for file in `find . -name pom.xml`; do sed -i ${file} -e 's!'${TLAST}'!'${TRELEASE}'!g'; done && \
mvn clean deploy || exit 1
git commit -a -m "releasing..." && \
git tag -f -a ${TRELEASE} -m "creating transitime tag" && \
git push -f --tags && \
for file in `find . -name pom.xml`; do sed -i ${file} -e 's!'${TRELEASE}'!'${TDEV}'!g'; done && \
mvn clean deploy || exit 1
git commit -a -m "preparing for next release" && \
git push
fi
echo "Finished!"



#mvn --batch-mode release:prepare -DreleaseVersion=${TRELEASE} -DdevelopmentVersion=${TDEV} -Dpushchanges=false && \
#git push --tags origin master && \
#mvn release:perform && \
#git commit -a -m "preparing for development iteration" && \
#git push && \

