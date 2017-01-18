#!/bin/bash
#===============================================================================

REPO_PATH=""

#===============================================================================
getScriptPath()
{
echo ${0%/*}/
}

#===============================================================================
getWorkingDirs()
{
SCRIPT_PATH=$(getScriptPath)
ROOT_PATH="../"

REALPATH_TOOL="realpath"

REPO_PATH=`${SCRIPT_PATH}${REALPATH_TOOL} ${SCRIPT_PATH}${ROOT_PATH}`
}

#===============================================================================
prepareFolders()
{

BUILD_DIR_MAIN=$REPO_PATH/build_tmp
BUILD_OUTPUT_PATH=$REPO_PATH/build_output
DEPLOY_PATH=$BUILD_OUTPUT_PATH/artifacts
REPORT_PATH=$BUILD_OUTPUT_PATH/reports
SLATHER_REPORT_PATH=$BUILD_OUTPUT_PATH/slather-reports
TEST_REPORT_PATH=$REPO_PATH/test-reports

rm -rf $BUILD_OUTPUT_PATH
rm -rf $TEST_REPORT_PATH

[[ ! -d $BUILD_OUTPUT_PATH ]] && mkdir $BUILD_OUTPUT_PATH
[[ ! -d $DEPLOY_PATH ]] && mkdir $DEPLOY_PATH
[[ ! -d $REPORT_PATH ]] && mkdir $REPORT_PATH
[[ ! -d $SLATHER_REPORT_PATH ]] && mkdir $SLATHER_REPORT_PATH
[[ ! -d $TEST_REPORT_PATH ]] && mkdir $TEST_REPORT_PATH
[[ ! -d $BUILD_DIR_MAIN ]] && mkdir $BUILD_DIR_MAIN
}

#===============================================================================
getWorkingDirs

prepareFolders

exit 0
