import sys
import json
import requests

def post_to_slack(short_description, jira_link, pr_link, pr_url, webhook_url):
    # Construct Slack message payload
    payload = {
        "blocks": [
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": "*Main Release Summary :white_tick: :megaphone:*"
                }
            },
            {
                "type": "divider"
            },
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": f"Short Description: {short_description}\nJira Ticket Link: {jira_link}\nService PR Links: {pr_link}"
                }
            },
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": f"Main PR Link: {pr_url}"
                }
            }
        ]
    }

    # Send message to Slack channel
    response = requests.post(webhook_url, json=payload)
    if response.status_code != 200:
        print("Failed to send message to Slack")
        print(response.text)

if __name__ == "__main__":
    if len(sys.argv) != 6:
        print("Usage: python script.py <short_description_file> <jira_link_file> <pr_link_file> <pr_link> <webhook_url>")
        sys.exit(1)

    # Read content from files
    with open(sys.argv[1], 'r') as f:
        short_description = f.read().strip()

    with open(sys.argv[2], 'r') as f:
        jira_link = f.read().strip()

    with open(sys.argv[3], 'r') as f:
        pr_link = f.read().strip()

    webhook_url = sys.argv[4]

    pr_url = sys.argv[5]

    # Send message to Slack
    post_to_slack(short_description, jira_link, pr_link, pr_url, webhook_url)
