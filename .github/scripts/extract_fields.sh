#!/bin/bash

# Function to extract fields from the pull request body
extract_fields() {
    local body="$1"

    # Extract Short Description
    description=$(echo "$1" | awk '/### Description/{flag=1; next} /### Jira Ticket Links/{flag=0} flag' | sed 's/^ *//;s/ *$//')
    echo "$description" > /tmp/description.txt

    # Extract Jira Ticket Link
    jira=$(echo "$1" | awk '/### Jira Ticket Links/{flag=1; next} /### PR Links/{flag=0} flag' | sed 's/^ *//;s/ *$//')
    echo "$jira" > /tmp/jira.txt

    # Extract PR Link
    pr_link=$(echo "$1" | awk '/### PR Links/{flag=1; next} /## Type of change/{flag=0} flag' | sed 's/^ *//;s/ *$//')
    echo "$pr_link" > /tmp/pr_link.txt
}

# Main function
main() {
    local body="$1"
    local webhook_url="$2"
    extract_fields "$body" "$webhook_url"
}

# Check if PR body is provided as input
if [ $# -eq 0 ]; then
    echo "Usage: $0 <PR_BODY>"
    exit 1
fi

# Execute main function with PR body provided as argument
main "$1"
