#!/usr/bin/env bash
set -e

# Prepare shared SSH key volume
mkdir -p /ssh
chown ubuntu:ubuntu /ssh

# Generate keypair if missing
if [ ! -f /ssh/id_rsa ]; then
  ssh-keygen -t rsa -b 4096 -f /ssh/id_rsa -N "" -q
  chown ubuntu:ubuntu /ssh/id_rsa /ssh/id_rsa.pub
  chmod 600 /ssh/id_rsa && chmod 644 /ssh/id_rsa.pub
fi

# Install public key for ansible user
mkdir -p /home/ansible/.ssh
cp /ssh/id_rsa.pub /home/ansible/.ssh/authorized_keys
chown -R ansible:ansible /home/ansible/.ssh
chmod 700 /home/ansible/.ssh
chmod 600 /home/ansible/.ssh/authorized_keys

# Start SSH daemon
/usr/sbin/sshd

# Launch Docker daemon
exec dockerd "$@"