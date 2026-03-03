output "firewall_ip" { value = module.hub_network.firewall_ip }
output "mgmt_vm_ip" { value = module.hub_servers.mgmt_ip }
output "hostpool_id" { value = module.avd.hostpool_id }
output "fslogix_share" { value = module.storage.fslogix_share_name }
output "app_id" { value = module.entra_app.app_id }
