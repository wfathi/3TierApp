# Infrastructure setup of 3 Tier JAVA Application
## Proxmox Virtual Environment Setup Project

### Project Overview
This project automates the setup of a Proxmox Virtual Environment using Vagrant and shell scripting. It creates a virtualization infrastructure with proper networking configuration for hosting virtual machines.

### Features
- Automated Proxmox VE installation and configuration
- Network bridge setup for VM connectivity
- DNS configuration with redundant nameservers
- Vagrant-managed development environment

### Prerequisites
- Vagrant 2.x or higher
- VirtualBox 6.x or higher
- Minimum 4GB RAM available
- 20GB free disk space
- Internet connection for package downloads

### Quick Start
1. Clone the repository:
```bash
git clone <repository-url>
cd <project-directory>
```
2. Start the environment:
```bash
vagrant up
```
### Network Configuration
The system is configured with:

- Bridge interface (vmbr0) for VM networking
- Primary interface (eth0) in bridge mode
- Static IP configuration for Proxmox management
- Redundant DNS servers configuration

### Usage
Access Proxmox web interface:
- URL: https://<proxmox_ip>:8006 but you need to change the hosts file in your OS to proxmox.local
- Terraform user: terraform-prov@pve, who has the rights necessary to create and manage VMs inside of the Proxmox. 

# Contributing
- Fork the repository
- Create a feature branch
- Commit your changes
- Push to the branch
- Create a Pull Request

# Acknowledgments
- Proxmox team for the excellent virtualization platform
- Vagrant team for development automation tools