import json
import requests
import os
import sys

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

def check_empty_fields(json_file):
    # Load the JSON object from the file
    with open(json_file, 'r') as f:
        data = json.load(f)

    # Check for empty values in the JSON object
    empty_fields = [key for key, value in data.items() if not value.strip()]
    return empty_fields

if __name__ == "__main__":
    pr_number = sys.argv[1]
    # Specify the path to the combined JSON file
    json_file = '/tmp/combined.json'

    # Check for empty fields in the JSON object
    empty_fields = check_empty_fields(json_file)

    if not empty_fields:
        print("All fields are not empty, action can proceed.")
    else:
        print("Failing the action as the following fields are empty:", ", ".join(empty_fields))
        comment=f"Error: The following fields are empty: {', '.join(empty_fields)}"
        add_comment(pr_number, comment, github_token)
        sys.exit(1)
