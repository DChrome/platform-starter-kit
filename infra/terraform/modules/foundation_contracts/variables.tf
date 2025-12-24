variable "namespace" {
  description = "Organizational namespace used for keys in labels and tags (e.g. 'psk', 'acme')."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*$", var.namespace))
    error_message = "namespace must be lowercase alphanumeric or hyphen."
  }
}

variable "project" {
  description = "Stable identifier for this platform/repo (e.g., 'psk'). Used for naming and tagging."
  type        = string

  validation {
    condition     = length(trimspace(var.project)) > 0
    error_message = "project must be a non-empty string."
  }

  # Conservative: lowercase letters/digits/hyphen only.
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$|^[a-z0-9]$", trimspace(var.project)))
    error_message = "project must match ^[a-z0-9][a-z0-9-]*[a-z0-9]$ (lowercase letters, digits, hyphens; no spaces)."
  }
}

variable "env" {
  description = "Environment identifier. Phase-2 default set: local/dev/prod."
  type        = string

  validation {
    condition     = contains(["local", "dev", "prod"], trimspace(lower(var.env)))
    error_message = "env must be one of: local, dev, prod."
  }
}

variable "component" {
  description = "Optional logical component identifier (e.g., 'network', 'eks', 'observability'). Affects name_prefix and tags."
  type        = string
  default     = null

  validation {
    condition = (
      var.component == null ||
      can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$|^[a-z0-9]$", trimspace(var.component)))
    )
    error_message = "component must match ^[a-z0-9][a-z0-9-]*[a-z0-9]$ (lowercase letters, digits, hyphens; no spaces)."
  }
}

variable "owner" {
  description = "Optional ownership identifier for tagging (team/person)."
  type        = string
  default     = null

  validation {
    condition     = var.owner == null || length(trimspace(var.owner)) > 0
    error_message = "owner must be null or a non-empty string."
  }
}

variable "extra_tags" {
  description = "Additional tags merged on top of standard tags."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.extra_tags : length(trimspace(k)) > 0 && length(trimspace(v)) > 0])
    error_message = "extra_tags keys and values must be non-empty strings."
  }
}
