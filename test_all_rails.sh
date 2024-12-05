#!/bin/bash

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Rails versions to test
RAILS_VERSIONS=(
  "~> 6.1.0"
  "~> 7.0.0"
  "~> 7.1.0"
  "~> 7.2.0"
  "~> 8.0.0"
)

# Function to run tests for a specific Rails version
test_rails_version() {
  local version=$1
  echo -e "\n${GREEN}Testing Rails ${version}...${NC}"
  
  # Update Rails and sqlite3
  RAILS="$version" bundle update rails sqlite3
  if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to update Rails ${version}${NC}"
    return 1
  fi

  # Run tests
  RAILS="$version" bundle exec rake test
  if [ $? -ne 0 ]; then
    echo -e "${RED}Tests failed for Rails ${version}${NC}"
    return 1
  fi

  echo -e "${GREEN}Rails ${version} tests passed successfully!${NC}"
  return 0
}

# Main execution
failed_versions=()

for version in "${RAILS_VERSIONS[@]}"; do
  if ! test_rails_version "$version"; then
    failed_versions+=("$version")
  fi
done

# Summary
echo -e "\n${GREEN}Test Summary:${NC}"
if [ ${#failed_versions[@]} -eq 0 ]; then
  echo -e "${GREEN}All Rails versions tested successfully!${NC}"
  exit 0
else
  echo -e "${RED}Tests failed for the following Rails versions:${NC}"
  printf "${RED}%s${NC}\n" "${failed_versions[@]}"
  exit 1
fi
