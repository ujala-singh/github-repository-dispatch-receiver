#!/bin/bash

echo "Starting workflow..."

PR_NUMBER="$1"
PR_URL="$2"
PR_USER="$3"

# Function to create the body content and save it to a file
create_body_file() {
  local PR_NUMBER="$1"
  local PR_URL="$2"
  local BODY_FILE="$(mktemp)"

  cat <<EOF > "$BODY_FILE"
## Change Summary

Summarise your changes in points

- This PR includes changes from staging PR: $PR_URL"
-

## Type of change

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Code refactoring (restructuring existing code without changing any functionality)
- [ ] This change requires a documentation update

## Documentation/Release Plan

- [Problem Statement doc]()
- [Feature documentation]()
- [Release plan]()

## Testing Checklist

Changes tested on
- [ ] development
- [ ] production
- [ ] [MABL Tests Link]() (if any)
- [ ] [Successful Workflow Links]() (if any)

---
EOF

  echo "$BODY_FILE"
}

# Function to create the main branch PR
create_main_branch_pr() {
  local PR_NUMBER="$1"
  local BODY_FILE="$2"
  local PR_USER="$3"

  # Switch to the 'main' branch
  git checkout main
  # Create a new branch for the main branch, including the PR number
  git checkout -b main-branch-update-from-staging-pr-${PR_NUMBER} origin/main
  # Fetch the changes from the closed pull request
  echo "Fetching changes from PR #$PR_NUMBER..."
  merged_commit=$(gh pr view $PR_NUMBER --json mergeCommit | jq -r '.[].oid')
  echo "Merged Commit Hash: $merged_commit"
  echo "Cherry Pick Commit to main-branch-update-from-staging-pr-${PR_NUMBER}"
  git cherry-pick -m 1 $merged_commit
  echo "Pushing the changes to main-branch-update-from-staging-pr-${PR_NUMBER}..."
  git push origin main-branch-update-from-staging-pr-${PR_NUMBER}
  echo "Creating the PR to main branch with branch name as main-branch-update-from-staging-pr-${PR_NUMBER}..."
  gh pr create --base main --head main-branch-update-from-staging-pr-${PR_NUMBER} --title "Merge changes from 'staging' to 'main' (PR #$PR_NUMBER)" --body "$(cat $BODY_FILE)"
  # Add your comment using gh
  gh pr comment $PR_NUMBER --body "Hey @$PR_USER, your main branch PR has been automatically created. In order to merge the PR, Please test your changes on staging (pre-prod) and update the change summary and checks accordingly."
}

# Function to clean up temporary files
cleanup_temp_files() {
  local TEMP_FILE="$1"
  rm "$TEMP_FILE"
}

BODY_FILE="$(create_body_file "$PR_NUMBER" "$PR_URL")"
create_main_branch_pr "$PR_NUMBER" "$BODY_FILE" "$PR_USER"
cleanup_temp_files "$BODY_FILE"

echo "Workflow completed successfully."
