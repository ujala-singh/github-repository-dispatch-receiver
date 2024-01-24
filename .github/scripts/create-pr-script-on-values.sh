#!/bin/bash

echo "Starting workflow..."
SERVICE_REPO_NAME="$1"

# Function to create the body content and save it to a file
create_body_file() {
  local BODY_FILE="$(mktemp)"

  cat <<EOF > "$BODY_FILE"
## Change Summary

Summarise your changes in points

- This PR includes changes from charts/values.yaml file.
- Image Tag Update: $SERVICE_REPO_NAME
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
  # Switch to the 'main' branch
  git checkout main
  git checkout -b main-branch-update-from-${SERVICE_REPO_NAME}-values origin/main
  echo "Fetching changes from 'staging'..."
  git fetch origin staging:staging
  echo "Merging changes from 'staging' into the new branch..."
  git merge staging
  echo "Pushing the changes to main-branch-update-from-${SERVICE_REPO_NAME}-values..."
  git push origin main-branch-update-from-${SERVICE_REPO_NAME}-values
  echo "Creating the PR to main branch with branch name as main-branch-update-from-${SERVICE_REPO_NAME}-values..."
  gh pr create --base main --head main-branch-update-from-${SERVICE_REPO_NAME}-values --title "Merge changes from 'staging' to 'main' (Update Image Tags)" --body "$(cat $BODY_FILE)"
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
