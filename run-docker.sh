#!/bin/bash
DOCKER_NAME="vswitch"
IMG_NAME="vswitch:latest"
PARAMS+="-p 830:830 "
PARAMS+="-it "

function run::() {
${@}
}

function run::as-root() {
  run:: sudo ${@}
}

if [[ "${1}" = "build" ]]; then
   run::as-root docker build -t ${IMG_NAME} .
elif [[ "${1}" = "push" ]]; then
   run::as-root docker push ${IMG_NAME}
elif [[ "${1}" = "rm" ]]; then
   run::as-root docker rm --force ${DOCKER_NAME}
elif [[ "${1}" = "run" ]]; then
   echo ${PARAMS}
   run::as-root docker run ${PARAMS} --name ${DOCKER_NAME} ${IMG_NAME}
else
   echo "Please enter right argument [build, push, rm, run]"
fi
