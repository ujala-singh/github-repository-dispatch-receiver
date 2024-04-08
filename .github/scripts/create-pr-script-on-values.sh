#!/bin/bash

echo "Starting workflow..."
SERVICE_REPO_NAME="$1"
IMAGE_TAG="$2"
SERVICE_PR_URL="$3"
SERVICE_PR_USER="$4"
PR_REVIEWERS="$5"

# Function to create the body content and save it to a file
create_body_file() {
  local BODY_FILE="$(mktemp)"
  local SERVICE_REPO_NAME="$SERVICE_REPO_NAME"

  cat <<EOF > "$BODY_FILE"
## Summary

Description, Jira Ticket Links and PR Links Fields are mandatory.
---
### Description

- Image Tag Update: "$SERVICE_REPO_NAME"
-

### Jira Ticket Links

### PR Links
- $SERVICE_PR_URL

## Type of change

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Code refactoring (restructing existing code without changing any functionality)
- [ ] This change requires a documentation update

## Testing Checklist

Changes tested on
- [ ] staging (pre-prod)
- [ ] [MABL Tests Link]() (if any)
- [ ] [Successful Workflow Links]() (if any)
EOF

  echo "$BODY_FILE"
}

# Function to push
commit_values() {
  # Switch to the 'main' branch
  git checkout main
  git pull origin main  # Make sure local 'main' is up to date with the remote

  # Switch to the new branch
  git checkout -b $NEW_BRANCH

  # Check if the branch exists remotely
  if git show-ref --verify --quiet "refs/remotes/origin/$NEW_BRANCH"; then
    git pull origin $NEW_BRANCH --rebase  # Use rebase to reconcile divergent branches
  fi

  latest_commit_id=$(git log --format='%H' --grep="^Updating the Image Tag for $SERVICE_REPO_NAME$" -n 1 staging)
  echo "Latest Commit Hash: $latest_commit_id"
  echo "Cherry Pick Commit to main-branch-update-from-${SERVICE_REPO_NAME}-values"
  # resolving conflicts in favor of the changes from latest commit
  git cherry-pick --strategy-option=theirs $latest_commit_id
  git commit --amend -m "Updating the Image Tag for $SERVICE_REPO_NAME ($(TZ='Asia/Kolkata' date +'%H:%M'))"
  echo "Pushing the changes to $NEW_BRANCH..."
  git push origin $NEW_BRANCH --force  # Force push after rebasing
}

# Function to update the PR body with the new PR URL
update_pr_body_and_commit() {
  local pr_number="$1"
  # Get the Existing Body Of the PR
  gh pr view $pr_number --json body | jq -r '.body' > existing-pr-body.txt
  cat existing-pr-body.txt
  # Add the new PR URL to the existing body content
  echo "Running Sed:"
  sed -i "s|### PR Links|### PR Links\n- $SERVICE_PR_URL|g" existing-pr-body.txt
  NEW_BODY=$(cat existing-pr-body.txt)
  echo "After Sed:"
  cat existing-pr-body.txt
  commit_values
  gh pr edit $pr_number --body "$NEW_BODY"
  PR_URL="https://github.com/ujala-singh/github-repository-dispatch-receiver/pull/$pr_number"
  gh pr comment $PR_URL --body "Hey @$SERVICE_PR_USER, your main branch PR has been automatically created. In order to merge the PR, Please test your changes on staging (pre-prod) and update the change summary and checks accordingly (Don't forget to add the JIRA Ticket)."
}

# Function to create the main branch PR
create_main_branch_pr() {
  commit_values
  echo "Creating the PR to main branch with branch name as $NEW_BRANCH..."
  PR_CREATE_OUTPUT=$(gh pr create --base main --head $NEW_BRANCH --title "Merge changes from 'staging' to 'main' (Update Image Tags for $SERVICE_REPO_NAME)" --body "$(cat $BODY_FILE)")
  gh pr edit $PR_CREATE_OUTPUT --add-reviewer $PR_REVIEWERS
  # Add your comment using gh
  echo "PR USER: $SERVICE_PR_USER"
  gh pr comment $PR_CREATE_OUTPUT --body "Hey @$SERVICE_PR_USER, your main branch PR has been automatically created. In order to merge the PR, Please test your changes on staging (pre-prod) and update the change summary and checks accordingly (Don't forget to add the JIRA Ticket)."
}

# Function to clean up temporary files
cleanup_temp_files() {
  local TEMP_FILE="$1"
  rm "$TEMP_FILE"
}

BODY_FILE="$(create_body_file)"
echo "$BODY_FILE"
NEW_BRANCH="main-branch-update-from-${SERVICE_REPO_NAME}-values"
# Check if the PR already exists for the branch
URL="https://api.github.com/repos/ujala-singh/github-repository-dispatch-receiver/pulls?head=ujala-singh:${NEW_BRANCH}"
# Send a GET request to the GitHub API with authentication and store the response
response=$(curl -sSL -H "Authorization: Bearer $GH_TOKEN" -H "Accept: application/vnd.github.v3+json" "${URL}")
is_open=$(echo "${response}" | jq -r '.[0].state')
# Check if the response is empty (no PRs for the branch)
if [ "$is_open" == "open"  ]; then
  # Extract the PR number from the first PR in the response using jq
  pr_number=$(echo "${response}" | jq -r '.[0].number')
  echo "Pull request found for branch '${NEW_BRANCH}' with PR number ${pr_number}"
  # Update the existing PR body with the new PR URL
  update_pr_body_and_commit $pr_number
else
  # Create a new PR with the provided body content
  create_main_branch_pr
fi

cleanup_temp_files "$BODY_FILE"

echo "Workflow completed successfully."
