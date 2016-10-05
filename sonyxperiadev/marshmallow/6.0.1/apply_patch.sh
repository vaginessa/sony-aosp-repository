#!/bin/bash
if [0 -ne 2]
then
    [USAGE] ./apply_patch.sh <git_branch> <patch_directory>
    exit 1
fi

cd external/libnfc-nci && git checkout -b $1
git fetch https://android.googlesource.com/platform/external/libnfc-nci refs/changes/61/170861/2 &amp;&amp; git cherry-pick FETCH_HEAD
cd ../toybox && git checkout -b $1
git am $2/sonyxperiadev/patches/platform/external/toybox/refs/changes/53/265153/1/*.patch
cd ../../hardware/qcom/gps && git checkout -b $1
git revert --no-edit 5c7552e789e4f039bebb09b972425a6cb47fc8e8
cd ../display && git checkout -b $1
git am $2/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/70/238470/1/*.patch
git am $2/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/52/265052/1/*.patch
git am $2/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/53/265053/1/*.patch
git am $2/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/92/265092/1/*.patch
git am $2/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/54/274454/1/*.patch
git am $2/sonyxperiadev/patches/platform/hardware/qcom/display/refs/changes/55/274455/1/*.patch
cd ../audio && git checkout -b $1
git cherry-pick 582e0a5e965897ea54ecfa5fe206797dab577a45
git cherry-pick 48e428ecccee5c585a5bcc2297ea21802861df6e
git am $2/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/10/250410/1/*.patch
git am $2/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/13/252313/1/*.patch
git am $2/sonyxperiadev/patches/platform/hardware/qcom/audio/refs/changes/84/278484/1/*.patch
cd ../media && git checkout -b $1
git am $2/sonyxperiadev/patches/platform/hardware/qcom/media/refs/changes/90/258490/1/*.patch
cd ../keymaster && git checkout -b $1
git cherry-pick 888834f9aba0609222c6e6bbd86bd6625af28746
git am $2/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/70/212570/5/*.patch
git am $2/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/80/212580/2/*.patch
git am $2/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/61/213261/1/*.patch
git am $2/sonyxperiadev/patches/platform/hardware/qcom/keymaster/refs/changes/21/245721/1/*.patch
cd ../../broadcom/libbt && git checkout -b $1
git am $2/sonyxperiadev/patches/platform/hardware/broadcom/libbt/refs/changes/17/114817/2/*.patch
cd ../../../system/core && git checkout -b $1
git cherry-pick 9cb3d3ccf49bf0fd484563fbf611c68789d5b8a9
git am $2/sonyxperiadev/patches/platform/system/core/refs/changes/92/269692/1/*.patch
cd ../../packages/apps/Nfc && git checkout -b $1
git revert --no-edit 988c3fff5470a1de3a880bd07fa438cc47e283c8
cd ../../../../../


repo status
