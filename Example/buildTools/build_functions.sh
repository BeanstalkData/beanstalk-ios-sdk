#!/bin/bash
#==============================================================================


#==============================================================================
# constants
PLIST_BUDDY_ED="/usr/libexec/PlistBuddy"

DIR_PATH_INFO_PLIST="/BeanstalkEngageiOSSDK/"

#==============================================================================
# constants - build targets

BUILD_TARGET_DEV="BeanstalkEngageiOSSDK_Example"

#==============================================================================
# constants - schemes
SCHEME_NAME_DEBUG="BeanstalkEngageiOSSDK-Example"

#==============================================================================
# constants - plists
PLIST_NAME_DEBUG="Info.plist"

#==============================================================================
# constants - build actions
BUILD_ACTION_BUILD="build"
BUILD_ACTION_TEST="test"

#==============================================================================
convert_string_to_lowercase()
{
echo $1 | tr '[A-Z]' '[a-z]'
}

#==============================================================================
# function arguments
getListOfTargets()
{

echo "$BUILD_TARGET_DEV"

}

#==============================================================================
# function arguments
getProjectWorkspaceName()
{

PARAM_DEVICE_TARGET=$1

echo "BeanstalkEngageiOSSDK.xcworkspace"

}

#==============================================================================
# function arguments
getProjectName()
{

PARAM_DEVICE_TARGET=$1

echo "BeanstalkEngageiOSSDK.xcodeproj"

}

#==============================================================================
# function arguments
# $1 - TARGET NAME
getProjectPlistName()
{

BUILD_TARGET_NAME=$1

if [ $BUILD_TARGET_NAME == $BUILD_TARGET_DEV ] ; then
    echo $PLIST_NAME_DEBUG
fi

}

#===============================================================================
# function arguments
# $1 - TARGET NAME
parseSchemeName()
{
BUILD_TARGET_NAME=$1

SCHEME=''

if [ $BUILD_TARGET_NAME == $BUILD_TARGET_DEV ] ; then
echo $SCHEME_NAME_DEBUG
fi

echo $PROJECT
}

#===============================================================================
# function arguments
# $1 - PARAM_PLIST_FILE
getBuildVersion()
{
PARAM_PLIST_FILE=$1

# Get Bundle version
BUNDLE_VERSION=$($PLIST_BUDDY_ED -c "Print CFBundleVersion:" ${REPO_PATH}${DIR_PATH_INFO_PLIST}${PARAM_PLIST_FILE})

BUILD_VERSION=`echo $BUNDLE_VERSION | cut -d'.' -f 3`

echo $BUILD_VERSION
}

#===============================================================================
# function arguments
# $1 - PARAM_PLIST_FILE
getBundleName()
{
echo "BeanstalkEngageiOSSDK"
}

#===============================================================================
