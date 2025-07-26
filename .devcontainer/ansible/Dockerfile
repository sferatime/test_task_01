# ansible/Dockerfile

# Use a lightweight Python base for Ansible
FROM python:3.11-slim

# Avoid interactive prompts during package installs
ENV DEBIAN_FRONTEND=noninteractive

# Install Ansible
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      openssh-client \
      sshpass \
 && rm -rf /var/lib/apt/lists/* \
 && pip install --no-cache-dir ansible

# Set working directory for your playbooks and inventory
WORKDIR /ansible

# Default command will be overridden by docker-compose, 
# but you can set a sensible default here:
CMD ["ansible-playbook", "-i", "inventory.ini", "playbook.yml"]