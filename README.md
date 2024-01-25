# GitHub Repository Dispatch Receiver

This repository serves as the central hub for managing and consolidating changes from various microservice repositories. Here's an overview of how it operates:

## Image Tag Synchronization
- GitHub Repository Dispatch events trigger the synchronization of the latest image tags in the charts/values.yaml file.

## Automatic Pull Requests
- Continuous workflows are in place to automatically create pull requests on the main branch whenever changes are pushed to the staging branch or when pull requests are merged into staging.

## Microservice-Specific Branches
- Upon receiving GitHub Repository Dispatch events from any microservice repository, a dedicated fixed branch is created on top of the main branch. This branch consolidates all changes related to the respective microservice.
- Once the dedicated branch is merged and approved, it is promptly deleted and recreated to accommodate new changes. This approach enables independent releases for each microservice.

## Cherry-Picking Commits
- In scenarios where developers raise pull requests directly on the staging branch, an automated process kicks in upon PR merge. This process identifies specific commits to cherry-pick, creating new pull requests automatically on top of the main branch.
