# Akash Network ::: Testnet -3

## How to submit consensus keys

### Init a new chain and create testnet keys

```sh
akash init --chain-id akash-testnet-3 <your_validator_moniker_name_here>
akash keys add testkey
```

### Fork and Clone the testnets repo
- Fork Akash testnet (https://github.com/ovrclk/net) repo to your personal github account
- Clone the repo
```sh
git clone https://github.com/<your_username>/net
cd testnet-3/val-cons-keys
```

### Copy `Sample.json` and edit 

```sh
cp Sample.json <your_moniker>.json
```
### Edit the file and update with `testkey` address & consensus pubkey.
You can get the consensus pubkey by querying
```sh
akash tendermint show-validator -o json
```

### Update the details and raise a PR

