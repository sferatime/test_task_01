# dind/Dockerfile
# ───────────────────────────────────────────────────────────────────────────
# Use the Ubuntu-based DinD image instead of docker:dind
FROM cruizba/ubuntu-dind:latest

ENV DEBIAN_FRONTEND=noninteractive

# Install SSH, sudo, and Python for Ansible modules
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      sudo \
      openssh-server \
      python3 \
      python3-apt \
 && mkdir -p /var/run/sshd \
 && rm -rf /var/lib/apt/lists/*

# Create ansible user with password-less sudo
RUN useradd -m -s /bin/bash ansible \
 && echo 'ansible ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ansible \
 && chmod 0440 /etc/sudoers.d/ansible \
 && mkdir -p /home/ansible/.ssh \
 && chown -R ansible:ansible /home/ansible

# Copy over your key-gen + sshd startup script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]