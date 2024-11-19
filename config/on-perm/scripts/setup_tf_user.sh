# Terraform Role to create and manage VMs inside of the proxmox for security reasons
sudo pveum role add TerraformProv -privs "Datastore.Allocate Datastore.AllocateSpace 
 Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit 
 VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk  
 VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Console
 VM.Migrate VM.Monitor VM.PowerMgmt SDN.Use"

# Terraform user
sudo pveum user add $username_proxmox_user --password $password_proxmox_user

# Attach the Terraform role to the user
sudo pveum aclmod / -user $username_proxmox_user -role TerraformProv

# Create a token for the user
sudo pveum user token add $username_proxmox_user terraform -expire $proxmox_tf_user_token_expiration -privsep 0 -comment "Terraform token" > $proxmox_tf_user_token_path

# Append the token to the config file
proxmox_token_value=$(awk '/value.*([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})/ {print $4}' $proxmox_tf_user_token_path)
proxmox_token_id=$(awk '/full-tokenid.{3}([a-zA-Z\-@!]+)/ {print $4}' $proxmox_tf_user_token_path)
sudo apt install -y jq
sudo jq --arg key1 "proxmox_tf_user_token_value" --arg value1 "$proxmox_token_value" \
   --arg key2 "proxmox_tf_user_token_id" --arg value2 "$proxmox_token_id/" \
   '. + {($key1): $value1, ($key2): $value2}' $config_file_path > temp.json && mv temp.json $config_file_path
