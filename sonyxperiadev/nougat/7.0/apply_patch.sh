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
~/bin/repo init -u $AOSP_MIRROR_URL/platform/manifest.git --repo-url $AOSP_MIRROR_URL/git-repo.git -b android-7.0.0_r13
cp $ROOTDIR/sonyxperiadev/nougat/7.0/sony.xml .repo/manifests/sony.xml
sed -i "s/fetch=\".*\"/fetch=\"$SONY_MIRROR_URL\"/" .repo/manifests/sony.xml
sed -i "/^<project/ s/name=\"/name=\"sonyxperiadev\//" .repo/manifests/sony.xml
sed -i "/^<\/manifest/ s/\(.*\)/  <!-- Sony AOSP addons -->\n  <include name=\"sony.xml\"\/>\n\1/" .repo/manifests/default.xml
~/bin/repo sync

cd external/toybox && git checkout -b $GIT_BRANCH
git am `ls $ROOTDIR/sonyxperiadev/patches/platform/external/toybox/refs/changes/74/265074/1/*.patch`
git cherry-pick d3e8dd1bf56afc2277960472a46907d419e4b3da
git cherry-pick 1c028ca33dc059a9d8f18daafcd77b5950268f41
git cherry-pick cb49c305e3c78179b19d6f174ae73309544292b8
cd ../../hardware/qcom/audio && git checkout -b $GIT_BRANCH
git revert --no-edit 1c9849ca9873ec815caf52935aa772b22658219e
git am `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/79/267279/1/*.patch`
git am `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/80/267280/1/*.patch`
git am `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/35/274235/6/*.patch`
cd ../bt && git checkout -b $GIT_BRANCH
git revert --no-edit c7dc913784965e4ce705c2045f0a8b43fcd1db1c
cd ../display && git checkout -b $GIT_BRANCH
git revert --no-edit b7d1a389b00370fc9d2a7db1268ce26271ead7e2
git revert --no-edit f026d04dde743a0524235ae57e2ce8ac5364d44b
git revert --no-edit 3261eb2236252f9f2510c008fad451411a780b3b
git am `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/72/265072/1/*.patch`
git am `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/73/265073/1/*.patch`
git am `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/54/274454/1/*.patch`
git am `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/55/274455/1/*.patch`
cd ../gps && git checkout -b $GIT_BRANCH
git revert --no-edit 53bf15aab71461f81e27e6f5176afcd1a29af7d4
git revert --no-edit 486ab751599b7f8b5a2f2711d22867ad54fdc79b
cd ../media && git checkout -b $GIT_BRANCH
git revert --no-edit 9e8b76d32ece15e79ebf4b02ede869d89807eec6
cd ../keymaster && git checkout -b $GIT_BRANCH
git revert --no-edit 583ecf5ed2a4be0d05229b8c6726680c3836be8b
git am `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/70/212570/5/*.patch`
git am `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/80/212580/2/*.patch`
git am `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/61/213261/1/*.patch`
git am `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/21/245721/1/*.patch`
cd ../../../system/core && git checkout -b $GIT_BRANCH
git am `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/52/269652/1/*.patch`
cd ../../packages/apps/Nfc && git checkout -b $GIT_BRANCH
git revert --no-edit 988c3fff5470a1de3a880bd07fa438cc47e283c8
cd ../Music && git checkout -b $GIT_BRANCH
git cherry-pick 6036ce6127022880a3d9c99bd15db4c968f3e6a3
cd ../../../



~/bin/repo status
~/bin/repo forall -p -c git log --oneline android-7.0.0_r13..$GIT_BRANCH

cd $ROOTDIR