import sys
import requests
import re

def extract_service_name(branch_name):
    regex = r"^main-branch-update-from-(.*)-values$"
    match = re.match(regex, branch_name)
    if match:
        return match.group(1)
    else:
        return "Receiver Helm Repo"

def read_file_content(filename):
    with open(filename, 'r') as f:
        return f.read().rstrip()

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
        print("Usage: python script.py <service_name> <description_file> <jira_file> <pr_link_file> <webhook_url> <pr_url>")
        sys.exit(1)

    branch_name = sys.argv[1]
    description_file = sys.argv[2]
    jira_file = sys.argv[3]
    pr_link_file = sys.argv[4]
    webhook_url = sys.argv[5]
    pr_url = sys.argv[6]

    # Read content from files
    description = read_file_content(description_file).split('\n')
    jira = read_file_content(jira_file).split('\n')
    pr_links = read_file_content(pr_link_file).split('\n')

    # Extract Service Name
    service_name = extract_service_name(branch_name)
    # Send message to Slack
    post_to_slack(service_name, description, jira, pr_links, pr_url, webhook_url)
