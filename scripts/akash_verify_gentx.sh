#!/bin/sh

set -e

AKASH_HOME="/tmp/akash$(date +%s)"
RANDOM_KEY="randomvalidatorkeyxx"

GENTX_FILE=$(ls centauri/gentxs -I gosuri.json | head -1)
LEN_GENTX=$(echo ${#GENTX_FILE})

if [ $LEN_GENTX -eq 0 ]; then
    echo "No new gentx file found."
else
    set -e

    echo "...........Init Akash.............."
    curl -L https://github.com/ovrclk/akash/releases/download/v0.6.1/akash_0.6.1_linux_amd64.zip -o akash_linux.zip && unzip akash_linux.zip
    rm akash_linux.zip
    cd akash_0.6.1_linux_amd64

    ./akashd init akash --chain-id centauri --home $AKASH_HOME -o
    echo "y" | ./akashctl keys add $RANDOM_KEY


    ./akashd init --chain-id centauri testvalxyz

    echo "..........Fetching genesis......."
    curl -s https://raw.githubusercontent.com/ovrclk/net/master/centauri/genesis.json > $AKASH_HOME/config/genesis.json

    cp centauri/gentxs/$GENTX_FILE $AKASH_HOME/config/gentx/

    ./akashd add-genesis-account $RANDOM_KEY 9000000uakt --home $AKASH_HOME
    ./akashd add-genesis-account $(cat centauri/gentxs/$GENTX_FILE | sed -n 's|.*"delegator_address":"\([^"]*\)".*|\1|p') 9000000uakt --home $AKASH_HOME

    echo "..........Collecting gentxs......."
    ./akashd collect-gentxs --home $AKASH_HOME
    sed -i '/persistent_peers =/c\persistent_peers = ""' $AKASH_HOME/config/config.toml

    echo "..........Starting node......."
    ./akashd start --home $AKASH_HOME &> /dev/null

    sleep 5s

    echo "...checking network status.."

    ./akashctl status --chain-id centauri

    echo "...Cleaning the stuff..."
    killall akashd > /dev/null 2>&1
    rm -rf $AKASH_HOME > /dev/null 2>&1
fi
