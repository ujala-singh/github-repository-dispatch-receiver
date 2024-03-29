#!/bin/bash

# Function to extract fields from the pull request body
extract_fields() {
    local body="$1"

    # Extract Description
    description=$(echo "$1" | awk '/### Description/{flag=1; next} /### Jira Ticket Links/{flag=0} flag' | sed 's/^ *//;s/ *$//')
    echo "$description" > /tmp/description.txt

    # Extract Jira Ticket Link
    jira=$(echo "$1" | awk '/### Jira Ticket Links/{flag=1; next} /### PR Links/{flag=0} flag' | sed 's/^ *//;s/ *$//')
    echo "$jira" > /tmp/jira.txt

    # Extract PR Link
    pr_link=$(echo "$1" | awk '/### PR Links/{flag=1; next} /## Type of change/{flag=0} flag' | sed 's/^ *//;s/ *$//')
    echo "$pr_link" > /tmp/pr_link.txt

    description=$(sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' /tmp/description.txt | sed '/^$/d')
    jira=$(sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' /tmp/jira.txt | sed '/^$/d')
    pr_link=$(sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' /tmp/pr_link.txt | sed '/^$/d')

    echo "$description" > /tmp/description.txt
    echo "$jira" > /tmp/jira.txt
    echo "$pr_link" > /tmp/pr_link.txt
}

# Main function
main() {
    local body="$1"
    extract_fields "$body"
}

# Check if PR body is provided as input
if [ $# -eq 0 ]; then
    echo "Usage: $0 <PR_BODY>"
    exit 1
fi

# Execute main function with PR body provided as argument
main "$1"
