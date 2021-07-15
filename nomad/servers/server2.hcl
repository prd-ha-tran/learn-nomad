datacenter = "dc1"

data_dir = "/nomad/data"

log_level = "INFO"

name = "nomad-server2"

server {
  enabled = true
  bootstrap_expect = 3
  encrypt = "xJlxYdp+WJMZfA3MIdJQgwnoHW8GP9gi1Wl/zh2yofE="
}

tls {
  # ...
  ca_file   = "nomad-ca.pem"
  cert_file = "server.pem"
  key_file  = "server-key.pem"
  # ...
}

acl {
  enabled = true
}

consul {
  address = "127.0.0.1:8500"
  token = "1b27e6f1-1ec2-54c5-3f4c-d4a89ad4fafd"
}