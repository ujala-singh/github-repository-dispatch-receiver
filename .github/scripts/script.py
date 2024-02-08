import sys
import json
import requests

def post_to_slack(short_description, jira_link, pr_link, webhook_url):
    # Construct Slack message payload
    payload = {
        "blocks": [
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": "*Atlan Release Summary :white_tick: :megaphone:*"
                }
            },
            {
                "type": "divider"
            },
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": f"{short_description}\n{jira_link}\n{pr_link}"
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
    if len(sys.argv) != 5:
        print("Usage: python script.py <short_description_file> <jira_link_file> <pr_link_file> <webhook_url>")
        sys.exit(1)

    # Read content from files
    with open(sys.argv[1], 'r') as f:
        short_description = f.read().strip()

    with open(sys.argv[2], 'r') as f:
        jira_link = f.read().strip()

    with open(sys.argv[3], 'r') as f:
        pr_link = f.read().strip()

    webhook_url = sys.argv[4]

    # Send message to Slack
    post_to_slack(short_description, jira_link, pr_link, webhook_url)
