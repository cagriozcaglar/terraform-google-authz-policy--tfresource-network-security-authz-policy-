# Terraform Google Network Security Authorization Policy

This module creates a Google Cloud Network Security Authorization Policy. Authorization policies are used to define a set of rules that control access to network resources based on attributes like identity, IP address, and HTTP headers.

This module will also enable the `networksecurity.googleapis.com` service API if it is not already enabled.

## Usage

Basic usage of this module is as follows:

```hcl
module "authz_policy" {
  source      = "./path/to/module"
  project_id  = "your-gcp-project-id"
  name        = "my-app-authz-policy"
  location    = "us-central1"
  action      = "ALLOW"
  description = "Authorization policy to allow traffic from internal IPs to my-app"
  labels = {
    env = "production"
  }

  rules = [
    {
      # Rule to allow traffic from a specific IP range
      sources = [{
        ip_blocks = ["10.0.0.0/8"]
      }]
      # Applied to requests for specific hosts and ports
      destinations = [{
        hosts = ["my-app.example.com"]
        ports = [443, 8080]
      }]
    },
    {
      # Rule to allow specific service accounts
      sources = [{
        principals = ["spiffe://your-project.svc.id.goog/ns/default/sa/my-service-account"]
      }]
    }
  ]
}
```

## Requirements

The following sections describe the requirements for using this module.

### Software

The following software is required:

- [Terraform](https://www.terraform.io/downloads.html) >= 1.3.0
- [Terraform Provider for Google Cloud Platform](https://github.com/hashicorp/terraform-provider-google) >= 5.3.0
- [Terraform Provider for Random](https://github.com/hashicorp/terraform-provider-random) >= 3.0

### APIs

A project with the following APIs enabled is required:

- `networksecurity.googleapis.com`

The module will enable this API if it is not already enabled.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| action | The action to take when a rule match is found. Possible values are 'ALLOW' or 'DENY'. | `string` | `"ALLOW"` | no |
| description | A free-text description of the Authorization Policy. | `string` | `null` | no |
| labels | A map of labels to attach to the Authorization Policy. | `map(string)` | `{}` | no |
| location | The location of the authorization policy. Can be 'global' or a region. | `string` | `"global"` | no |
| name | The name of the Authorization Policy. If not provided, a random name will be generated. | `string` | `null` | no |
| project\_id | The project ID in which the Authorization Policy will be created. If not provided, the provider project is used. | `string` | `null` | no |
| rules | <pre>A list of rules that match traffic. A rule consists of a list of sources and a list of destinations.<br>If a traffic is matched by multiple rules, the first matched rule will be enforced.<br>If no rule is matched, the default action is enforced.<br>Each rule object can have the following attributes:<br>- `sources`: (Optional) A list of source specifications. A source specifies a list of identities or a list of IP blocks. Max 1 item.<br>  - `principals`: (Optional) A list of peer identities to match for authorization.<br>  - `ip_blocks`: (Optional) A list of CIDR ranges to match for authorization.<br>- `destinations`: (Optional) A list of destination specifications. A destination specifies a list of hosts, ports, methods, and a header matcher. Max 1 item.<br>  - `hosts`: (Required) A list of host names or FQDNs.<br>  - `ports`: (Required) A list of destination ports to match.<br>  - `methods`: (Optional) A list of HTTP methods to match.<br>  - `http_header_match`: (Optional) A HTTP header matcher. Max 1 item.<br>    - `header_name`: (Required) The name of the HTTP header to match.<br>    - `regex_match`: (Required) The value of the header must match the regular expression.</pre> | <pre>list(object({<br>  sources = optional(list(object({<br>    principals = optional(list(string), [])<br>    ip_blocks  = optional(list(string), [])<br>  })), [])<br>  destinations = optional(list(object({<br>    hosts             = list(string)<br>    ports             = list(number)<br>    methods           = optional(list(string), [])<br>    http_header_match = optional(list(object({<br>      header_name = string<br>      regex_match = string<br>    })), [])<br>  })), [])<br>}))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| create\_time | The timestamp when the authorization policy was created. |
| id | The canonical ID of the authorization policy, in the format `projects/{project}/locations/{location}/authorizationPolicies/{name}`. |
| name | The name of the authorization policy. |
| update\_time | The timestamp when the authorization policy was last updated. |

## Resources

| Name | Type |
|------|------|
| [google_network_security_authorization_policy.authz_policy](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/network_security_authorization_policy) | resource |
| [google_project_service.networksecurity_api](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_project_service) | resource |
| [random_id.default](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [google_client_config.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
