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

def check_empty_fields(field_paths):
    empty_fields = []
    for field_path, field_name in field_paths.items():
        print(f"{field_path}: {os.path.getsize(field_path)}")
        if os.path.isfile(field_path) and os.path.getsize(field_path) == 0:
            empty_fields.append(field_name)
    return empty_fields

if __name__ == "__main__":
    pr_number = sys.argv[1]
    field_paths = {
        "/tmp/description.txt": "Description",
        "/tmp/jira.txt": "Jira Ticket Links",
        "/tmp/pr_link.txt": "PR Links"
    }

    # Check for empty fields
    empty_fields = check_empty_fields(field_paths)

    if not empty_fields:
        print("All fields are not empty, action can proceed.")
    else:
        print("Failing the action as the following fields are empty:", ", ".join(empty_fields))
        add_comment(pr_number, f"Error: The following fields are empty: {', '.join(empty_fields)}")
        sys.exit(1)
