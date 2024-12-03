#!/bin/bash
set -e
# To suppress user prompts 
export DEBIAN_FRONTEND=noninteractive
config_file_path="/vagrant/config.tfvars.json"
proxmox_ip=$(awk -F'"' '/proxmox_ip/ {print $4}' $config_file_path)
password_proxmox_user=$(awk -F'"' '/password_proxmox_user/ {print $4}' $config_file_path)
username_proxmox_user=$(awk -F'"' '/username_proxmox_user/ {print $4}' $config_file_path)
proxmox_tf_user_token_expiration=$(awk -F'"' '/proxmox_tf_user_token_expiration/ {print $4}' $config_file_path)
proxmox_tf_user_token_path=$(awk -F'"' '/proxmox_tf_user_token_path/ {print $4}' $config_file_path)
proxmox_time_zone=$(awk -F'"' '/proxmox_time_zone/ {print $4}' $config_file_path)
proxmox_ubuntu_template_passwd=$(awk -F'"' '/proxmox_ubuntu_template_passwd/ {print $4}' $config_file_path)


echo "Detected Proxmox IP: $proxmox_ip"

source /vagrant/scripts/setup_proxmox.sh
source /vagrant/scripts/setup_tf_user.sh 
source /vagrant/scripts/setup_image_vm_template.sh 