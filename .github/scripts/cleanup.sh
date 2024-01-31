#!/bin/bash

REPO_URL="https://github.com/ujala-singh/github-repository-dispatch-receiver.git"

# Get the list of tags
TAGS=$(git ls-remote --tags $REPO_URL | awk -F/ '{print $NF}')

# Calculate the date 5 days ago
FIVE_DAYS_AGO=$(date -u --date='-5 days' "+%Y-%m-%dT%H:%M:%SZ")

for TAG in $TAGS; do
    # Get the tag date
    TAG_DATE=$(git log -1 --format=%ai $TAG)
    # Check if the tag name doesn't contain "-base"
    if [[ ! "$TAG" =~ -base ]]; then
        # Compare the tag date with the date 5 days ago
        if [ "$(date -u --date="$TAG_DATE" "+%Y-%m-%dT%H:%M:%SZ")" \< "$FIVE_DAYS_AGO" ]; then
            echo "Deleting tag: $TAG"
            git push --delete origin $TAG
            git tag --delete $TAG
            echo "Deleting the release $TAG"
            gh release delete "$TAG" --yes
        fi
    fi
done

# Push the changes to the remote repository
git push origin --tags
