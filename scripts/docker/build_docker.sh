#! /usr/bin/env bash
# shellcheck disable=SC1091

# Generic DSS Build Docker script
set -e

# Default values
COMPONENT_NAME=""
DOCKERFILE_NAME=""
DOCKER_TAG=""
ARTIFACT_BLOB=""

# Parse command line arguments
while getopts ":c:d:t:a:u" opt; do
  case $opt in
    c) COMPONENT_NAME="$OPTARG";;
    d) DOCKERFILE_NAME="$OPTARG";;
    t) DOCKER_TAG="$OPTARG";;
    a) ARTIFACT_BLOB="$OPTARG";;
    u) USERFLAG=true;;
    \?) echo "Invalid option: -$OPTARG" >&2;;
  esac
done

# Check if required arguments are present
if [[ -z "$COMPONENT_NAME" || -z "$DOCKERFILE_NAME" || -z "$DOCKER_TAG" || -z "$ARTIFACT_BLOB" ]]; then
  echo "Usage: $0 -c COMPONENT_NAME -d DOCKERFILE_NAME -t DOCKER_TAG -a ARTIFACT_BLOB" [-u]>&2
  exit 1
fi

# Load utility functions
DOCKER_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "$DOCKER_DIR/../utils.sh"

# Check for submodules and update init recursive if missing
checksubmodules

# Read ARTIFACT_BLOB var as array
IFS=' ' read -ra ARTIFACT_LIST <<< "$ARTIFACT_BLOB"

# Check number of built artifacts
CHECK_ARTIFACT=0
for ARTIFACT in "${ARTIFACT_LIST[@]}"
do
    CHECK_ARTIFACT=$((CHECK_ARTIFACT+$(find "$ARTIFACTS_DIR/" -name "$ARTIFACT" | wc -l)))
done
echo "Num. Artifacts: $CHECK_ARTIFACT"
echo "Num. Artifacts expected: ${#ARTIFACT_LIST[@]}"

# Only build if number of built artifacts does not match number of blobs
if [ "$CHECK_ARTIFACT" != "${#ARTIFACT_LIST[@]}" ]
then
    # Build Docker image
    DOCKERBUILDSTR="docker build -t $DOCKER_TAG -f $DOCKER_DIR/$DOCKERFILE_NAME.Dockerfile $DSS_DIR"
    echo "BUILDING: $DOCKERBUILDSTR"
    eval "$DOCKERBUILDSTR"

    # Check if the docker build should run as the current user
    USERSTR=''
    CHOWNSTR=''

    if [[ "$USERFLAG" == true ]]
    then
      USERSTR="-u $(id -u "${USER}"):$(id -g "${USER}")"
      echo "Running build in Docker with USERFLAG enabled"
    else
      for ARTIFACT in "${ARTIFACT_LIST[@]}"
      do
          CHOWNSTR="$CHOWNSTR && chown $(id -u "${USER}"):$(id -g "${USER}") dss-ansible/artifacts/$ARTIFACT"
      done
    fi

    # Build component with Docker container
    DOCKERRUNSTR="docker run --rm -v $DSS_DIR:/$DOCKERFILE_NAME $USERSTR $DOCKER_TAG sh -c \"./scripts/build_$COMPONENT_NAME.sh $CHOWNSTR\""
    echo "RUNNING: $DOCKERRUNSTR"
    eval "$DOCKERRUNSTR"

else
    echo 'Artifact already built. Skipping...'
fi
