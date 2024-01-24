#!/bin/bash

# Get the list of tags from the remote repository
tags=$(git ls-remote --tags origin | awk '{print $2}')

# Loop over each tag
for tag in $tags; do
    # Extract tag name from the full reference
    tag_name=$(basename "$tag")

    # Check if the tag name doesn't contain "-base"
    if [[ ! "$tag_name" =~ -base ]]; then
        # Get the commit date of the tag
        tag_date=$(git log -1 --format=%ai "$tag_name" | awk '{print $1}')
        echo "$tag_date"
        # Calculate the age of the tag in seconds
        tag_date_seconds=$(date -j -f "%Y-%m-%d" "$tag_date" "+%s")
        echo "$tag_date_seconds"
        # Get the current date in seconds
        current_date_seconds=$(date "+%s")

        # Calculate the difference in seconds
        age_seconds=$((current_date_seconds - tag_date_seconds))

        # Check if the tag is older than 20 days
        if ((age_seconds > 1728000)); then
            echo "Deleting the tag $tag_name"
            git tag -d "$tag_name"
            git push origin ":refs/tags/$tag_name"
        fi
    fi
done

# Find and remove releases older than 20 days
current_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

curl -s -H "Authorization: Bearer $GH_TOKEN" "https://api.github.com/repos/ujala-singh/github-repository-dispatch-receiver/releases" | jq -r '.[] | "\(.tag_name) \(.created_at)"' | while read -r tag created_at; do
    if [[ ! "$tag" =~ -base ]]; then
        release_date=$created_at
        echo "Release Date: $release_date"
        # Calculate the age of the tag in seconds
        release_date_seconds=$(date -j -f "%Y-%m-%d" "$release_date" "+%s")
        echo "Release Date Seconds: $release_date_seconds"
        # Get the current date in seconds
        current_date_seconds=$(date "+%s")
        # Calculate the difference in seconds
        age_seconds=$((current_date_seconds - release_date_seconds))
        if ((age_seconds > 1728000)); then
            echo "Release $tag created on $release_date is older than 20 days."
            echo "Deleting the release $release"
            gh release delete "$release" --yes
        else
            echo "Release $tag created on $release_date is within the last 20 days."
        fi
    fi
done
