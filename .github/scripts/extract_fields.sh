#!/bin/bash

PR_BODY="$1"

# Function to extract fields from the pull request body
extract_fields() {
    local body="$1"

    # Extract Description
    description=$(echo "$1" | awk '/### Description/{flag=1; next} /### Jira Ticket Links/{flag=0} flag' | sed 's/^ *//;s/ *$//')
    echo "description=$description" >> $GITHUB_OUTPUT 

    # Extract Jira Ticket Link
    jira=$(echo "$1" | awk '/### Jira Ticket Links/{flag=1; next} /### PR Links/{flag=0} flag' | sed 's/^ *//;s/ *$//')
    echo "jira=$jira" >> $GITHUB_OUTPUT 

    # Extract PR Link
    pr_link=$(echo "$1" | awk '/### PR Links/{flag=1; next} /## Type of change/{flag=0} flag' | sed 's/^ *//;s/ *$//')
    echo "pr_link=$pr_link" >> $GITHUB_OUTPUT 
}

# Main function
main() {
    local body="$1"
    extract_fields "$body"
}

# Execute main function with PR body provided as argument
main "$PR_BODY"
