#!/usr/bin/env bash

# git pre-commit hook
#
# To use, store as .git/hooks/pre-commit inside your repository and make sure
# it has execute permissions.
#
# This script does not handle file names that contain spaces.

# List all nonformatted files
files=$(git diff --cached --name-only --diff-filter=ACM | grep '\.go$')

# Some files are not formatted with goimports. Print message.
nonformatted=$(goimports -l $files)
if [ "$nonformatted" ]; then
  echo >&2 "Go files must be formatted with goimports. Running:"
  for fn in $nonformatted; do
    echo >&2 "  goimports -w $PWD/$fn"
    goimports -w "$PWD/$fn"
    git add "$PWD/$fn"
  done
  printf "\n"
fi

# Run linter.
task analysis || exit 1

# Build binaries to ensure program can be built
task build || exit 1

# Run test.
task unit_tests || exit 1

# Clean up unused dependency.
go mod tidy
git add go.mod
git add go.sum

echo ""
echo -e "\e[32mCommitting...\e[0m"
