# The variables.tf file is used to define input variables for the module.
# The action to take when a rule match is found.
variable "action" {
  description = "The action to take when a rule match is found. Possible values are 'ALLOW' or 'DENY'."
  type        = string
  default     = "ALLOW"

  validation {
    condition     = contains(["ALLOW", "DENY"], var.action)
    error_message = "The action must be either 'ALLOW' or 'DENY'."
  }
}

# A free-text description of the resource.
variable "description" {
  description = "A free-text description of the Authorization Policy."
  type        = string
  default     = null
}

# Labels to apply to the resource.
variable "labels" {
  description = "A map of labels to attach to the Authorization Policy."
  type        = map(string)
  default     = {}
}

# The location of the authorization policy.
variable "location" {
  description = "The location of the authorization policy. Can be 'global' or a region."
  type        = string
  default     = "global"
}

# The name of the Authorization Policy.
variable "name" {
  description = "The name of the Authorization Policy. If not provided, a random name will be generated."
  type        = string
  default     = null
}

# The project ID in which the resource belongs.
variable "project_id" {
  description = "The project ID in which the Authorization Policy will be created. If not provided, the provider project is used."
  type        = string
  default     = null
}

# A list of rules that match traffic.
variable "rules" {
  description = <<-EOD
    A list of rules that match traffic. A rule consists of a list of sources and a list of destinations.
    If a traffic is matched by multiple rules, the first matched rule will be enforced.
    If no rule is matched, the default action is enforced.
    Each rule object can have the following attributes:
    - `sources`: (Optional) A list of source specifications. A source specifies a list of identities or a list of IP blocks. Max 1 item.
      - `principals`: (Optional) A list of peer identities to match for authorization.
      - `ip_blocks`: (Optional) A list of CIDR ranges to match for authorization.
    - `destinations`: (Optional) A list of destination specifications. A destination specifies a list of hosts, ports, methods, and a header matcher. Max 1 item.
      - `hosts`: (Required) A list of host names or FQDNs.
      - `ports`: (Required) A list of destination ports to match.
      - `methods`: (Optional) A list of HTTP methods to match.
      - `http_header_match`: (Optional) A HTTP header matcher. Max 1 item.
        - `header_name`: (Required) The name of the HTTP header to match.
        - `regex_match`: (Required) The value of the header must match the regular expression.
  EOD
  type = list(object({
    sources = optional(list(object({
      principals = optional(list(string), [])
      ip_blocks  = optional(list(string), [])
    })), [])
    destinations = optional(list(object({
      hosts             = list(string)
      ports             = list(number)
      methods           = optional(list(string), [])
      http_header_match = optional(list(object({
        header_name = string
        regex_match = string
      })), [])
    })), [])
  }))
  default  = []
  nullable = false

  validation {
    condition = alltrue([
      for r in var.rules :
      length(r.sources) <= 1 &&
      length(r.destinations) <= 1 &&
      alltrue([
        for d in r.destinations : length(d.http_header_match) <= 1
      ])
    ])
    error_message = "The 'sources' and 'destinations' attributes within a rule, and 'http_header_match' within a destination, are lists that can have at most one item each."
  }
}
