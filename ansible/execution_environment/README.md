# How to set init setup

1. `python3 -m venv .venv`
2. Python venv should be set automatically thanks to mise. If not - `source .venv/bin/activate`
3. `pip install -r venv-requirements.txt`

# How to build and use the execution environment

1. Run `ansible-builder build`
2. `cd ..` to the directory with the Ansible playbooks
3. Run the wanted playbook - `ansible-navigator run fearless.yml -i inventory/prod.yml --execution-environment-image homelab:latest`
