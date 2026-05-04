#!/bin/bash
set -e

# Read project name from .claude-project file in the current directory
PROJECT_NAME=$(cat .claude-project 2>/dev/null | tr -d '[:space:]')
if [[ -z "$PROJECT_NAME" ]]; then
  echo "Error: .claude-project file not found or empty. Create one with a project slug, e.g. 'my-project'." >&2
  exit 1
fi

IMAGE="$PROJECT_NAME"

# Build image (cached after first run — only rebuilds if Dockerfile changes)
docker build -t "$IMAGE" .devcontainer/

# Usage:
#   ./dev.sh           — resume the most recent Claude session
#   ./dev.sh --fresh   — start a new Claude session
#   ./dev.sh --shell   — drop into bash instead of Claude
#
# ~/.claude is mounted so Claude has access to full conversation history and memory.

if [[ "$1" == "--fresh" ]]; then
  CLAUDE_ARGS=(claude --dangerously-skip-permissions)
elif [[ "$1" == "--shell" ]]; then
  CLAUDE_ARGS=(bash)
else
  CLAUDE_ARGS=(bash -c 'claude --continue --dangerously-skip-permissions || claude --dangerously-skip-permissions')
fi

docker run -it --rm \
  --user "$(id -u):$(id -g)" \
  --workdir "/workspace/$PROJECT_NAME" \
  -e HOME=/home/claude \
  -v "$(pwd):/workspace/$PROJECT_NAME" \
  -v "$HOME/.claude:/home/claude/.claude" \
  -v "$HOME/.claude.json:/home/claude/.claude.json" \
  -v "$HOME/.ssh:/home/claude/.ssh:ro" \
  -v "$HOME/.gitconfig:/home/claude/.gitconfig:ro" \
  -e ANTHROPIC_API_KEY \
  "$IMAGE" \
  "${CLAUDE_ARGS[@]}"
