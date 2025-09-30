FROM codercom/code-server:latest

USER root

# Install system packages
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    jq \
    ca-certificates \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf aws awscliv2.zip

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

# Install eksctl
RUN curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" \
    && tar -xzf eksctl_Linux_amd64.tar.gz \
    && mv eksctl /usr/local/bin/ \
    && rm eksctl_Linux_amd64.tar.gz

# Pre-configure AWS CLI region
RUN mkdir -p /home/coder/.aws && \
    echo '[default]\nregion = us-east-1' > /home/coder/.aws/config && \
    chown -R coder:coder /home/coder/.aws

# Setup PATH and kubectl completion for coder user
RUN echo 'export PATH=/usr/local/bin:$PATH' >> /home/coder/.bashrc && \
    echo 'source <(kubectl completion bash)' >> /home/coder/.bashrc && \
    echo 'alias k=kubectl' >> /home/coder/.bashrc && \
    echo 'complete -F __start_kubectl k' >> /home/coder/.bashrc

USER coder
