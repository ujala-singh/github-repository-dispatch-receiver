import sys
import os
import requests

# Read GitHub token from environment variable
github_token = os.environ.get("GITHUB_TOKEN")

def add_comment(pr_number, comment, github_token):
    # Prepare the comment payload
    payload = {
        "body": comment
    }

    # Prepare the headers
    headers = {
        "Authorization": f"Bearer {github_token}",
        "Content-Type": "application/json"
    }

    # Send a POST request to add a comment to the PR
    url = f"https://api.github.com/repos/ujala-singh/github-repository-dispatch-receiver/issues/{pr_number}/comments"
    response = requests.post(url, headers=headers, json=payload)

    # Check if the request was successful
    if response.status_code == 201:
        print("Comment added successfully")
    else:
        print("Failed to add comment. Status code:", response.status_code)
        print("Response:", response.text)

def check_empty_fields(field_paths):
    empty_fields = []
    for field_path, field_name in field_paths.items():
        print(f"{field_path}: {os.path.getsize(field_path)}")
        if os.path.isfile(field_path) and os.path.getsize(field_path) < 3:
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
        add_comment(pr_number, f"Error: The following fields are empty: {', '.join(empty_fields)}", github_token)
        sys.exit(1)
