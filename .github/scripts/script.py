import sys
import json
import requests

def post_to_slack(service_name, description, jira, pr_link, pr_url, webhook_url):
    # Assuming pr_links and jira_links are lists containing the links
    pr_bullet_points = "\n".join([f"• {link}" for link in pr_link])
    jira_bullet_points = "\n".join([f"• {link}" for link in jira])
    # Construct Slack message payload
    payload = {
        "blocks": [
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": "*New Production Release :mega:*"
                }
            },
            {
                "type": "divider"
            },
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": f"*Service: {service_name}* \n *Description:* {description} \n *Jira:* {jira_bullet_points} \n *Pull Requests:* \n{pr_bullet_points}\n• {pr_url}"
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
    service_name = sys.argv[1]
    # Read content from files
    with open(sys.argv[2], 'r') as f:
        description = f.read().strip()

    with open(sys.argv[3], 'r') as f:
        jira = f.read().strip()

    with open(sys.argv[4], 'r') as f:
        pr_link = f.read().strip()

    webhook_url = sys.argv[5]

    pr_url = sys.argv[6]

    # Send message to Slack
    post_to_slack(service_name, description, jira, pr_link, pr_url, webhook_url)
