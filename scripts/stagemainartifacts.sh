#! /usr/bin/env bash
set -e
# stagemainartifacts.sh
#
# Identify newly-built artifacts, then stage them in the 'main' folder of the artifacts bucket.
# If existing 'main' artifacts exist, remove them first.
#
# This script will only execute when triggered by a GitHub merge event.
# This is determined by the presence of the substring 'refs/heads/' in a $GITHUB_REF var.
#
# This script must be passed the following vars:
#   DSSMAINS3URI:   The S3 URI pointing to the artifacts bucket
#   DSSGLOBLIST:    A list of fileglobs expected to be present after a successful build.
#                       Note if any glob does not match, the script will fail and return non-zero.
#

# Read DSSGLOBLIST var as array
IFS=' ' read -ra DSSGLOBLIST <<< "$DSSGLOBLIST"

# Check if DSSMAINS3URI is defined
if [[ "$DSSMAINS3URI" == '' ]]
then
    echo "*** ERROR: DSSMAINS3URI var not defined"
    exit 1
fi

# Check if DSSGLOBLIST var provided
if [[ ${DSSGLOBLIST[0]} == '' ]]
then
    echo "No artifact globs provided."
    exit 1
fi

# Check if build was triggered by merge. Otherwise skip (eg: skip PR or manual build)
if [[ $GITHUB_REF != *"refs/heads"* ]]
then
    echo "Not a GitHub merge. Skipping main artifacts rotation."
    exit 0
fi

# Find local artifacts
LOCALARTIFACTS=()
for GLOB in "${DSSGLOBLIST[@]}"
do
    mapfile -t GLOBFILES < <(find . -name "$GLOB")
    
    if [[ "${GLOBFILES[0]}" == '' ]]
    then
        echo "*** ERROR - I couldn't find a file matching glob: '$GLOB'! Terminating..."
        exit 1
    fi

    LOCALARTIFACTS+=("${GLOBFILES[@]}")
done

# Delete existing main artifacts
for GLOB in "${DSSGLOBLIST[@]}"
do
    set +e
    mapfile -t REMOTEARTIFACTS < <(aws s3 ls "$DSSMAINS3URI"/ | grep -oP "${GLOB//\*/.*}")
    set -e

    if [[ "${REMOTEARTIFACTS[0]}" == '' ]]
    then
        echo "I couldn't find any existing main artifacts matching glob '$GLOB' in the bucket. Skipping deletion..."
    else
        for artifact in "${REMOTEARTIFACTS[@]}"
        do
            echo "Deleting existing object from artifacts bucket: $artifact"
            aws s3 rm "$DSSMAINS3URI/$artifact" --only-show-errors
        done
    fi
done

# Copy new main artifacts
for file in "${LOCALARTIFACTS[@]}"
do
    echo "Copying file to artifacts bucket: $file"
    aws s3 cp "$file" "$DSSMAINS3URI"/ --only-show-errors
done
