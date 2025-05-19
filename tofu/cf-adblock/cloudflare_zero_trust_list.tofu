locals {
  # Get all response bodies from the data block instances
  all_response_bodies = values(data.http.adblock_hosts_urls)[*].response_body

  # Split each response body into lines and flatten into a single list of lines
  all_lines = flatten([
    for body in local.all_response_bodies :
    split("\n", body)
  ])

  # Filter out lines that are empty or start with '#' (after trimming whitespace)
  filtered_lines = [
    for line in local.all_lines :
    trimspace(line)
    if trimspace(line) != "" && !startswith(trimspace(line), "#")
  ]

  # Sort the filtered lines alphabetically
  sorted_lines = sort(local.filtered_lines)

  # Remove duplicate lines from the sorted list
  domains = distinct(local.sorted_lines)

  # Use chunklist to split a list into fixed-size chunks
  # It returns a list of lists
  chunked_domains = chunklist(local.domains, 1000)
}

data "http" "adblock_hosts_urls" {
  for_each = {
    for i in range(0, length(var.adblock_hosts_urls)) :
    i => element(var.adblock_hosts_urls, i)
  }
  url          = each.value
  method       = "GET"
}

resource "cloudflare_zero_trust_list" "adblock_domain_lists" {
  account_id = var.cloudflare_secondary_account_id

  for_each = {
    for i in range(0, length(local.chunked_domains)) :
    i => element(local.chunked_domains, i)
  }

  name  = "ad_domain_list_${each.key}"
  type  = "DOMAIN"
  items = [ # Transform the list of strings into a list of objects
    for domain_str in each.value : { value = domain_str }
  ]
}
