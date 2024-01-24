import os
import requests
from datetime import datetime, timedelta

# GitHub repository details
github_repo_owner = os.environ.get("GITHUB_OWNER")
github_repo = os.environ.get("GITHUB_REPO")
github_access_token = os.environ.get("GITHUB_TOKEN")

# Get current date and date 20 days ago
current_date = datetime.utcnow()
twenty_days_ago = current_date - timedelta(days=20)

# Fetch tags
tags_url = f"https://api.github.com/repos/{github_repo_owner}/{github_repo}/tags"
tags_response = requests.get(tags_url, headers={"Authorization": f"Bearer {github_access_token}"})
tags = tags_response.json()

# Fetch releases
releases_url = f"https://api.github.com/repos/{github_repo_owner}/{github_repo}/releases"
releases_response = requests.get(releases_url, headers={"Authorization": f"Bearer {github_access_token}"})
releases = releases_response.json()

# Function to check if a date is older than 20 days
def is_older_than_20_days(date_str):
    release_date = datetime.strptime(date_str, "%Y-%m-%dT%H:%M:%SZ")
    return release_date < twenty_days_ago

# Process and delete older tags
# for tag in tags:
#     tag_name = tag["name"]
#     tag_date = tag["commit"]["commit"]["author"]["date"]
    
#     if is_older_than_20_days(tag_date):
#         print(f"Deleting tag: {tag_name}")
        # Uncomment the line below to delete the tag
        # requests.delete(f"https://api.github.com/repos/{github_repo_owner}/{github_repo}/git/refs/tags/{tag_name}", headers={"Authorization": f"Bearer {github_access_token}"})

# Process and delete older releases
for release in releases:
    release_name = release["tag_name"]
    release_date = release["created_at"]
    
    if is_older_than_20_days(release_date):
        print(f"Deleting release: {release_name}")
        # Uncomment the line below to delete the release
        # requests.delete(f"https://api.github.com/repos/{github_repo_owner}/{github_repo}/releases/{release['id']}", headers={"Authorization": f"Bearer {github_access_token}"})
