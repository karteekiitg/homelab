resource "cloudflare_zero_trust_dns_location" "homelab" {
  account_id     = var.cloudflare_account_id
  name           = "HomeLab" # This will be the name in the Cloudflare dashboard
  client_default = true      # Set to true if this should be the default location for WARP clients
  ecs_support    = false

  endpoints = {
    doh = {
      enabled = true # Enables DNS over HTTPS
    }
    dot = {
      enabled = false # DNS over TLS, can be enabled if needed
    }
    ipv4 = {
      enabled = false # Enables a dedicated IPv4 DNS resolver for this location
    }
    ipv6 = {
      enabled = true # Enables a dedicated IPv6 DNS resolver, can be enabled if needed
    }
  }
}

output "dns_location_homelab" {
  description = "DNS location - HomeLab (Cloudflare-assigned IPs)"
  value = {
    # These attributes will be populated with the unique IPs/hostnames assigned by Cloudflare
    # after a successful 'tofu apply'.
    id                      = cloudflare_zero_trust_dns_location.homelab.id # Added ID output for external scripts
    doh                     = "https://${cloudflare_zero_trust_dns_location.homelab.doh_subdomain}.cloudflare-gateway.com/dns-query"
    ipv4_destination        = cloudflare_zero_trust_dns_location.homelab.ipv4_destination
    ipv4_destination_backup = cloudflare_zero_trust_dns_location.homelab.ipv4_destination_backup # May not be populated if only one IPv4 is assigned
    # 'ip' might be populated with an IPv6 if ipv6 endpoint is enabled and assigned.
    # For IPv4, refer to ipv4_destination.
    ip = cloudflare_zero_trust_dns_location.homelab.ip
    # dns_destination_ipv6_block_id is not relevant when Cloudflare assigns IPs.
  }
}

output "dns_location_homelab_id" {
  description = "The ID of the HomeLab DNS location for use in other configurations or scripts."
  value       = cloudflare_zero_trust_dns_location.homelab.id
}
