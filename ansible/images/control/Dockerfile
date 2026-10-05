# The Ansible "control node": the machine you run playbooks from
FROM python:3.12-slim
RUN apt-get update && apt-get install -y openssh-client && rm -rf /var/lib/apt/lists/* \
 && pip install --no-cache-dir ansible-core==2.17.4
WORKDIR /ansible
CMD ["bash"]
