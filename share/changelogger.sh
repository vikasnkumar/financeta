#!/bin/bash
LAST_REV=`git rev-list --tags --max-count=1`
LAST_DATE=`git show -s --format=%ad $LAST_REV`
#echo "$LAST_REV on $LAST_DATE"
git log --pretty=format:"%ad%n%H%n%s%n%b" --since="$LAST_DATE" > Changes

