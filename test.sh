#!/bin/bash 
set -e
set -o pipefail

usage() {
	echo "Usage:"
	echo "  $0 <profile>"
	exit 1
}

mkcd() {
	local DIR=$1
	mkdir -p $DIR && cd $DIR
}

nxf_setup() {
	if ! nextflow &>/dev/null; then
		export PATH=$PWD:$PATH 
		if [ ! -x nextflow ]; then
			curl -fsSL get.nextflow.io | bash && chmod +x nextflow
		fi
	fi
}

RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NORMAL="\033[0m"

[[ $1 == "help" ]] && usage

BASE_DIR=$(dirname $0)

PROFILE=${PROFILE-"testGemFlux"} 
CHECKDIR=${CHECKDIR-"checksum"}

RUN_OPTS=${RUN_OPTS-"-process.errorStrategy=terminate"}

echo -e "==$YELLOW Running pipeline with profile -> $BLUE${PROFILE}$NORMAL"
nxf_setup && nextflow -c ${BASE_DIR}/test-profiles.config run ${BASE_DIR} -profile $PROFILE ${RUN_OPTS} "$@"
echo -e "==$YELLOW Compare results$NORMAL"
mkcd $CHECKDIR
cut -f 3 ../pipeline.db | xargs -I{} ln -fs {}
md5sum -c ../${BASE_DIR}/data/$PROFILE.md5
echo -e "==$YELLOW Clean up$NORMAL"
cd .. && rm -rf $CHECKDIR
echo -e "==$YELLOW DONE$NORMAL"
