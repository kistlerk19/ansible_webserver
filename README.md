# Ansible + Laravel + Docker
    Make sure Ansible and Git are installed.

## Quick Setup
# Deploying with ansible
    Run the following commands:
    clone this repository or
    `git clone https://github.com/kistlerk19/ansible_webserver.git`
    then run `cd ansible_webserver`
    Run `ansible all -i hosts -m ping` to test whether the control node is able to connect to the hosts

## Setting up Variables
    1. Edit values on your `group_vars/all.yml` file to suit your server
    2. Run the `server-setup.yml` playbook to set up the LEMP server
    3. Run the `laravel-deploy.yml` playbook to deploy the Laravel application
    4. Access your server's IP address or hostname to test the setup: http://IP


# Dockerizing the app
    Run the following commands:
    clone this repository or
    `git clone https://github.com/kistlerk19/ansible_webserver.git`
    then run `cd ansible_webserver/application/bare_server`
    1. Run `docker-compose build` to build the containers
    2. Then Run `docker-compose up` to start the containers
    3. Navigate to http://0.0.0.0:8000