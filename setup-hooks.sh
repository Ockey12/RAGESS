#!/bin/sh

# Copying hook scripts
cp scripts/pre-push .git/hooks/pre-push

# Granting Execution Authority
chmod +x .git/hooks/pre-push

echo "Git hooks has been configured."
