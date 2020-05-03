#!/bin/sh

AKASH_HOME="/tmp/akash$(date +%s)"

GENTX_FILE=$(ls centauri/gentxs -I gosuri.json | head -1)
LEN_GENTX=$(echo ${#GENTX_FILE})

if [ $LEN_GENTX -eq 0 ]; then
    echo "No new gentx file found."
else
    rm -rf $AKASH_HOME > /dev/null 2>&1
    killall akashd > /dev/null 2>&1

    set -e

    echo "...........Init akash......."
    ./bins/akashd init akash --chain-id centauri --home $AKASH_HOME -o

    echo "..........Fetching genesis......."
    curl -s https://raw.githubusercontent.com/ovrclk/net/master/centauri/genesis.json > $AKASH_HOME/config/genesis.json

    mkdir $AKASH_HOME/config/gentx
    cp centauri/gentxs/$GENTX_FILE $AKASH_HOME/config/gentx/
    ./bins/akashd add-genesis-account $(cat centauri/gentxs/$GENTX_FILE | sed -n 's|.*"delegator_address":"\([^"]*\)".*|\1|p') 9000000uakt --home $AKASH_HOME

    echo "..........Collecting gentxs......."
    ./bins/akashd collect-gentxs --home $AKASH_HOME
    sed -i '/persistent_peers =/c\persistent_peers = ""' $AKASH_HOME/config/config.toml

    echo "..........Starting node......."
    ./bins/akashd start --home $AKASH_HOME &> /dev/null

    sleep 2s

    echo "...checking network status.."

    ./bins/akashctl status --chain-id centauri

    echo "...Cleaning the stuff..."
    killall akashd > /dev/null 2>&1
    rm -rf $AKASH_HOME > /dev/null 2>&1

fi
