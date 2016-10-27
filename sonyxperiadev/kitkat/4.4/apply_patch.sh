#!/bin/bash

cd `dirname $0`/../../..
ROOTDIR=`pwd`

if [ $# -ne 4 ]
then
    echo "[USAGE] ./apply_patch.sh <aosp_workspace> <aosp_mirror> <sony_mirror> <git_branch>"
    exit 1
fi

AOSP_WORKSPACE=$1
AOSP_MIRROR_URL=$2
SONY_MIRROR_URL=$3
GIT_BRANCH=$4

mkdir -p $AOSP_WORKSPACE
cd $AOSP_WORKSPACE
~/bin/repo init -u $AOSP_MIRROR_URL/platform/manifest.git --repo-url $AOSP_MIRROR_URL/git-repo.git -b android-4.4.4_r2
cp $ROOTDIR/sonyxperiadev/kitkat/4.4/sony.xml .repo/manifests/sony.xml
sed -i "s/fetch=\".*\"/fetch=\"$SONY_MIRROR_URL\"/" .repo/manifests/sony.xml
sed -i "/^<project/ s/name=\"/name=\"sonyxperiadev\//" .repo/manifests/sony.xml
sed -i "/^<\/manifest/ s/\(.*\)/  <!-- Sony AOSP addons -->\n  <include name=\"sony.xml\"\/>\n\1/" .repo/manifests/default.xml
~/bin/repo sync

cd build && git checkout -b $GIT_BRANCH
git cherry-pick 612e2cd0e8c79bc6ab46d13cd96c01d1be382139
cd ..
cd hardware/qcom/bt && git checkout -b $GIT_BRANCH
git cherry-pick 5a6037f1c8b5ff0cf263c9e63777444ba239a056
cd ../../../
cd hardware/qcom/audio && git checkout -b $GIT_BRANCH
git cherry-pick 00f6869a0981b570f90dbf39981734f36eafdfa9
git cherry-pick 20bcfa8b451941843e8eabb5308f1f04f07d347a
cd ../../../
cd hardware/qcom/display && git checkout -b $GIT_BRANCH
git cherry-pick d5ae1812a9509d8849f4494fcf17f68bf33f533c
git cherry-pick 5898f2e789800fb196ce94532eef033e7d7e60b3
cd ../../../

~/bin/repo status
~/bin/repo forall -p -c git log --oneline android-4.4.4_r2..$GIT_BRANCH

cd $ROOTDIR