#!/bin/bash
# Script to apply Sony Xperia patches
# Copyright (C) 2017 Adrien Bioteau - All Rights Reserved
# Permission to copy and modify is granted under the GPLv3 license
# Last revised 11/05/2017

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
~/bin/repo init -u $AOSP_MIRROR_URL/platform/manifest.git --repo-url $REPO_MIRROR_URL/git-repo.git -b android-6.0.1_r81

sed -i -e "/^  <!-- Sony AOSP addons -->/d; /^<\/manifest/ s/\(.*\)/  <!-- Sony AOSP addons -->\n\1/" .repo/manifests/default.xml
git clone $GITHUB_MIRROR_URL/abioteau/local_manifests
cd local_manifests
git checkout -f m-mr1
sed -i "s/fetch=\".*:\/\/github.com\/\(.*\)\"/fetch=\"$(echo $GITHUB_MIRROR_REL_URL | sed 's/\//\\\//g')\/\1\"/" *.xml
find *.xml | xargs -I {} sed -i -e "/^  <include name=\"{}\"\/>/d; /^<\/manifest/ s/\(.*\)/  <include name=\"{}\"\/>\n\1/" ../.repo/manifests/default.xml
cp *.xml ../.repo/manifests/.
cd ..
rm -rf local_manifests

~/bin/repo sync -j $NB_CORES
~/bin/repo manifest -o manifest.xml -r

cd bionic && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/bionic/refs/changes/50/234150/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/bionic/refs/changes/53/236953/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/bionic/refs/changes/90/497890/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/bionic/refs/changes/95/506395/1/*.patch`
cd ../external/libnfc-nci && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/libnfc-nci/refs/changes/61/170861/2/*.patch`
cd ../toybox && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/external/toybox/refs/changes/53/265153/1/*.patch`
cd ../../hardware/qcom/gps && repo start $GIT_BRANCH .
git revert --no-edit --no-commit 5c7552e789e4f039bebb09b972425a6cb47fc8e8 && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit -m "`cat .git/MERGE_MSG`" --author "`git log -1 5c7552e789e4f039bebb09b972425a6cb47fc8e8 | grep "Author: " | sed -e "s/Author: //"`" --date "`git log -1 5c7552e789e4f039bebb09b972425a6cb47fc8e8 | grep "Date:   " | sed -e "s/Date:   //"`" && unset GIT_COMMITTER_DATE
cd ../display && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/70/238470/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/52/265052/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/53/265053/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/92/265092/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/54/274454/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/55/274455/1/*.patch`
cd ../audio && repo start $GIT_BRANCH .
git format-patch -o /tmp/582e0a5e965897ea54ecfa5fe206797dab577a45 -1 582e0a5e965897ea54ecfa5fe206797dab577a45 && git am -3 --committer-date-is-author-date /tmp/582e0a5e965897ea54ecfa5fe206797dab577a45/0001-*.patch && rm -rf /tmp/582e0a5e965897ea54ecfa5fe206797dab577a45
git format-patch -o /tmp/48e428ecccee5c585a5bcc2297ea21802861df6e -1 48e428ecccee5c585a5bcc2297ea21802861df6e && git am -3 --committer-date-is-author-date /tmp/48e428ecccee5c585a5bcc2297ea21802861df6e/0001-*.patch && rm -rf /tmp/48e428ecccee5c585a5bcc2297ea21802861df6e
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/10/250410/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/13/252313/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/84/278484/1/*.patch`
cd ../media && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/media/refs/changes/90/258490/1/*.patch`
cd ../keymaster && repo start $GIT_BRANCH .
git format-patch -o /tmp/888834f9aba0609222c6e6bbd86bd6625af28746 -1 888834f9aba0609222c6e6bbd86bd6625af28746 && git am -3 --committer-date-is-author-date /tmp/888834f9aba0609222c6e6bbd86bd6625af28746/0001-*.patch && rm -rf /tmp/888834f9aba0609222c6e6bbd86bd6625af28746
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/70/212570/5/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/80/212580/2/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/61/213261/1/*.patch`
cd ../../libhardware && repo start $GIT_BRANCH .
git format-patch -o /tmp/48f57ad4f470ebcb71ac10df4e5e0953a6cfacd8 -1 48f57ad4f470ebcb71ac10df4e5e0953a6cfacd8 && git am -3 --committer-date-is-author-date /tmp/48f57ad4f470ebcb71ac10df4e5e0953a6cfacd8/0001-*.patch && rm -rf /tmp/48f57ad4f470ebcb71ac10df4e5e0953a6cfacd8
cd ../broadcom/libbt && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/broadcom/libbt/refs/changes/17/114817/2/*.patch`
cd ../../../system/core && repo start $GIT_BRANCH .
git format-patch -o /tmp/9cb3d3ccf49bf0fd484563fbf611c68789d5b8a9 -1 9cb3d3ccf49bf0fd484563fbf611c68789d5b8a9 && git am -3 --committer-date-is-author-date /tmp/9cb3d3ccf49bf0fd484563fbf611c68789d5b8a9/0001-*.patch && rm -rf /tmp/9cb3d3ccf49bf0fd484563fbf611c68789d5b8a9
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/92/269692/1/*.patch`
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/system/core/refs/changes/38/327438/1/*.patch`
cd ../../packages/apps/Nfc && repo start $GIT_BRANCH .
git revert --no-edit --no-commit 988c3fff5470a1de3a880bd07fa438cc47e283c8 && export GIT_COMMITTER_DATE="`date +"2017-01-01 08:00:00 +0200"`" && git commit -m "`cat .git/MERGE_MSG`" --author "`git log -1 988c3fff5470a1de3a880bd07fa438cc47e283c8 | grep "Author: " | sed -e "s/Author: //"`" --date "`git log -1 988c3fff5470a1de3a880bd07fa438cc47e283c8 | grep "Date:   " | sed -e "s/Date:   //"`" && unset GIT_COMMITTER_DATE
cd ../../../
cd frameworks/base && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/frameworks/base/refs/changes/31/229331/1/*.patch`
cd ../opt/telephony && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/frameworks/opt/telephony/refs/changes/52/268352/1/*.patch`
cd ../../../hardware/ril && repo start $GIT_BRANCH .
git am -3 --committer-date-is-author-date `ls $ROOTDIR/sonyxperiadev/patches/platform/hardware/ril/refs/changes/11/229011/1/*.patch`
cd ../../



cd $ROOTDIR
