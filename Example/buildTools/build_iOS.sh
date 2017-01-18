#!/bin/bash
#===============================================================================

XCODEBUILD=xcodebuild

BUILD_CONFIGURATION="Debug"
WORKSPACE_NAME=""
PROJECT_NAME=""
SCHEME=""
PLIST_FILE=""

#===============================================================================
BUILD_DIR=""
LOG_DIR=""

DATE_STR="0"

CURR_DIR=""
SCRIPT_PATH=""
REPO_PATH=""

PCH_ROOT=""
DERIVED_PATH=""
ARCHIVE_PATH=""

BUILD_ACTION=""
BUNDLE_VERSION=""
BUILD_OUTPUT_PATH=""
DEPLOY_PATH=""
REPORT_PATH=""
TEST_PATH=""
SLATHER_PATH=""

BUILD_TARGET_NAME=""

#===============================================================================
getScriptPath()
{
echo ${0%/*}/
}

#===============================================================================
getWorkingDirs()
{
CURR_DIR=$PWD

SCRIPT_PATH=$(getScriptPath)
ROOT_PATH="../"

REALPATH_TOOL="realpath"

REPO_PATH=`${SCRIPT_PATH}${REALPATH_TOOL} ${SCRIPT_PATH}${ROOT_PATH}`

}

#===============================================================================
getWorkingDirs

. ${SCRIPT_PATH}/build_functions.sh



#===============================================================================
print_usage()
{
  LIST_OF_TARGETS=$(getListOfTargets)

  echo "Usage: $0 --build_action=[build, test] --target_name=[$LIST_OF_TARGETS]"
  exit 1
}

#===============================================================================
parse_cmd_line()
{
  for i in $*
  do
      case $i in
      --build_action=*)
         BUILD_ACTION=${i#*=}
      ;;
      --target_name=*)
       BUILD_TARGET_NAME=${i#*=}
       echo "BUILD_TARGET_NAME = $BUILD_TARGET_NAME"
      ;;
      *)
      # unknown option
      BUILD_TARGET_NAME=""
      break
      ;;
      esac
  done

  if [ -z "$BUILD_TARGET_NAME" ]
  then
    print_usage $0
    return 1
  fi

  if [ -z "$BUILD_ACTION" ]
  then
    BUILD_ACTION=$BUILD_ACTION_BUILD
  fi

  WORKSPACE_NAME=$(getProjectWorkspaceName)
  PROJECT_NAME=$(getProjectName)
  SCHEME=$(parseSchemeName $BUILD_TARGET_NAME)
  PLIST_FILE=$(getProjectPlistName $BUILD_TARGET_NAME)

  echo "BUILD_ACTION = $BUILD_ACTION"
  echo "WORKSPACE_NAME = $WORKSPACE_NAME"
  echo "PROJECT_NAME = $PROJECT_NAME"
  echo "SCHEME = $SCHEME"
  echo "PLIST_FILE = $PLIST_FILE"
}

#===============================================================================
unlockKeychain()
{
   security unlock-keychain -u /Library/Keychains/System.keychain
#   security unlock-keychain -pbuild ~/Library/Keychains/login.keychain
}

#===============================================================================
prepareDir()
{
DATE_STR=`date +"%Y%m%d%H%M%S"`

BUILD_DIR_MAIN=$REPO_PATH/build_tmp
BUILD_OUTPUT_PATH=$REPO_PATH/build_output
DEPLOY_PATH=$BUILD_OUTPUT_PATH/artifacts
REPORT_PATH=$BUILD_OUTPUT_PATH/reports
TEST_PATH=$REPO_PATH/test-reports
SLATHER_PATH=$BUILD_OUTPUT_PATH/slather-reports

SCHEME_STR=${SCHEME// /_}

BUILD_DIR=$BUILD_DIR_MAIN/$SCHEME_STR.build.$DATE_STR
LOG_DIR=$BUILD_DIR/Logs
PCH_ROOT=$BUILD_DIR/Pch.root
DERIVED_PATH=$BUILD_DIR/Derived
ARCHIVE_PATH=$BUILD_DIR/Archive

echo "BUILD_DIR = $BUILD_DIR"
echo "LOG_DIR = $LOG_DIR"
echo "PCH_ROOT = $PCH_ROOT"

[[ ! -d $BUILD_DIR ]] && mkdir -pv $BUILD_DIR
[[ ! -d $LOG_DIR ]] && mkdir -pv $LOG_DIR
}



#===============================================================================
# function arguments
# $1 - BUILD_PRODUCT_NAME
buildProject()
{
BUILD_PRODUCT_NAME=$1

cd $REPO_PATH


if [ $BUILD_ACTION == $BUILD_ACTION_BUILD ] ; then
    $XCODEBUILD -workspace $WORKSPACE_NAME -scheme "$SCHEME" -sdk "iphoneos" \
    -derivedDataPath $DERIVED_PATH -archivePath $ARCHIVE_PATH -verbose -configuration $BUILD_CONFIGURATION clean archive 1>$LOG_DIR/$BUILD_PRODUCT_NAME.Build.log 2>&1
else

    $XCODEBUILD -workspace $WORKSPACE_NAME -scheme "$SCHEME" -sdk "iphonesimulator"  \
    -destination "platform=iOS Simulator,name=iPhone 6,OS=latest" VALID_ARCHS=x86_64\
    -derivedDataPath $DERIVED_PATH -verbose -configuration $BUILD_CONFIGURATION clean test 1>$LOG_DIR/$BUILD_PRODUCT_NAME.Test.log 2>&1

    cat $LOG_DIR/$BUILD_PRODUCT_NAME.Test.log | $SCRIPT_PATH/ocunit2junit 1>/dev/null

    slather coverage --verbose --input-format profdata --cobertura-xml  \
    --binary-file $DERIVED_PATH/Build/Intermediates/CodeCoverage/Products/${BUILD_CONFIGURATION}-iphonesimulator/BeanstalkEngageiOSSDK.common/${BUILD_PRODUCT_NAME}.framework/${BUILD_PRODUCT_NAME}  \
    --build-directory $DERIVED_PATH --output-directory $SLATHER_PATH        \
    --scheme $SCHEME --workspace $WORKSPACE_NAME $PROJECT_NAME
fi


BUILD_RES=$?

cd $CURR_DIR

return $BUILD_RES
}


#===============================================================================
# function arguments
# $1 - BUILD_PRODUCT_NAME
# $2 - DEPLOY_PRODUCT_NAME
deployFiles()
{
BUILD_PRODUCT_NAME=$1
DEPLOY_PRODUCT_NAME=$2

if [ -f $LOG_DIR/$BUILD_PRODUCT_NAME.Build.log ] ; then
cp $LOG_DIR/$BUILD_PRODUCT_NAME.Build.log $REPORT_PATH/$DEPLOY_PRODUCT_NAME.Build.log
fi

if [ -f $LOG_DIR/$BUILD_PRODUCT_NAME.Test.log ] ; then
cp $LOG_DIR/$BUILD_PRODUCT_NAME.Test.log $REPORT_PATH/$DEPLOY_PRODUCT_NAME.Test.log
fi

}

#===============================================================================
buildAndDeploy()
{
BUILD_PRODUCT_NAME=$(getBundleName $PLIST_FILE)
echo BUILD_PRODUCT_NAME=$BUILD_PRODUCT_NAME

buildProject $BUILD_PRODUCT_NAME
BUILD_RES=$?

DEPLOY_PRODUCT_NAME="$BUILD_PRODUCT_NAME"

deployFiles $BUILD_PRODUCT_NAME $DEPLOY_PRODUCT_NAME

return $BUILD_RES
}

#===============================================================================
on_exit()
{

[[ -d $BUILD_DIR ]] && rm -rf $BUILD_DIR
    echo
}

#===============================================================================
trap on_exit EXIT

parse_cmd_line $*

unlockKeychain

prepareDir

buildAndDeploy
BUILD_RES=$?

exit $BUILD_RES
