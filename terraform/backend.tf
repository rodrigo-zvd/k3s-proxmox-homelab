terraform {
  backend "local" {
    # Caminho ABSOLUTO na sua workstation
    # Ajuste '/home/rodrigo' se seu usuário for diferente
    path = "/home/rodrigo/terraform-states/k3s-homelab.tfstate"
  }
}