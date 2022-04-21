#!/usr/bin/env bash

set -e

# OSX GUI apps do not pick up environment variables the same way as Terminal apps and there are no easy solutions,
# especially as Apple changes the GUI app behavior every release (see https://stackoverflow.com/q/135688/483528). As a
# workaround to allow GitHub Desktop to work, add this (hopefully harmless) setting here.
original_path=$PATH
export PATH=$PATH:/usr/local/bin

# Since trufflehog only supports directory based scanning we want to scan the minimal number of times by removing duplicate directories.
# This means we'll still end up scanning some files not included in the commit but this is the best we can do for now.
FOUND_CREDENTIALS=0
PATHS=()

# strip out filenames and just get the paths
for file in "$@"; do
  PATHS+=("${file%/*}")
done

# return a new array of only unique paths https://stackoverflow.com/questions/13648410/how-can-i-get-unique-values-from-an-array-in-bash
UNIQ_PATHS=" " read -r -a PATHS <<< "$(echo "${PATHS[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')"

for uniq_path in $UNIQ_PATHS; do
  trufflehog filesystem --no-update --directory="$uniq_path" || FOUND_CREDENTIALS=$?
done

# reset path to the original value
export PATH=$original_path

exit ${FOUND_CREDENTIALS}
