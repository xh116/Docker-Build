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

MODE=${MODE:-server}

if [ "$MODE" = server ] ; then  
     echo "Run hysteria in server mode ..."
     /usr/local/bin/hysteria server --config /etc/config.json 
elif  [ "$MODE" = client ] ; then
     echo "Run hysteria in client mode ..."
    /usr/local/bin/hysteria client --config /etc/config.json 
else 
echo "Something wrong, you may check if the value is correct"   
fi


exit $?
