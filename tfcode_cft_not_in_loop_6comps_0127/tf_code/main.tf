# The main.tf file contains the core resource definition for the Terraform module.
# Retrieves the current client configuration to determine the default project ID.
data "google_client_config" "current" {}

# Generates a random suffix for the authorization policy name if no name is provided.
resource "random_id" "default" {
  # The length of the random string in bytes.
  byte_length = 4
}

# Enables the Network Security API for the project.
resource "google_project_service" "networksecurity_api" {
  # The project ID to enable the API in. Defaults to the provider project if not specified.
  project = coalesce(var.project_id, data.google_client_config.current.project)
  # The service to enable.
  service = "networksecurity.googleapis.com"
  # Do not disable the API when the resource is destroyed.
  disable_on_destroy = false
  # Use the beta provider for this resource.
  provider = google-beta
}

# Creates a Google Network Security Authorization Policy.
# This resource is used to define a set of rules that control access to network resources.
resource "google_network_security_authorization_policy" "authz_policy" {
  # The project ID to create the resource in. Defaults to the provider project if not specified.
  project = coalesce(var.project_id, data.google_client_config.current.project)
  # The name of the authorization policy. A random name is generated if not provided.
  name = coalesce(var.name, "authz-policy-${random_id.default.hex}")
  # The location of the authorization policy.
  location = var.location
  # The action to take when a rule match is found.
  action = var.action
  # A free-text description of the resource.
  description = var.description
  # The labels to apply to the resource.
  labels = var.labels
  # Use the beta provider for this resource, as it is often required for newer network security features.
  provider = google-beta

  # A list of rules that match traffic.
  dynamic "rules" {
    for_each = var.rules
    content {

      # A list of sources.
      dynamic "sources" {
        for_each = rules.value.sources
        content {
          # A list of peer identities to match for authorization.
          principals = sources.value.principals
          # A list of CIDR ranges to match for authorization.
          ip_blocks = sources.value.ip_blocks
        }
      }

      # A list of destinations.
      dynamic "destinations" {
        for_each = rules.value.destinations
        content {
          # A list of host names or FQDNs to match.
          hosts = destinations.value.hosts
          # A list of destination ports to match.
          ports = destinations.value.ports
          # A list of HTTP methods to match.
          methods = destinations.value.methods

          # A HTTP header matcher.
          dynamic "http_header_match" {
            # This dynamic block is used because http_header_match is an optional list block with max 1 item.
            for_each = destinations.value.http_header_match
            content {
              # The name of the HTTP header to match.
              header_name = http_header_match.value.header_name
              # The value of the header must match the regular expression.
              regex_match = http_header_match.value.regex_match
            }
          }
        }
      }
    }
  }
  # Explicit dependency to ensure the API is enabled before creating the policy.
  depends_on = [google_project_service.networksecurity_api]
}
