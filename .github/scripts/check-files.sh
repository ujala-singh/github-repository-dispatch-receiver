#!/bin/bash

PR_NUMBER="$1"

# Function to add comment on PR
add_comment() {
    local PR_NUMBER="$1"
    local COMMENT="$2"
    gh pr comment $PR_NUMBER --body "$COMMENT"
}

# Check if short_description.txt is empty
if [ ! -s short_description.txt ]; then
    echo "short_description.txt is empty, failing the action..."
    add_comment "$PR_NUMBER" "Error: Short Description field is empty."
    exit 1
fi

# Check if jira_link.txt is empty
if [ ! -s jira_link.txt ]; then
    echo "jira_link.txt is empty, failing the action..."
    add_comment "$PR_NUMBER" "Error: Jira link field is empty."
    exit 1
fi

# Check if pr_link.txt is empty
if [ ! -s pr_link.txt ]; then
    echo "pr_link.txt is empty, failing the action..."
    add_comment "$PR_NUMBER" "Error: PR Link field is empty."
    exit 1
fi

echo "All fields are not empty, action can proceed."
