#!/usr/bin/env bash

# Name of the GitHub user or organization
USER="input-output-hk"

# Name of the GitHub repository
REPO="cardano-node"

# GitHub API URL for the releases of the repo
RELEASES_API_URL="https://api.github.com/repos/$USER/$REPO/releases"
TAGS_API_URL="https://api.github.com/repos/$USER/$REPO/git/refs/tags"

# Path to the flake.nix file
FLAKE_NIX_FILE="/home/bismuth/plutus/workspace/vscWs/nix-config.git/intelTower/flake.nix"

# Fetch the list of releases and parse the JSON to get the tag name of the latest release
LATEST_TAG=$(curl -s $RELEASES_API_URL | jq -r '.[0].tag_name')

# If the latest tag is empty or null, print an error and exit
if [[ -z "$LATEST_TAG" || "$LATEST_TAG" == "null" ]]; then
    echo "Error: Could not retrieve the latest release tag."
    exit 1
fi

# Fetch the commit hash associated with the latest tag
COMMIT_HASH=$(curl -s $TAGS_API_URL/$LATEST_TAG | jq -r '.object.sha')

# If the commit hash is empty or null, print an error and exit
if [[ -z "$COMMIT_HASH" || "$COMMIT_HASH" == "null" ]]; then
    echo "Error: Could not retrieve the commit hash for the latest release tag."
    exit 1
fi

echo "The commit hash of the latest cardano-node release ($LATEST_TAG) is $COMMIT_HASH"

# Escape COMMIT_HASH for use in sed
ESCAPED_COMMIT_HASH=$(echo $COMMIT_HASH | sed 's/\//\\\//g')

# Find the line with "cardano-node" and replace the commit hash
sed -i "/cardano-node = {/!b;n;s/\(url = \"github:input-output-hk\/cardano-node?rev=\).*\"/\1$ESCAPED_COMMIT_HASH\"/" $FLAKE_NIX_FILE

# If the sed command failed, print an error message and exit
if [[ $? -ne 0 ]]; then
    echo "Error: Could not update the commit hash in the flake.nix file."
    exit 1
fi

echo "Updated inputs.cardano-node in flake.nix with the latest commit hash."
