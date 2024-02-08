#!/bin/bash

# Function to extract fields from the pull request body
extract_fields() {
    local body="$1"

    # Extract Short Description
    short_description=$(echo "$body" | grep -oP '(?<=Short Description: ).*' | tr -d '\n')

    # Extract Jira ticket link
    jira_link=$(echo "$body" | grep -oP '(?<=Jira Ticket Link: ).*' | tr -d '\n')

    # Extract PR Link
    pr_link=$(echo "$body" | grep -oP '(?<=PR Link: ).*' | tr -d '\n')

    # Print the extracted fields
    echo "Short Description: $short_description"
    echo "Jira Ticket Link: $jira_link"
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
