import sys
import requests

def post_to_slack(service_name, description, jira, pr_links, pr_url, webhook_url):
    # Construct Slack message payload
    description_bullet_points = "\n".join([f"• {point.lstrip('-')}" for point in description])
    pr_bullet_points = "\n".join([f"• {link.lstrip('-')}" for link in pr_links])
    jira_bullet_points = "\n".join([f"• {link.lstrip('-')}" for link in jira])

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
                    "text": f"*Service: {service_name}*\n*Description:*\n{description_bullet_points}\n*Jira:*\n{jira_bullet_points}\n*Pull Requests:*\n{pr_bullet_points}\n• {pr_url}"
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
    if len(sys.argv) != 7:
        print("Usage: python script.py <service_name> <description> <jira> <pr_links> <webhook_url> <pr_url>")
        sys.exit(1)

    service_name = sys.argv[1]
    description = sys.argv[2].split('\n')
    jira = sys.argv[3].split('\n')
    pr_links = sys.argv[4].split('\n')
    webhook_url = sys.argv[5]
    pr_url = sys.argv[6]

    # Send message to Slack
    post_to_slack(service_name, description, jira, pr_links, pr_url, webhook_url)
