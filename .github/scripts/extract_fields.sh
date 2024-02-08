#!/bin/bash

# Function to extract fields from the pull request body
extract_fields() {
    local body="$1"

    # Extract Short Description
    short_description=$(echo "$1" | awk '/### Short Description/{flag=1; next} /### Jira ticket link/{flag=0} flag' | sed 's/^ *//;s/ *$//')
    echo "Short Description: $short_description" > short_description.txt

    # Extract Jira Ticket Link
    jira_link=$(echo "$1" | awk '/### Jira ticket link/{flag=1; next} /### PR Link/{flag=0} flag' | sed 's/^ *//;s/ *$//')
    echo "Jira Ticket Link: $jira_link" > jira_link.txt

    # Extract PR Link
    pr_link=$(echo "$1" | awk '/### PR Link/{flag=1; next} /## Type of change/{flag=0} flag' | sed 's/^ *//;s/ *$//')
    echo "PR Link: $pr_link" > pr_link.txt
}

# Main function
main() {
    local body="$1"
    local webhook_url="$2"
    pr_description=$(extract_fields "$body" "$webhook_url")
}

# Check if PR body is provided as input
if [ $# -eq 0 ]; then
    echo "Usage: $0 <PR_BODY>"
    exit 1
fi

# Execute main function with PR body provided as argument
main "$1"
