#!/bin/bash

set -e
trap 'catch $? $LINENO' EXIT

catch() {
  if [ "$1" != "0" ]; then
    echo "Error $1 occurred on $2"
    rm -rf ${ARCHIVE}
    exit "$1"
  fi
}

ARCHIVE=${1}
shift
FORMAT=${1}
shift

export GOPATH=${HOME}/go

rm -rf ${ARCHIVE}
mkdir -p ${ARCHIVE}
cp -a resin-xp-finder/. ${ARCHIVE}/.
# Skip the 'validation_print' directory
rm -rf ${ARCHIVE}/validation_print

find ${ARCHIVE} -name "*.photon" | (while read i; do
    nn=$(dirname $i)/$(basename $i .photon).${FORMAT}
    echo ":uv3dp ${i}" "$@" "${nn}"
    go run github.com/ezrec/uv3dp/cmd/uv3dp ${i} "$@" ${nn}
    rm -f ${i}
done)

rm -f ${ARCHIVE}.zip
cd ${ARCHIVE}
zip -r ../${ARCHIVE}.zip .
cd ..
rm -rf ${ARCHIVE}
