#!/bin/bash

# exit script immediately if a command fails
set -e

# Some people require insecure proxies
HTTP=https
if [ "$INSECURE_PROXY" = "TRUE" ]; then
    HTTP=http
fi

ANDROOT=$PWD

pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

apply_gerrit_cl_commit() {
    _ref=$1
    _commit=$2
    # Check whether the commit is already stored
    if [ -z $(git rev-parse --quiet --verify $_commit^{commit}) ]
    # If not, fetch the ref from $LINK
    then
        git fetch $LINK $_ref
        _fetched=$(git rev-parse FETCH_HEAD)
        if [ "$_fetched" != "$_commit" ]
        then
            echo "$(pwd): WARNING:"
            echo -e "\tFetched commit is not \"$_commit\""
            echo -e "\tPlease update the commit hash for $_ref to \"$_fetched\""
        fi
        git cherry-pick FETCH_HEAD
    else
        git cherry-pick $_commit
    fi
}

pushd $ANDROOT/hardware/interfaces
LINK=$HTTP && LINK+="://android.googlesource.com/platform/hardware/interfaces"
# [android10-dev] thermal: Init module to NULL
# Change-Id: I250006ba6fe9d91e765dde1e4534d5d87aaab879
apply_gerrit_cl_commit refs/changes/90/1320090/1 3861f7958bec14685cde5b8fee4e590cece76d68
popd

pushd $ANDROOT/system/extras
LINK=$HTTP && LINK+="://android.googlesource.com/platform/system/extras"
# verity: Do not increment data when it is nullptr.
apply_gerrit_cl_commit refs/changes/52/1117052/1 c82514bd034f214b16d273b10c676dd63a9e603b
popd

pushd $ANDROOT/system/sepolicy
LINK=$HTTP && LINK+="://android.googlesource.com/platform/system/sepolicy"
# property_contexts: Remove compatible guard
apply_gerrit_cl_commit refs/changes/00/1185400/1 668b7bf07a69e51a6c190d6b366d574b9e4af1d4
popd

# because "set -e" is used above, when we get to this point, we know
# all patches were applied successfully.
echo "+++ all patches applied successfully! +++"

set +e

