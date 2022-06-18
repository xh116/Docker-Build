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

WEBUI_PORT=${WEBUI_PORT:-8081}
SESSION_PORT=${SESSION_PORT:-56881}
PUID=${PUID:-1024}
PGID=${PGID:-1024} 

# base on https://github.com/crazy-max/docker-qbittorrent/blob/master/entrypoint.sh

if [ -n "${PGID}" ] && [ "${PGID}" != "$(id -g qbittorrent)" ]; then
  echo "Switching to PGID ${PGID}..."
  sed -i -e "s/^qbittorrent:\([^:]*\):[0-9]*/qbittorrent:\1:${PGID}/" /etc/group
  sed -i -e "s/^qbittorrent:\([^:]*\):\([0-9]*\):[0-9]*/qbittorrent:\1:\2:${PGID}/" /etc/passwd
fi
if [ -n "${PUID}" ] && [ "${PUID}" != "$(id -u qbittorrent)" ]; then
  echo "Switching to PUID ${PUID}..."
  sed -i -e "s/^qbittorrent:\([^:]*\):[0-9]*:\([0-9]*\)/qbittorrent:\1:${PUID}:\2/" /etc/passwd
fi



if [ ! -f  /config/qBittorrent.conf ]; then
  echo "Initializing qBittorrent configuration..."
  cat >  /config/qBittorrent.conf <<EOL  
[General]
ported_to_new_savepath_system=true

[AutoRun]
enabled=false
program=

[BitTorrent]
Session\DefaultSavePath=/downloads
Session\FinishedTorrentExportDirectory=/downloads/torrents
Session\Port=${SESSION_PORT}
Session\QueueingSystemEnabled=true
Session\TempPath=/downloads/incomplete
Session\TempPathEnabled=true

[Core]
AutoDeleteAddedTorrentFile=Never

[LegalNotice]
Accepted=true

[Meta]
MigrationVersion=2

[Preferences]
WebUI\Address=*
WebUI\AlternativeUIEnabled=true
WebUI\Enabled=true
WebUI\HostHeaderValidation=true
WebUI\LocalHostAuth=true
WebUI\RootFolder=/opt/dark_light
WebUI\Port=${WEBUI_PORT}
WebUI\SecureCookie=true
WebUI\ServerDomains=*
WebUI\UseUPnP=true
EOL
fi

echo "Fixing permissions..."
chown -R qbittorrent:qbittorrent /data /config /opt

if [[ ! `df -P -T /downloads | tail -n +2 | awk '{print $2}'` =~ "^(nfs3|nfs4|smb2|smb3|nfs|cifs)$" ]]; then
  chown qbittorrent:qbittorrent /downloads
  else 
  echo "/downloads is a remote directory, please try to grant permissions manually"
fi

chown -R qbittorrent:qbittorrent /home/qbittorrent 

exec su-exec qbittorrent:qbittorrent "$@"
