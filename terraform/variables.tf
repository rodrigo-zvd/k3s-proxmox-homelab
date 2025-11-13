# variables.tf

# --- Proxmox API Credentials (sensitive) ---
# These are loaded from terraform.tfvars (which is git-ignored)
variable "proxmox_api_token_id" {
  type      = string
  sensitive = true
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

# --- Proxmox Host Configuration ---
variable "proxmox_api_url" {
  type        = string
  description = "The Proxmox API URL (e.g., https://172.20.1.10:8006/api2/json)"
  default     = "https://172.20.1.3:8006/api2/json" # Your Proxmox IP
}

variable "proxmox_node_name" {
  type        = string
  description = "The name of the Proxmox node to deploy to"
  default     = "pve" # Your Proxmox node name
}

variable "proxmox_storage_pool" {
  type        = string
  description = "The Proxmox storage pool to use (e.g., local-lvm)"
  default     = "local-lvm" # Your Proxmox storage
}

# --- K3s Cluster Definition ---
variable "vm_template_name" {
  type        = string
  description = "Name of the Ubuntu 22.04 cloud-init template in Proxmox"
  default     = "ubuntu-2204-template" # Your template name
}

variable "ssh_public_key" {
  type        = string
  description = "The SSH public key to inject via cloud-init"
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAN3JnFSajM3rl8Dg6Pj/ffFpE4dYK9dEiftI2Y2Cke0 rodrigo@YogaSlim6" # Your SSH key
}

# --- Node Specifics (Our 3x4GB HA Plan) ---
variable "k3s_nodes" {
  type = map(object({
    vmid   = number
    ip     = string
    memory = number # In MB
    cores  = number
  }))
  description = "Map of K3s nodes to create"
  default = {
    # Node 1
    "k3s-node-01" = {
      vmid   = 100 # VMID 100
      ip     = "172.20.1.50"
      memory = 4096
      cores  = 2
    },
    # Node 2
    "k3s-node-02" = {
      vmid   = 101 # VMID 101
      ip     = "172.20.1.51"
      memory = 4096
      cores  = 2
    },
    # Node 3
    "k3s-node-03" = {
      vmid   = 102 # VMID 102
      ip     = "172.20.1.52"
      memory = 4096
      cores  = 2
    }
  }
}

variable "network_gateway" {
  type    = string
  default = "172.20.1.1" # Your gateway
}

variable "network_bridge" {
  type    = string
  default = "vmbr0" # Your Proxmox bridge
}