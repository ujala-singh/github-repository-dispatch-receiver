#!/bin/bash

PR_NUMBER="$1"
EMPTY_FLAG=false
EMPTY_FIELDS=""

# Function to add comment on PR
add_comment() {
    local PR_NUMBER="$1"
    local COMMENT="$2"
    gh pr comment $PR_NUMBER --body "$COMMENT"
}

description="$(cat /tmp/description.txt)"
jira="$(cat /tmp/jira.txt)"
pr_link="$(cat /tmp/pr_link.txt)"

# Check if description.txt is empty
if [ $description == " " ]; then
    echo "description.txt is empty"
    EMPTY_FLAG=true
    EMPTY_FIELDS+="Description"
fi

# Check if jira.txt is empty
if [ $jira == " " ]; then
    echo "jira.txt is empty"
    EMPTY_FLAG=true
    if [ -n "$EMPTY_FIELDS" ]; then
        EMPTY_FIELDS+=", Jira Links"
    else
        EMPTY_FIELDS+="Jira Links"
    fi
fi

# Check if pr_link.txt is empty
if [ $pr_link == " " ]; then
    echo "pr_link.txt is empty"
    EMPTY_FLAG=true
    if [ -n "$EMPTY_FIELDS" ]; then
        EMPTY_FIELDS+=", PR Links"
    else
        EMPTY_FIELDS+="PR Links"
    fi
fi

# Check if any file is empty
if $EMPTY_FLAG; then
    echo "One or more files are empty, failing the action..."
    add_comment "$PR_NUMBER" "Error: The following fields are empty: $EMPTY_FIELDS"
    exit 1
fi

echo "All fields are not empty, action can proceed."
