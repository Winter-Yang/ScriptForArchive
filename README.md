---
layout: post
title: "如何使用Shell脚本编译生成Archive文件并导出签名IPA文件。"
date: 2015-011-24 16:35
comments: true
tags:
     - Archive
     - Shell
     - IPA
     - App
     - iOS
     - Xcode
     - workspace
     
---


## 如何使用Shell脚本编译生成Archive文件并导出签名IPA文件

###1: build说明
 
  本Shell脚本用于build，XCode的workspace源代码工程，并导出成可重签名的IPA文件，用于分发测试安装文件和用于提交appstore审核的文件。实现辅助产品开发，测试的配置管理工作。
  
  使用本脚本需要以下环境 ：
  
    - Mac OS 10.9+ 
	- XCode 6.0 or later and command line tools 
	- 用于WorkSpace工程，例如使用了Cocoapods依赖库管理的工程 
	- 配置好开发证书和ad ho 证书（for Debug）和（for Release） 
	- 源代码工程中配置好Scheme名字和build 
	- 对Debug配置和Release配置设置好证书名称 
	- 确认在Xcode UI界面中能够完全build，并通过环境生成Archive和IPA，并正确签名。 
	- 在workspace文件夹下建立build文件夹

###2: 复制脚本文件到WorkSpace目录

###3: 打开终端工具，并进入workspace目录

###4: 给脚本执行权限
    - chmod 777 ./build_one_target.sh
    
###5: 修改脚本参数，源代码里已经有注释需要修改的
	- workspace name 
	- provisioningProfile
	- scheme name 
	- build_config
	
#### 代码块如下

```
	#!/bin/bash
	
	#out file
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
	clean_cmd=${clean_cmd}' clean -workspace '${build_workspace}' -scheme '${build_scheme}' 
	-configuration '${build_config}
	# clean log
	$clean_cmd >  $build_path/clean_qa.log || exit
	# Exporting xcarchive(xcode-Product-Archive)
	archive_name="ZCFundManage_${bundleShortVersion}_${timeStamp}.xcarchive"
	archive_path="$build_path/"$archive_name
	build_cmd='xcodebuild'
	build_cmd=${build_cmd}' -workspace '${build_workspace}' -scheme '${build_scheme}' 
	-destination generic/platform=iOS archive -configuration '${build_config}' ONLY_ACTIVE_ARCH=NO -archivePath 
	'${archive_path}
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
	ipa_cmd=${ipa_cmd}' -exportArchive -exportFormat ipa -archivePath '${archive_path}' 
	-exportPath '${ipa_path}' -exportProvisioningProfile '${provisioningProfile}
	
	echo "** Exporting ZF ** to the ${ipa_path}"
	echo ${ipa_cmd}
	eval ${ipa_cmd} > $build_path/export_ipa_qa.log || exit
	if [ ! -f "${ipa_path}" ]; then
	    echo "** Error! Export IPA ZF FAILED ** Please check $build_path/export_ipa_qa.log."
	    exit 2
	else
	    echo "** Export IPA ZF SUCCEEDED ** to the ${ipa_path}"
	fi

```	
###6: 执行脚本
	./build_one_target.sh
	

大一些的工程，大约3-5分钟完成。 
完成之后，在workspace目录下的build目录下，会有如下两个主要文件。 
targetname_QA_20150420_094731.xcarchive 
targetname_QA_adhoc_v2.1.1_b44_rev7849_t20150420_094731.ipa

xcarchive文件很重要，可以用于不同证书签名的ipa文件 
ipa文件使用的是adhoc 证书导出，用于真机测试分发。证书名称在源代码中配置。根据不同的产品bundle id，做相应修改，这里的名称和证书，仅做演示参考，不具有任何商业意义


参考：http://blog.csdn.net/vieri_ch/article/details/45147027
github：https://github.com/Winter-Yang/ScriptForArchive
blog：

<!--more-->
---
