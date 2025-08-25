#!/bin/bash

# Script to apply standardized labels to GitHub repository
# Based on https://github.com/abdonrd/github-labels/blob/master/github-labels.json

REPO="lusu007/dienstplan"

# Function to create a label
create_label() {
    local name="$1"
    local color="$2"
    local description="$3"
    
    echo "Creating label: $name"
    gh label create "$name" --color "$color" --description "$description" --repo "$REPO"
}

# Function to update an existing label
update_label() {
    local name="$1"
    local color="$2"
    local description="$3"
    
    echo "Updating label: $name"
    gh label edit "$name" --color "$color" --description "$description" --repo "$REPO"
}

echo "Applying standardized labels to $REPO..."

# Standard labels from github-labels repository
create_label "good first issue" "7057ff" "Good for newcomers"
create_label "help wanted" "008672" "Extra attention is needed"
create_label "priority: critical" "b60205" "Critical priority - needs immediate attention"
create_label "priority: high" "d93f0b" "High priority - should be addressed soon"
create_label "priority: low" "0e8a16" "Low priority - can be addressed when convenient"
create_label "priority: medium" "fbca04" "Medium priority - normal priority level"
create_label "status: can't reproduce" "fec1c1" "Issue cannot be reproduced"
create_label "status: confirmed" "215cea" "Issue has been confirmed"
create_label "status: duplicate" "cfd3d7" "This issue or pull request already exists"
create_label "status: needs information" "fef2c0" "More information is needed to proceed"
create_label "status: wont do/fix" "eeeeee" "This will not be worked on"
create_label "type: bug" "d73a4a" "Something isn't working"
create_label "type: discussion" "d4c5f9" "General discussion or questions"
create_label "type: documentation" "006b75" "Documentation improvements or updates"
create_label "type: enhancement" "84b6eb" "Improvements to existing functionality"
create_label "type: epic" "3E4B9E" "A theme of work that contain sub-tasks"
create_label "type: feature request" "fbca04" "New feature or request"
create_label "type: question" "d876e3" "Further information is requested"

# Additional conventional commit labels
create_label "commit: feat" "1d76db" "New feature (conventional commit)"
create_label "commit: fix" "d73a4a" "Bug fix (conventional commit)"
create_label "commit: docs" "006b75" "Documentation changes (conventional commit)"
create_label "commit: style" "fef2c0" "Code style changes (conventional commit)"
create_label "commit: refactor" "84b6eb" "Code refactoring (conventional commit)"
create_label "commit: perf" "0e8a16" "Performance improvements (conventional commit)"
create_label "commit: test" "d4c5f9" "Test changes (conventional commit)"
create_label "commit: chore" "cfd3d7" "Build/tooling changes (conventional commit)"
create_label "breaking change" "b60205" "Introduces breaking changes"

echo "Labels applied successfully!"
echo ""
echo "Note: If some labels already exist, you may see errors for those."
echo "You can run this script multiple times safely."
