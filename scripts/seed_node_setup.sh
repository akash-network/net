set -e

export DENOM=uakt
export CHAINID=centauri
export DAEMON=akashd
export CLI=akashctl
export PERSISTENT_PEERS="b29c405d575b76795150cf9b26e44a7b51e72dd8@157.245.119.72:26656,c7c3f86b35dee13958190b301f7f3b8de137fa9e@167.71.138.117:26656"
export GENESIS_URL="https://raw.githubusercontent.com/ovrclk/net/master/centauri/genesis.json"
export AKASH_URL="https://github.com/ovrclk/akash/releases/download/v0.6.1/akash_0.6.1_linux_amd64.deb"

rm -rf ~/.$DAEMON

echo "-----------Installing akash---------"
curl -L $AKASH_URL -o akash_linux.deb
sudo -S dpkg -i akash_linux.deb

echo "-----------Fetching akash path--------"
DAEMON_PATH=$(which $DAEMON)

echo "-----------Init chain---------"
$DAEMON init --chain-id $CHAINID $CHAINID

echo "----------Fetching genesis---------"
curl -s $GENESIS_URL >~/.$DAEMON/config/genesis.json

echo "----------Setting config for seed node---------"
sed -i 's#tcp://127.0.0.1:26657#tcp://0.0.0.0:26657#g' ~/.$DAEMON/config/config.toml
sed -i "/seed_mode =/c\seed_mode = true" ~/.$DAEMON/config/config.toml
sed -i '/persistent_peers =/c\persistent_peers = "'"$PERSISTENT_PEERS"'"' ~/.$DAEMON/config/config.toml
sed -i 's/pruning = "syncable"/pruning = "nothing"/g' ~/.$DAEMON/config/app.toml

echo "---------Creating system file---------"

echo "[Unit]
Description=${DAEMON} daemon
After=network-online.target
[Service]
User=${USER}
ExecStart=${DAEMON_PATH} start --pruning nothing
Restart=always
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
" >$DAEMON.service

sudo mv $DAEMON.service /lib/systemd/system/$DAEMON.service
sudo -S systemctl daemon-reload
sudo -S systemctl start $DAEMON
