import json
import requests
from datetime import datetime, timedelta

# GitHub API endpoint for tags
tags_url = 'https://api.github.com/repos/{owner}/{repo}/tags'

# GitHub API endpoint for releases
releases_url = 'https://api.github.com/repos/{owner}/{repo}/releases'

# Function to get GitHub data (tags or releases)
def get_github_data(url):
    response = requests.get(url)
    if response.status_code == 200:
        return response.json()
    else:
        print(f'Request failed with status code {response.status_code}')
        return None

# Function to filter data older than a specified number of days
def filter_data(data, days):
    current_date = datetime.utcnow()
    filtered_data = []

    for item in data:
        created_at = datetime.strptime(item['created_at'], "%Y-%m-%dT%H:%M:%SZ")
        if current_date - created_at > timedelta(days=days):
            filtered_data.append(item)

    return filtered_data

# Get and filter GitHub tags
tags_data = get_github_data(tags_url.format(owner='your_username', repo='your_repository'))
if tags_data:
    filtered_tags = filter_data(tags_data, days=20)
    print(f'Filtered Tags: {filtered_tags}')

# Get and filter GitHub releases
releases_data = get_github_data(releases_url.format(owner='your_username', repo='your_repository'))
if releases_data:
    filtered_releases = filter_data(releases_data, days=20)
    print(f'Filtered Releases: {filtered_releases}')
