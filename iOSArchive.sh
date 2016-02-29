#!/bin/bash

# out file
AppInfoPath="/Users/YangWD/Desktop/AppTest"

# workspace name， must be xcworkspace
build_workspace="ZCFundManage.xcworkspace"

# project name and path
project_path=$(pwd)
project_name=$(ls | grep xcodeproj | awk -F.xcodeproj '{print $1}')

# Info.plist
app_infoplist_path=${project_path}/${project_name}/Info.plist

# bundleShortVersion
bundleShortVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" "${app_infoplist_path}")

# bundleVersion
bundleVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" "${app_infoplist_path}")

# scheme name
build_scheme="ZCFundManage"

# buidl config. the default is Debug|Release
build_config="Release"

/usr/libexec/PlistBuddy -c "set :CFBundleIdentifier ${oldAppFile}" "$app_infoplist_path"    
/usr/libexec/PlistBuddy -c "set :CFBundleName ${appFile}" "$app_infoplist_path"
/usr/libexec/PlistBuddy -c "set :CFBundleDisplayName ${appFile}" "$app_infoplist_path"

# provisiong profile name
provisioningProfile='"XC Ad Hoc: com.xxxxxx.yyyyyy"'
# creat Time
timeStamp="$(date +"%Y%m%d_%H%M%S")"
echo "*****打包时间:$timeStamp"
if [ ! -d "$project_path/$build_workspace" ]; then
    echo  "Error!Current path is not a xcode workspace.Please check, or do not use -w option."
    exit 2
fi
# clean
clean_cmd='xcodebuild'
clean_cmd=${clean_cmd}' clean -workspace '${build_workspace}' -scheme '${build_scheme}' -configuration '${build_config}
# clean log
$clean_cmd >  $build_path/clean_qa.log || exit
# Exporting xcarchive(xcode-Product-Archive)
archive_name="ZCFundManage_${bundleShortVersion}_${timeStamp}.xcarchive"
archive_path="$build_path/"$archive_name
build_cmd='xcodebuild'
build_cmd=${build_cmd}' -workspace '${build_workspace}' -scheme '${build_scheme}' -destination generic/platform=iOS archive -configuration '${build_config}' ONLY_ACTIVE_ARCH=NO -archivePath '${archive_path}
echo "** Archiving ZF ** to the ${archive_path}"

# build log
$build_cmd > $build_path/build_archive_qa.log || exit
if [ ! -d "${archive_path}" ]; then
    echo  "** Error! ARCHIVE ZF FAILED ** Please check $build_path/build_archive_qa.log."
    exit 2
else
    echo "** ARCHIVE ZF SUCCEEDED ** to the ${archive_path}"
fi 

# Exporting ipa
ipa_name="ZCFundManage_${bundleShortVersion}_${timeStamp}.ipa"
ipa_path="$build_path/"$ipa_name 
ipa_cmd='xcodebuild'
ipa_cmd=${ipa_cmd}' -exportArchive -exportFormat ipa -archivePath '${archive_path}' -exportPath '${ipa_path}' -exportProvisioningProfile '${provisioningProfile}

echo "** Exporting ZF ** to the ${ipa_path}"
echo ${ipa_cmd}
eval ${ipa_cmd} > $build_path/export_ipa_qa.log || exit
if [ ! -f "${ipa_path}" ]; then
    echo "** Error! Export IPA ZF FAILED ** Please check $build_path/export_ipa_qa.log."
    exit 2
else
    echo "** Export IPA ZF SUCCEEDED ** to the ${ipa_path}"
fi




















