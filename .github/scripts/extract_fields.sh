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
}

filter_files() {
    # Remove extra whitespace or empty lines from description file
    description=$(grep -vE '^\s*$' /tmp/description.txt)
    echo "$description" > /tmp/description_filter.txt

    # Remove extra whitespace or empty lines from Jira file
    jira=$(grep -vE '^\s*$' /tmp/jira.txt)
    echo "$jira" > /tmp/jira_filter.txt

    # Remove extra whitespace or empty lines from PR link file
    pr_link=$(grep -vE '^\s*$' /tmp/pr_link.txt)
    echo "$pr_link" > /tmp/pr_link_filter.txt
}
# Main function
main() {
    local body="$1"
    local webhook_url="$2"
    extract_fields "$body" "$webhook_url"
    filter_files
}

# Check if PR body is provided as input
if [ $# -eq 0 ]; then
    echo "Usage: $0 <PR_BODY>"
    exit 1
fi

# Execute main function with PR body provided as argument
main "$1"
