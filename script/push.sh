#!/bin/sh
#!/bin/bash
# Script to commit and push
# Copyright (C) 2016 Adrien Bioteau - All Rights Reserved
# Permission to copy and modify is granted under the GPLv3 license
# Last revised 11/20/2016

setup_git() {
  git config --global user.email "adrien.bioteau@gmail.com"
  git config --global user.name "Adrien Bioteau"
}

commit_sonyxperiadev_files() {
  git checkout master
  git add sonyxperiadev
  git status
  git commit --message "Sony Xperia AOSP build instructions `date +%m/%d/%Y`"
}

upload_files() {
  cd $2
  git remote add origin-travis https://${GH_TOKEN}@github.com/$1 > /dev/null 2>&1
  git push --quiet --set-upstream origin-travis `git rev-parse --abbrev-ref HEAD`
  cd -
}

setup_git
commit_sonyxperiadev_files
upload_files abioteau/sony-aosp-repository.git .
upload_files abioteau/vendor_nxp.git vendor/nxp
upload_files abioteau/vendor_sony.git vendor/sony
upload_files abioteau/vendor_qcom_prebuilt.git vendor/qcom/prebuilt