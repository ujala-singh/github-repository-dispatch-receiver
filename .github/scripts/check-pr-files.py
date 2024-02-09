import sys
import os
import subprocess

# Read GitHub token from environment variable
github_token = os.environ.get("GITHUB_TOKEN")

def add_comment(pr_number, comment):
    # Format the curl command to add a comment to the PR
    curl_command = f"curl -X POST \
                    -H 'Authorization: Bearer {github_token}' \
                    -H 'Content-Type: application/json' \
                    -d '{{\"body\": \"{comment}\"}}' \
                    https://api.github.com/repos/ujala-singh/github-repository-dispatch-receiver/issues/{pr_number}/comments"

    # Execute the curl command
    subprocess.run(curl_command, shell=True)

def check_empty_fields(pr_number, fields):
    empty_fields = []
    for field_name, field_value in fields.items():
        if not field_value:
            empty_fields.append(field_name)
    return empty_fields

if __name__ == "__main__":
    pr_number = sys.argv[1]
    description = sys.argv[2]
    jira_links = sys.argv[3]
    pr_links = sys.argv[4]

    fields = {
        "Description": description,
        "Jira Ticket Links": jira_links,
        "PR Links": pr_links
    }

    # Check for empty fields
    empty_fields = check_empty_fields(pr_number, fields)

    if not empty_fields:
        print("All fields are not empty, action can proceed.")
    else:
        print("Failing the action as the following fields are empty:", ", ".join(empty_fields))
        add_comment(pr_number, f"Error: The following fields are empty: {', '.join(empty_fields)}")
        sys.exit(1)
