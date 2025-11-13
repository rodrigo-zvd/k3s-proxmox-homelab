# main.tf

# This resource loops through all nodes defined in var.k3s_nodes
resource "proxmox_vm_qemu" "k3s_node" {
  # Use 'for_each' to create one instance per item in the map
  for_each = var.k3s_nodes

  # --- VM Identification ---
  vmid         = each.value.vmid
  name         = each.key # Uses the map key (e.g., "k3s-node-01")
  tags         = "k3s,terraform"
  force_create = true

  # --- Proxmox Target ---
  target_node = var.proxmox_node_name

  # --- Template Cloning ---
  clone  = var.vm_template_name
  onboot = true
  agent  = 1 # Enable QEMU guest agent

  # --- VM Resources (Proxmox 9+ syntax) ---
  cpu {
    cores   = each.value.cores
    sockets = 1
  }
  memory = each.value.memory

  # --- Cloud-Init (Bootstrapping) ---
  os_type = "cloud-init"

  # Network config
  ipconfig0 = "ip=${each.value.ip}/24,gw=${var.network_gateway}"

  # User and SSH key config
  ciuser  = "ubuntu" # Default user in Ubuntu cloud images
  sshkeys = var.ssh_public_key

  # --- VM Disks (Proxmox 9+ syntax) ---
  # Cloud-init drive
  disk {
    format  = "raw"
    type    = "cloudinit"
    storage = "local-lvm" # Often 'local-lvm' or 'local' for cloud-init
    slot    = "ide2"
  }

  # Root disk
  disk {
    format  = "raw"
    type    = "disk"
    storage = var.proxmox_storage_pool
    size    = "50G" # 50GB disk
    slot    = "scsi0"
  }

  # --- VM Network ---
  network {
    id     = 0
    model  = "virtio"
    bridge = var.network_bridge
  }

  # --- Hardware Config ---
  scsihw = "virtio-scsi-pci"

  serial {
    id   = 0
    type = "socket"
  }

  # --- Provisioning (Ansible Inventory) ---
  connection {
    type        = "ssh"
    user        = "ubuntu" # This must match the 'ciuser'
    host        = each.value.ip
    private_key = file("~/.ssh/id_ed25519") # Your private SSH key
  }

  # Wait for cloud-init to finish before marking the resource as "created"
  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait"
    ]
  }
}

# --- Output ---
# This prints the IPs of the created nodes
output "k3s_node_ips" {
  description = "The static IPs configured for the K3s nodes."
  value = {
    for k, v in proxmox_vm_qemu.k3s_node : k => v.ipconfig0
  }
}