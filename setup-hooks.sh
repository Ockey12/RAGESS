#!/bin/sh

# Create .git/hooks directory if it does not exist
if [ ! -d ".git/hooks" ]; then
  mkdir .git/hooks
fi

# Copying hook scripts
cp scripts/pre-push .git/hooks/pre-push

# Granting Execution Authority
chmod +x .git/hooks/pre-push

echo "Git hooks has been configured."
