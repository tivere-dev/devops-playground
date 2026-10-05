# A practice "server" that Ansible manages over SSH, like a real cloud VM
FROM ubuntu:22.04
RUN apt-get update \
 && apt-get install -y openssh-server python3 python3-apt sudo \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /run/sshd \
 && useradd -m -s /bin/bash ansible \
 && echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible \
 && mkdir -p /home/ansible/.ssh && chmod 700 /home/ansible/.ssh
# The control node's public key: lets it log in without a password
COPY id_ed25519.pub /home/ansible/.ssh/authorized_keys
RUN chown -R ansible:ansible /home/ansible/.ssh && chmod 600 /home/ansible/.ssh/authorized_keys
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
