#!/bin/bash
set -e

IMAGE="istari-openmdao-wrapper"

# Read project name from .claude-project file in the current directory
PROJECT_NAME=$(cat .claude-project 2>/dev/null | tr -d '[:space:]')
if [[ -z "$PROJECT_NAME" ]]; then
  echo "Error: .claude-project file not found or empty. Create one with a project slug, e.g. 'my-project'." >&2
  exit 1
fi

# Build image (cached after first run — only rebuilds if Dockerfile changes)
docker build -t "$IMAGE" .devcontainer/

# Usage:
#   ./dev.sh           — resume the most recent Claude session
#   ./dev.sh --fresh   — start a new Claude session
#   ./dev.sh --shell   — drop into bash instead of Claude
#
# ~/.claude is mounted so Claude has access to full conversation history and memory.

CLAUDE_CMD="claude --continue --dangerously-skip-permissions"
if [[ "$1" == "--fresh" ]]; then
  CLAUDE_CMD="claude --dangerously-skip-permissions"
elif [[ "$1" == "--shell" ]]; then
  CLAUDE_CMD="bash"
fi

docker run -it --rm \
  --user "$(id -u):$(id -g)" \
  -e HOME=/home/claude \
  -v "$(pwd):/workspace/$PROJECT_NAME" \
  -v "$HOME/.claude:/home/claude/.claude" \
  -v "$HOME/.claude.json:/home/claude/.claude.json" \
  -v "$HOME/.ssh:/home/claude/.ssh:ro" \
  -v "$HOME/.gitconfig:/home/claude/.gitconfig:ro" \
  -e ANTHROPIC_API_KEY \
  "$IMAGE" \
  $CLAUDE_CMD
