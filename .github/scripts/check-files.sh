#!/bin/bash

PR_NUMBER="$1"

# Function to add comment on PR
add_comment() {
    local PR_NUMBER="$1"
    local COMMENT="$2"
    gh pr comment $PR_NUMBER --body "$COMMENT"
}

# Check if description.txt is empty
if [ ! -s "/tmp/description.txt" ]; then
    echo "description.txt is empty, failing the action..."
    add_comment "$PR_NUMBER" "Error: Description field is empty."
    exit 1
fi

# Check if jira.txt is empty
if [ ! -s "/tmp/jira.txt" ]; then
    echo "jira.txt is empty, failing the action..."
    add_comment "$PR_NUMBER" "Error: Jira Links field is empty."
    exit 1
fi

# Check if pr_link.txt is empty
if [ ! -s "/tmp/pr_link.txt" ]; then
    echo "pr_link.txt is empty, failing the action..."
    add_comment "$PR_NUMBER" "Error: PR Links field is empty."
    exit 1
fi

echo "All fields are not empty, action can proceed."
