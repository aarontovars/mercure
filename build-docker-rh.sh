#!/bin/bash

PREFIX="mercureimaging"
VERSION="latest"  # Set a default value for VERSION
TAG=${MERCURE_TAG:-$VERSION}
# Define where mercure is going to store things
# You can redefine types of volumes in docker/docker-compose.yml

MERCUREBASE=/opt/mercure
DATADIR=$MERCUREBASE/data
CONFIGDIR=$MERCUREBASE/config
DBDIR=$MERCUREBASE/db
MERCURESRC=./

#################################################################
# BUILD SECTION
#################################################################
echo "Building Docker containers for mercure $VERSION"
echo "Using image tag $TAG"
echo ""

FORCE_BUILD="n"
CACHE="--no-cache"

while getopts "fp:t:" opt; do
  case $opt in
    f)
      FORCE_BUILD=y
      ;;
    p)
      PREFIX=$OPTARG
      ;;
    t)
      TAG=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

if [ $FORCE_BUILD = "y" ]; then
  echo "Forcing building"
else
  read -p "Proceed (y/n)? " ANS
  if [ "$ANS" = "y" ]; then
  echo ""
  else
  echo "Aborted."
  exit 0
  fi
fi

build_component () {
  podman build docker/$1 -t $PREFIX/mercure-$1:$TAG -t $PREFIX/mercure-$1:latest --build-arg VERSION_TAG=$TAG
}

podman build $CACHE -t $PREFIX/mercure-base:$TAG -t $PREFIX/mercure-base:latest -f docker/base/Dockerfile .

for component in ui bookkeeper receiver router processor dispatcher cleaner
do
  build_component $component
done

podman build nomad/sshd -t $PREFIX/alpine-sshd:latest
podman build nomad/processing -t $PREFIX/processing-step:$TAG -t $PREFIX/processing-step:latest
podman build nomad/dummy-processor -t $PREFIX/mercure-dummy-processor:$TAG -t $PREFIX/processing-step:latest

echo ""
echo "Done."
echo ""