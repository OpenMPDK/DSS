#!/usr/bin/env bash

#trigger_build_scripts.sh
#This Script reads the $RUN_SCRIPT variable sent via the Github workflow and runs the build_gcc.sh or build_aws-sdk.sh
#It also tries to use the latest artifacts from S3 if there is no change in the build_gcc.sh or build_aws-sdk.sh

if [[ $RUN_SCRIPT == "build_gcc.sh" ]]
then
    echo "Only Run build_gcc.sh and download the latest files of the aws sdk rpm"
    echo "Fetching the latest build folder path"
    LATEST_BUILD_FOLDER=$(aws s3 ls s3://$BUCKET_NAME/$DSS_S3_BUILDS_PREFIX/ | grep -Eo '[0-9]{1,4}' | tail -1)
    echo "Executing build_gcc.sh"
    ./scripts/build_gcc.sh
    echo "Downloading aws-sdk RPM to the directory"
    aws s3 cp --recursive s3://$BUCKET_NAME/$DSS_S3_BUILDS_PREFIX/$LATEST_BUILD_FOLDER/ dss-ansible/artifacts/ --exclude "*" --include "aws-sdk-cpp-*.rpm"
elif [[ $RUN_SCRIPT == "build_aws-sdk.sh" ]]
then
    echo "Only Run build_aws-sdk.sh and download the latest files of the gcc"
    echo "Fetching the latest build folder path"
    LATEST_BUILD_FOLDER=$(aws s3 ls s3://$BUCKET_NAME/$DSS_S3_BUILDS_PREFIX/ | grep -Eo '[0-9]{1,4}' | tail -1)
    echo "Executing build_aws-sdk.sh"
    ./scripts/build_aws-sdk.sh
    echo "Downloading dss-gcc RPM to the directory"
    aws s3 cp --recursive s3://$BUCKET_NAME/$DSS_S3_BUILDS_PREFIX/$LATEST_BUILD_FOLDER/ dss-ansible/artifacts/ --exclude "*" --include "dss-gcc510-*.rpm"
elif [[ $RUN_SCRIPT == "None" ]]
then
    echo "Don't Run Any Script & download both the RPM Files to the Directory"
    echo "Fetching the latest build folder path"
    LATEST_BUILD_FOLDER=$(aws s3 ls s3://$BUCKET_NAME/$DSS_S3_BUILDS_PREFIX/ | grep -Eo '[0-9]{1,4}' | tail -1)
    aws s3 cp --recursive s3://$BUCKET_NAME/$DSS_S3_BUILDS_PREFIX/$LATEST_BUILD_FOLDER/ dss-ansible/artifacts/ --exclude "*" --include "*.rpm"
elif [[ $RUN_SCRIPT == "ALL" ]]
then
    echo "Run Both Scripts"
    echo "Executing build_gcc.sh"
    ./scripts/build_gcc.sh
    echo "Executing build_aws-sdk.sh"
    ./scripts/build_aws-sdk.sh
fi