#!/command/with-contenv sh

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

#global var
INTERFACE=$(ip addr show | awk '/inet.*brd/{print $NF; exit}')
IP=$(ifconfig $INTERFACE | grep -i mask | awk '{print $2}'| cut -f2 -d:)

 

# gen gfwdns.rsc  
echo "Generating GFWlist for ROS, URL is http://"$IP":5533/gfwdns.rsc ..."


 
