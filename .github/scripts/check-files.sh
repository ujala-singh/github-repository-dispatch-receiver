#!/bin/bash

PR_NUMBER="$1"
EMPTY_FIELDS=""

# Function to add comment on PR
add_comment() {
    local PR_NUMBER="$1"
    local COMMENT="$2"
    gh pr comment $PR_NUMBER --body "$COMMENT"
}

# Check if description.txt is empty
if [ -s "/tmp/description.txt" ]; then
    echo "description.txt is not empty."
else
    echo "description.txt is empty."
    EMPTY_FIELDS+=" Description "
fi

# Check if jira.txt is empty
if [ -s "/tmp/jira.txt" ]; then
    echo "jira.txt is not empty."
else
    echo "jira.txt is empty."
    EMPTY_FIELDS+=" Jira Ticket Links "
fi

# Check if pr_link.txt is empty
if [ -s "/tmp/pr_link.txt" ]; then
    echo "pr_link.txt is not empty."
else
    echo "pr_link.txt is empty."
    EMPTY_FIELDS+=" PR Links "
fi

# Remove trailing comma and space from EMPTY_FIELDS
EMPTY_FIELDS=$(echo "$EMPTY_FIELDS" | sed 's/,\s$//')

# Check if all files are empty
if [ -z "$EMPTY_FIELDS" ]; then
    echo "All fields are not empty, action can proceed."
else
    echo "Failing the action as the following files are empty: $EMPTY_FIELDS"
    add_comment "$PR_NUMBER" "Error: The following files are empty: $EMPTY_FIELDS"
    exit 1
fi
