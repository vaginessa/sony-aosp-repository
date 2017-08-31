#!/bin/bash
# Script to apply Sony Xperia patches
# Copyright (C) 2017 Adrien Bioteau - All Rights Reserved
# Permission to copy and modify is granted under the GPLv3 license
# Last revised 08/29/2017

relpath () {
    [ $# -ge 1 ] && [ $# -le 2 ] || return 1
    current="${2:+"$1"}"
    target="${2:-"$1"}"
    if [[ "$target" = "http"* ]] || [[ "$current" = "http"* ]]; then
        echo "$target"
        return 0
    fi
    [ "$target" != . ] || target=/
    target="/${target##/}"
    [ "$current" != . ] || current=/
    current="${current:="/"}"
    current="/${current##/}"
    appendix="${target##/}"
    relative=''
    while appendix="${target#"$current"/}"
        [ "$current" != '/' ] && [ "$appendix" = "$target" ]; do
        if [ "$current" = "$appendix" ]; then
            relative="${relative:-.}"
            echo "${relative#/}"
            return 0
        fi
        current="${current%/*}"
        relative="$relative${relative:+/}.."
    done
    relative="$relative${relative:+${appendix:+/}}${appendix#/}"
    echo "$relative"
}

cd `dirname $0`/../../..
ROOTDIR=`pwd`
NB_CORES=`grep -c ^processor /proc/cpuinfo`

if [ $# -ne 5 ]
then
    echo "[USAGE] ./apply_patch.sh <aosp_workspace> <aosp_mirror> <repo_mirror> <github_mirror> <git_branch>"
    exit 1
fi

AOSP_WORKSPACE=$1
AOSP_MIRROR_URL=$2
REPO_MIRROR_URL=$3
GITHUB_MIRROR_URL=$4
GITHUB_MIRROR_REL_URL=$(relpath $AOSP_MIRROR_URL/platform $GITHUB_MIRROR_URL)
GIT_BRANCH=$5

mkdir -p $AOSP_WORKSPACE
cd $AOSP_WORKSPACE
~/bin/repo init -u $AOSP_MIRROR_URL/platform/manifest.git --repo-url $REPO_MIRROR_URL/git-repo.git -b android-7.1.2_r29

sed -i -e "/^  <!-- Sony AOSP addons -->/d; /^<\/manifest/ s/\(.*\)/  <!-- Sony AOSP addons -->\n\1/" .repo/manifests/default.xml
git clone $GITHUB_MIRROR_URL/sonyxperiadev/local_manifests
cd local_manifests
git checkout -f n-mr1_3.18
sed -i "s/fetch=\".*:\/\/github.com\/\(.*\)\"/fetch=\"$(echo $GITHUB_MIRROR_REL_URL | sed 's/\//\\\//g')\/\1\"/" *.xml
find *.xml | xargs -I {} sed -i -e "/^  <include name=\"{}\"\/>/d; /^<\/manifest/ s/\(.*\)/  <include name=\"{}\"\/>\n\1/" ../.repo/manifests/default.xml
cp *.xml ../.repo/manifests/.
cd ..
rm -rf local_manifests
git clone $GITHUB_MIRROR_URL/abioteau/vendor_manifests
cd vendor_manifests
git checkout -f n-mr1_3.18
sed -i "s/fetch=\".*:\/\/github.com\/\(.*\)\"/fetch=\"$(echo $GITHUB_MIRROR_REL_URL | sed 's/\//\\\//g')\/\1\"/" *.xml
find *.xml | xargs -I {} sed -i -e "/^  <include name=\"{}\"\/>/d; /^<\/manifest/ s/\(.*\)/  <include name=\"{}\"\/>\n\1/" ../.repo/manifests/default.xml
cp *.xml ../.repo/manifests/.
cd ..
rm -rf vendor_manifests

~/bin/repo sync -j $NB_CORES
~/bin/repo manifest -o manifest.xml -r

cd external/toybox && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/toybox/refs/changes/74/265074/1/*.patch`
git format-patch -o /tmp/d3e8dd1bf56afc2277960472a46907d419e4b3da -1 d3e8dd1bf56afc2277960472a46907d419e4b3da && git am -3 --committer-date-is-author-date /tmp/d3e8dd1bf56afc2277960472a46907d419e4b3da/0001-*.patch && rm -rf /tmp/d3e8dd1bf56afc2277960472a46907d419e4b3da
git format-patch -o /tmp/1c028ca33dc059a9d8f18daafcd77b5950268f41 -1 1c028ca33dc059a9d8f18daafcd77b5950268f41 && git am -3 --committer-date-is-author-date /tmp/1c028ca33dc059a9d8f18daafcd77b5950268f41/0001-*.patch && rm -rf /tmp/1c028ca33dc059a9d8f18daafcd77b5950268f41
git format-patch -o /tmp/cb49c305e3c78179b19d6f174ae73309544292b8 -1 cb49c305e3c78179b19d6f174ae73309544292b8 && git am -3 --committer-date-is-author-date /tmp/cb49c305e3c78179b19d6f174ae73309544292b8/0001-*.patch && rm -rf /tmp/cb49c305e3c78179b19d6f174ae73309544292b8
cd ../libnfc-nci && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/libnfc-nci/refs/changes/52/371052/1/*.patch`
cd ../../hardware/qcom/audio && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/91/294291/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/35/274235/9/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/86/333386/1/*.patch`
cd ../../../system/core && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/52/269652/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/12/373812/1/*.patch`
cd ../../packages/apps/Music && repo start $GIT_BRANCH .
git format-patch -o /tmp/6036ce6127022880a3d9c99bd15db4c968f3e6a3 -1 6036ce6127022880a3d9c99bd15db4c968f3e6a3 && git am -3 --committer-date-is-author-date /tmp/6036ce6127022880a3d9c99bd15db4c968f3e6a3/0001-*.patch && rm -rf /tmp/6036ce6127022880a3d9c99bd15db4c968f3e6a3
cd ../../../frameworks/av && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/frameworks/av/refs/changes/92/384692/2/*.patch`
cd ../../



cd $ROOTDIR
