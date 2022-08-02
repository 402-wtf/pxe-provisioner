# PXE Provisioning Playbook

This Ansible playbook sets up a provisioning server to allow iPXE provisioning of networked machines through IaC.

It provides the following:

* DHCP Proxy server to pass additional dhcp-options to network clients to enable chainloading of iPXE.
* Provides an API via Matchbox to dictate what instructions a machine gets.


## Requirements

* A machine or VM that allows the use of namespaces and cgroups on the kernel
* A networked machine with access to the internet at least during the initial setup
* The target provisioner machine should have `sudo` available
* The target user on the provisioner machine should have sudo privileges


## Setup the inventory

## Run the playbook

```bash
ansible-playbook -i inventory -K main.yml
```
