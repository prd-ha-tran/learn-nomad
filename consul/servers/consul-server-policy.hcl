agent_prefix "" {
  policy = "write"
}

node_prefix "" {
  policy = "read"
}

node "consul-server1" {
  policy = "write"
}

node "consul-server2" {
  policy = "write"
}

node "consul-server3" {
  policy = "write"
}

operator = "write"