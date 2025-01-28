#!/usr/bin/env python3
"""
Pull Request Field Validator

This script validates fields in a Pull Request by checking:
1. Description length (minimum 120 characters)
2. Jira ticket link format (must contain atlanhq.atlassian.net)
3. PR link format (must contain github.com/atlanhq)

It posts warnings as comments on the PR if any issues are found, without blocking the PR.
"""

import sys
import os
import requests
from typing import Dict, List
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)

class PRFieldValidator:
    """
    A class to handle validation of Pull Request fields and posting comments.
    """

    def __init__(self):
        """
        Initialize the validator with GitHub token and required configurations.
        """
        self.github_token = os.environ.get("GITHUB_TOKEN")
        if not self.github_token:
            raise ValueError("GitHub token not provided. Set GITHUB_TOKEN environment variable.")

        # Configure logging
        logging.basicConfig(
            level=logging.INFO,
            format="%(asctime)s - %(levelname)s - %(message)s",
        )

        # Constants
        self.MIN_DESCRIPTION_LENGTH = 120
        self.REQUIRED_JIRA_DOMAIN = "ujala-singh.atlassian.net"
        self.REQUIRED_PR_DOMAIN = "github.com/ujala-singh"
        
        logging.info("PRFieldValidator initialized successfully")

    def validate_fields(self, field_paths: Dict[str, str]) -> List[str]:
        """
        Check all fields for potential issues.
        """
        warnings_list = [] 

        for field_path, field_name in field_paths.items():
            try:
                if "description" in field_path.lower():
                    warnings_list.extend(self._check_description(field_path))
                elif "jira" in field_path.lower():
                    warnings_list.extend(self._check_jira_link(field_path))
                elif "pr_link" in field_path.lower():
                    warnings_list.extend(self._check_pr_link(field_path))
            except Exception as e:
                logging.error(f"Error validating {field_name}: {e}")
                warnings_list.append(f"⚠️ Error validating {field_name}: {e}")
                
        logging.info(f"Found {len(warnings_list)} warnings: {warnings_list}")
        return warnings_list

    def _check_description(self, file_path: str) -> List[str]:
        """Check if description meets length requirements."""
        try:
            with open(file_path, 'r') as file:
                content = file.read().strip()
                if len(content) < self.MIN_DESCRIPTION_LENGTH:
                    return [f"⚠️ Description is less than {self.MIN_DESCRIPTION_LENGTH} characters. Consider adding more details."]
        except Exception as e:
            logging.error(f"Error reading description file: {e}")
            raise
        return []

    def _check_jira_link(self, file_path: str) -> List[str]:
        """Check if Jira link contains required domain."""
        try:
            with open(file_path, 'r') as file:
                content = file.read().strip()
                if self.REQUIRED_JIRA_DOMAIN not in content:
                    return [f"⚠️ Jira ticket link doesn't contain '{self.REQUIRED_JIRA_DOMAIN}'. Please verify if this is correct."]
        except Exception as e:
            logging.error(f"Error reading Jira link file: {e}")
            raise
        return []

    def _check_pr_link(self, file_path: str) -> List[str]:
        """Check if PR link contains required domain."""
        try:
            with open(file_path, 'r') as file:
                content = file.read().strip()
                if self.REQUIRED_PR_DOMAIN not in content:
                    return [f"⚠️ PR link doesn't contain '{self.REQUIRED_PR_DOMAIN}'. Please verify if this is correct."]
        except Exception as e:
            logging.error(f"Error reading PR link file: {e}")
            raise
        return []

    def post_comment(self, pr_number: str, warnings_list: List[str]) -> None:
        """
        Post warnings as a comment on the PR.
        """
        if not warnings_list:
            logging.info("No warnings to post")
            return

        comment = self._format_comment(warnings_list)

        headers = {
            "Authorization": f"Bearer {self.github_token}",
            "Accept": "application/vnd.github.v3+json",
            "Content-Type": "application/json"
        }

        url = f"https://api.github.com/repos/ujala-singh/github-repository-dispatch-receiver/issues/{pr_number}/comments"
        logging.info(f"Posting comment to PR #{pr_number}")

        try:
            response = requests.post(url, headers=headers, json={"body": comment})
            response.raise_for_status()
            logging.info("Comment added successfully")
        except requests.exceptions.RequestException as e:
            logging.error(f"Failed to add comment: {str(e)}")
            if hasattr(e.response, 'text'):
                logging.error(f"Response: {e.response.text}")

    def _format_comment(self, warnings_list: List[str]) -> str:
        """Format warnings into a Markdown comment."""
        return (
            "### PR Field Warnings\n\n"
            "The following warnings were found in your PR. These are not blocking issues, but please review them:\n\n"
            f"{chr(10).join(warnings_list)}\n\n"
            "---\n"
            "_Note: These are warnings only. Reviewers may proceed with the merge if they determine these warnings are not relevant to this PR._"
        )


def main():
    """Main function to run the PR field validation."""
    logging.info("Starting PR field validation")

    try:
        if len(sys.argv) < 2:
            raise ValueError("PR number not provided. Usage: script.py <pr_number>")

        pr_number = sys.argv[1]
        logging.info(f"Validating PR #{pr_number}")

        # Initialize validator
        validator = PRFieldValidator()

        # Define paths to check
        field_paths = {
            "/tmp/description.txt": "Description",
            "/tmp/jira.txt": "Jira Ticket Links",
            "/tmp/pr_link.txt": "PR Links"
        }

        # Run validation
        warnings_list = validator.validate_fields(field_paths)

        # Handle results
        if warnings_list:
            validator.post_comment(pr_number, warnings_list)
            logging.info("Warnings found and commented on PR")
        else:
            logging.info("All fields look good!")

    except Exception as e:
        logging.error(f"An error occurred: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
