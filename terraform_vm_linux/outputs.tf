locals {
  inventory = <<EOF
[master]
${join(
  "\n",
  formatlist(
    "%s ansible_host=%s", 
    azurerm_linux_virtual_machine.master.*.computer_name,
    azurerm_linux_virtual_machine.master.*.public_ip_address,
  ),
  )}
[workers]
${join(
  "\n", 
  formatlist(
    "%s ansible_host=%s", 
    azurerm_linux_virtual_machine.worker.*.computer_name,
    azurerm_linux_virtual_machine.worker.*.public_ip_address,
  ),
  )}

[all:vars]
ansible_user=azureuser
ansible_ssh_private_key_file='../key/terraform'
EOF
}

output "master_vm_ip" {
  value = azurerm_linux_virtual_machine.master.*.public_ip_address
}

output "worker_vm_ip" {
  value = azurerm_linux_virtual_machine.worker.*.public_ip_address
}
