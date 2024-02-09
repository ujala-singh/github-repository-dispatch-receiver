#!/bin/bash

# Function to extract fields from the pull request body
extract_fields() {
    local body="$1"

    # Extract Description
    description=$(echo "$1" | awk '/### Description/{flag=1; next} /### Jira Ticket Links/{flag=0} flag' | sed 's/^ *//;s/ *$//')

    # Extract Jira Ticket Link
    jira=$(echo "$1" | awk '/### Jira Ticket Links/{flag=1; next} /### PR Links/{flag=0} flag' | sed 's/^ *//;s/ *$//')

    # Extract PR Link
    pr_link=$(echo "$1" | awk '/### PR Links/{flag=1; next} /## Type of change/{flag=0} flag' | sed 's/^ *//;s/ *$//')

    # Create combined JSON object
    combined_json="{\"Description\": \"$description\", \"Jira_Ticket_Links\": \"$jira\", \"PR_Links\": \"$pr_link\"}"

    # Print combined JSON object
    echo "$combined_json" > /tmp/combined.json
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
