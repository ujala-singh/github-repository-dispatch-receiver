#!/bin/bash

# Function to extract fields from the pull request body
extract_fields() {
    local body="$1"

    # Extract Short Description
    short_description=$(echo "$1" | grep -oP '(?<=### Short Description\n).*' | sed 's/^ *//;s/ *$//')
    echo "Short Description: $short_description"

    # Extract Jira Ticket Link
    jira_link=$(echo "$1" | grep -oP '(?<=### Jira ticket link\n).*' | sed 's/^ *//;s/ *$//')
    echo "Jira Ticket Link: $jira_link"

    # Extract PR Link
    pr_link=$(echo "$1" | grep -oP '(?<=### PR Link\n).*' | sed 's/^ *//;s/ *$//')
    echo "PR Link: $pr_link"
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
