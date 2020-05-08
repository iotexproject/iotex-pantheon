# Configure auth methods
path "sys/auth" {
  capabilities = [ "read", "list" ]
}

# Configure auth methods
path "sys/auth/*" {
  capabilities = [ "read", "list" ]
}

# Manage userpass auth methods
path "auth/userpass/*" {
  capabilities = [ "read", "update" ]
}

# Manage github auth methods
path "auth/github/*" {
  capabilities = [ "read", "delete" ]
}

# Display the Policies tab in UI
path "sys/policies" {
  capabilities = [ "read", "list" ]
}

# Create and manage ACL policies from UI
path "sys/policies/acl/*" {
  capabilities = [ "read", "list" ]
}

# Create and manage policies
path "sys/policies/acl" {
  capabilities = [ "read", "list" ]
}

# Create and manage policies
path "sys/policies/acl/*" {
  capabilities = [ "read", "list" ]
}

# List available secrets engines to retrieve accessor ID
path "sys/mounts" {
  capabilities = [ "read" ]
}

# Create and manage entities and groups
path "identity/*" {
  capabilities = [ "read", "list" ]
}
