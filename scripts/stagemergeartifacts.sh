#! /usr/bin/env bash
set -e
# stagemainartifacts.sh
#
# Identify newly-built artifacts, then stage them in a folder of the artifacts bucket.
# This folder will match the branch name of the merge.
# If artifacts exist in this folder matching a file glob, remove them first.
#
# This script will only execute when triggered by a GitHub / GitLab merge event.
# More plainly, this is when a commit is pushed to a protected branch (after PR / MR).
# This is determined by the presence of the substring 'refs/heads/' in a $GITHUB_REF var,
#   or when $CI_PIPELINE_SOURCE == "push".
#
# This script must be passed the following vars:
#   DSSS3URI:   The S3 URI pointing to the artifacts bucket
#   DSSGLOBLIST:    A list of fileglobs expected to be present after a successful build.
#                       Note if any glob does not match, the script will fail and return non-zero.
#

# Read DSSGLOBLIST var as array
IFS=' ' read -ra DSSGLOBLIST <<< "$DSSGLOBLIST"

# Check if DSSS3URI is defined
if [[ "$DSSS3URI" == '' ]]
then
    echo "*** ERROR: DSSS3URI var not defined"
    exit 1
fi

# Check if DSSGLOBLIST var provided
if [[ ${DSSGLOBLIST[0]} == '' ]]
then
    echo "No artifact globs provided."
    exit 1
fi

# Check if build was triggered by merge. Otherwise skip (eg: skip PR or manual build)
if [[ $GITHUB_REF != "refs/heads"* && $CI_PIPELINE_SOURCE != "push" ]]
then
    echo "Not a merge. Skipping artifact rotation."
    exit 0
fi

# Derive the branch name
if [[ $GITHUB_REF ]]
then
    BRANCH_NAME=$(echo "$GITHUB_REF" | cut --complement -c 1-11)
elif [[ $CI_MERGE_REQUEST_TARGET_BRANCH_NAME ]]
then
    BRANCH_NAME=$CI_MERGE_REQUEST_TARGET_BRANCH_NAME
else
    echo "*** ERROR - I could not derive the branch name."
    exit 1
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
    mapfile -t REMOTEARTIFACTS < <(aws s3 ${MINIO_HOST_URL:+--endpoint-url $MINIO_HOST_URL} ls "$DSSS3URI/$BRANCH_NAME/" | grep -oP "${GLOB//\*/.*}")
    set -e

    if [[ "${REMOTEARTIFACTS[0]}" == '' ]]
    then
        echo "I couldn't find any existing main artifacts matching glob '$GLOB' in the bucket. Skipping deletion..."
    else
        for artifact in "${REMOTEARTIFACTS[@]}"
        do
            echo "Deleting existing object from artifacts bucket: $artifact"
            aws s3 ${MINIO_HOST_URL:+--endpoint-url $MINIO_HOST_URL} rm "$DSSS3URI/$BRANCH_NAME/$artifact" --only-show-errors
        done
    fi
done

# Copy new main artifacts
for file in "${LOCALARTIFACTS[@]}"
do
    echo "Copying file to artifacts bucket: $file"
    aws s3 ${MINIO_HOST_URL:+--endpoint-url $MINIO_HOST_URL} cp "$file" "$DSSS3URI/$BRANCH_NAME/" --only-show-errors
done
