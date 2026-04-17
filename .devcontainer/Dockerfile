FROM continuumio/miniconda3:latest

# System dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Node.js (required by Claude Code)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Claude Code (installed globally so all users can access it)
RUN npm install -g @anthropic-ai/claude-code

# Project Python dependencies
ARG CONDA_PACKAGES="openmdao"
RUN conda install -y $CONDA_PACKAGES

# Create a non-root user (Claude refuses --dangerously-skip-permissions as root)
RUN useradd -m -s /bin/bash claude && \
    echo "claude ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    chmod -R 777 /home/claude

USER claude
WORKDIR /workspace
