#!/bin/bash

REPO_URL="https://github.com/ujala-singh/github-repository-dispatch-receiver.git"

# Get the list of tags
TAGS=$(git ls-remote --tags $REPO_URL | awk -F/ '{print $NF}')

# Calculate the date 2 days ago
TWO_DAYS_AGO=$(date -u -v-2d "+%Y-%m-%dT%H:%M:%SZ")

for TAG in $TAGS; do
    # Get the tag date
    TAG_DATE=$(git log -1 --format=%ai $TAG)

    # Compare the tag date with the date 2 days ago
    if [ "$(date -u -d "$TAG_DATE" "+%Y-%m-%dT%H:%M:%SZ")" \< "$TWO_DAYS_AGO" ]; then
        echo "Deleting tag: $TAG"
        #git push --delete origin $TAG
        #git tag --delete $TAG
    fi
done

# Push the changes to the remote repository
#git push origin --tags
