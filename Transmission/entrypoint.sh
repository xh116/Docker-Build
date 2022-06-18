#!/bin/sh -e

cat << "EOF"
 _______ _              _____                     
|__   __(_)            / ____|                    
   | |   _ _ __  _   _| (___   ___ _ ____   _____ 
   | |  | | '_ \| | | |\___ \ / _ \ '__\ \ / / _ \
   | |  | | | | | |_| |____) |  __/ |   \ V /  __/
   |_|  |_|_| |_|\__, |_____/ \___|_|    \_/ \___|
                  __/ |
                 |___/                           
EOF

if [ -n "${PGID}" ] && [ "${PGID}" != "$(id -g transmission)" ]; then
  echo "Switching to PGID ${PGID}..."
  sed -i -e "s/^transmission:\([^:]*\):[0-9]*/transmission:\1:${PGID}/" /etc/group
  sed -i -e "s/^transmission:\([^:]*\):\([0-9]*\):[0-9]*/transmission:\1:\2:${PGID}/" /etc/passwd
fi
if [ -n "${PUID}" ] && [ "${PUID}" != "$(id -u transmission)" ]; then
  echo "Switching to PUID ${PUID}..."
  sed -i -e "s/^transmission:\([^:]*\):[0-9]*:\([0-9]*\)/transmission:\1:${PUID}:\2/" /etc/passwd
fi

IP="$(ifconfig $INTERFACE | grep -i mask | awk '{print $2}'| cut -f2 -d:)"
GATEWAY_IP="$(ip route | grep default | awk '{print $3}')"

 
PUID=${PUID:-1024}
PGID=${PGID:-1024}
USERNAME=${USERNAME:-admin}
PASSWORD=${PASSWORD:-password}
PEER_PORT=${PEER_PORT:-51413}
RPC_PORT=${RPC_PORT:-9091}
TRANSMISSION_WEB_HOME=${TRANSMISSION_WEB_HOME:-/transmission-web-control}


if [ ! -f  /config/settings.json ]; then
echo "Initializing transmission configuration..."
cat >  /config/settings.json <<EOL  
{
    "alt-speed-down": 50,
    "alt-speed-enabled": false,
    "alt-speed-time-begin": 540,
    "alt-speed-time-day": 127,
    "alt-speed-time-enabled": false,
    "alt-speed-time-end": 1020,
    "alt-speed-up": 50,
    "bind-address-ipv4": "0.0.0.0",
    "bind-address-ipv6": "::",
    "blocklist-enabled": false,
    "blocklist-url": "http://www.example.com/blocklist",
    "cache-size-mb": 4,
    "dht-enabled": true,
    "download-dir": "/downloads/complete",
    "download-queue-enabled": true,
    "download-queue-size": 5,
    "encryption": 1,
    "idle-seeding-limit": 30,
    "idle-seeding-limit-enabled": false,
    "incomplete-dir": "/downloads/incomplete",
    "incomplete-dir-enabled": true,
    "lpd-enabled": false,
    "message-level": 2,
    "peer-congestion-algorithm": "",
    "peer-id-ttl-hours": 6,
    "peer-limit-global": 200,
    "peer-limit-per-torrent": 50,
    "peer-port": 51413,
    "peer-port-random-high": 65535,
    "peer-port-random-low": 49152,
    "peer-port-random-on-start": false,
    "peer-socket-tos": "default",
    "pex-enabled": true,
    "port-forwarding-enabled": true,
    "preallocation": 1,
    "prefetch-enabled": 1,
    "queue-stalled-enabled": true,
    "queue-stalled-minutes": 30,
    "ratio-limit": 2,
    "ratio-limit-enabled": false,
    "rename-partial-files": true,
    "rpc-authentication-required": true,
    "rpc-bind-address": "0.0.0.0",
    "rpc-enabled": true,
    "rpc-password": "${PASSWORD}",
    "rpc-port": 9091,
    "rpc-url": "/transmission/",
    "rpc-username": "${USERNAME}",
    "rpc-host-whitelist": "127.0.0.1",
    "rpc-host-whitelist-enabled": false,
    "rpc-whitelist": "127.0.0.1",
    "rpc-whitelist-enabled": false,
    "scrape-paused-torrents-enabled": true,
    "script-torrent-done-enabled": false,
    "script-torrent-done-filename": "",
    "seed-queue-enabled": false,
    "seed-queue-size": 10,
    "speed-limit-down": 100,
    "speed-limit-down-enabled": false,
    "speed-limit-up": 100,
    "speed-limit-up-enabled": false,
    "start-added-torrents": true,
    "trash-original-torrent-files": false,
    "umask": 2,
    "upload-slots-per-torrent": 14,
    "utp-enabled": false,
    "watch-dir": "/watch",
    "watch-dir-enabled": true
}
EOL
fi

echo "Fixing permissions..."
chown transmission:transmission /config \
      /config/settings.json \
      /watch 
      
if [[ ! `df -P -T /downloads | tail -n +2 | awk '{print $2}'` =~ "^(nfs3|nfs4|smb2|smb3|nfs|cifs)$" ]]; then
  chown transmission:transmission /downloads
  else 
  echo "/downloads is a remote directory, please try to grant permissions manually "
fi

chown -R transmission:transmission /var/lib/transmission
 
 
exec su-exec transmission:transmission "$@"
