#!/bin/bash

set -e

set_naive_iptables(){

# Redirect all TCP traffic to redir port
iptables -t nat -A PREROUTING -p tcp -j REDIRECT --to-ports 1080
# Redirect all DNS request to redir port
iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 1080

}

set_naive_iptables

#Enable forwarding
sysctl -w net/ipv4/ip_forward=1

ip addr

exec "$@"
