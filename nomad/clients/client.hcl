datacenter = "dc1"

client {
  enabled = true
  encrypt = "xJlxYdp+WJMZfA3MIdJQgwnoHW8GP9gi1Wl/zh2yofE="
}

tls {
  # ...
  ca_file   = "nomad-ca.pem"
  cert_file = "server.pem"
  key_file  = "server-key.pem"
  # ...
}