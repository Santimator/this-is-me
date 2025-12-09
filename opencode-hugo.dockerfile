# Use a minimal, stable Debian image for a slim footprint
FROM debian:stable-slim

# Image metadata
LABEL maintainer="your-email@example.com"
LABEL description="OpenCode AI sandbox with Hugo Extended and local MCP memory server"
LABEL version="1.0"
LABEL tools="opencode,hugo,mcp-memory"

# Set environment variables for non-interactive installs
ENV DEBIAN_FRONTEND=noninteractive

# 1. Install dependencies (curl, git, wget, dpkg, nodejs, npm)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    wget \
    dpkg \
    ca-certificates \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# 2. Install Hugo Extended and verify
ARG HUGO_VERSION=0.120.4
RUN wget -O /tmp/hugo.deb https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.deb \
    && dpkg -i /tmp/hugo.deb \
    && rm /tmp/hugo.deb \
    && hugo version

# 3. Install MCP Memory Server globally (as root, before switching to devuser)
RUN npm install -g local-memory-mcp

# 4. Configure User and home directory
RUN useradd -ms /bin/bash devuser

# 5. Switch to devuser and set HOME
USER devuser
WORKDIR /home/devuser

# 6. Install OpenCode AI as devuser
RUN curl -fsSL https://opencode.ai/install | bash

# 7. Add OpenCode to PATH for devuser
ENV PATH="/home/devuser/.opencode/bin:/home/devuser/.local/bin:${PATH}"

# 8. Set final workspace
WORKDIR /home/devuser/project

CMD ["/bin/bash"]
