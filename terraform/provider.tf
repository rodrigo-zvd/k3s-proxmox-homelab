# provider.tf

terraform {
  required_providers {
    # We use the Telmate provider, which is the standard for Proxmox
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc05" # Pinned version for Proxmox 9
    }
  }
}

# The provider configuration will be populated by variables
provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure     = true # For homelab, skipping cert validation is ok
  pm_log_enable       = false
}