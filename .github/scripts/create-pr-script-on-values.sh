#!/bin/bash

echo "Starting workflow..."
SERVICE_REPO_NAME="$1"
IMAGE_TAG="$2"

# Function to create the body content and save it to a file
create_body_file() {
  local BODY_FILE="$(mktemp)"
  local SERVICE_REPO_NAME="$SERVICE_REPO_NAME"

  cat <<EOF > "$BODY_FILE"
## Summary

### Description

- Image Tag Update: "$SERVICE_REPO_NAME"
-

### Jira Ticket Links

### PR Links

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

# Function to create the main branch PR
create_main_branch_pr() {
  NEW_BRANCH="main-branch-update-from-${SERVICE_REPO_NAME}-values"
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

  echo "Creating the PR to main branch with branch name as $NEW_BRANCH..."
  gh pr create --base main --head $NEW_BRANCH --title "Merge changes from 'staging' to 'main' (Update Image Tags for $SERVICE_REPO_NAME)" --body "$(cat $BODY_FILE)"
}

# Function to clean up temporary files
cleanup_temp_files() {
  local TEMP_FILE="$1"
  rm "$TEMP_FILE"
}

BODY_FILE="$(create_body_file)"
create_main_branch_pr
cleanup_temp_files "$BODY_FILE"

echo "Workflow completed successfully."
