#!/bin/bash

NETWORK=centauri
CONFIG=~/.akashd/config
FAUCET_ACCOUNTS=("akash1czxh6ewhuy00tsv5zu50gz7lz2cxcpufdrarty" "akash1pxc9r4xcynfgkeyp4vk32hghwws82eepfwgaqy" "akash1qjcvelu4rud75jztawcls48luxmapcajvfdhuy")

rm -rf ~/.akashd

akashd init dummy --chain-id centauri

rm -rf $CONFIG/gentx && mkdir $CONFIG/gentx

sed -i "s/\"stake\"/\"uakt\"/g" ~/.akashd/config/genesis.json

for i in $NETWORK/gentxs/*.json; do
  echo $i
  akashd add-genesis-account $(jq -r '.value.msg[0].value.delegator_address' $i) 10000000uakt
  cp $i $CONFIG/gentx/
done

for addr in "${FAUCET_ACCOUNTS[@]}"; do
    echo "Adding faucet addr: $addr"
    akashd add-genesis-account $addr 10000000000000uakt
done

akashd collect-gentxs

akashd validate-genesis

cp $CONFIG/genesis.json $NETWORK