#! /usr/bin/env bash
# shellcheck disable=SC1091

# Generic DSS Build Docker script
set -e

# Default values
COMPONENT_NAME=""
DOCKER_TAG=""
ARTIFACT_BLOB=""

# Parse command line arguments
while getopts ":c:t:a:u" opt; do
  case $opt in
    c) COMPONENT_NAME="$OPTARG";;
    t) DOCKER_TAG="$OPTARG";;
    a) ARTIFACT_BLOB="$OPTARG";;
    u) USERFLAG=true;;
    \?) echo "Invalid option: -$OPTARG" >&2;;
  esac
done

# Check if required arguments are present
if [[ -z "$COMPONENT_NAME" || -z "$DOCKER_TAG" || -z "$ARTIFACT_BLOB" ]]; then
  echo "Usage: $0 -c COMPONENT_NAME -t DOCKER_TAG -a ARTIFACT_BLOB" [-u]>&2
  exit 1
fi

# Load utility functions
DOCKER_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "$DOCKER_DIR/../utils.sh"

# Check for submodules and update init recursive if missing
checksubmodules

# Check if artifact already built
CHECK_ARTIFACT=$(find "$ARTIFACTS_DIR/" -name "$ARTIFACT_BLOB" | wc -l)

# Only build if artifact not already built
if [ "$CHECK_ARTIFACT" == 0 ]
then
    # Build Docker image
    echo "BUILDING: docker build -t $DOCKER_TAG -f $DOCKER_DIR/$COMPONENT_NAME.Dockerfile $DSS_DIR"
    docker build -t "$DOCKER_TAG" -f "$DOCKER_DIR"/"$COMPONENT_NAME".Dockerfile "$DSS_DIR"

    # Check if the docker build should run as the current user
    USERSTR=''
    CHOWNSTR="&& chown $(id -u "${USER}"):$(id -g "${USER}") dss-ansible/artifacts/$ARTIFACT_BLOB"

    if [[ "$USERFLAG" == true ]]
    then
      USERSTR="-u $(id -u "${USER}"):$(id -g "${USER}")"
      CHOWNSTR=''
      echo "Running build in Docker with USERFLAG enabled"
    fi

    # Build component with Docker container
    echo "RUNNING: docker run --rm -v $DSS_DIR:/$COMPONENT_NAME $USERSTR $DOCKER_TAG sh -c ./scripts/build_$COMPONENT_NAME.sh $CHOWNSTR"
    docker run --rm -v "$DSS_DIR":/"$COMPONENT_NAME" $USERSTR "$DOCKER_TAG" sh -c "./scripts/build_$COMPONENT_NAME.sh $CHOWNSTR"

else
    echo 'Artifact already built. Skipping...'
fi
