# BME CLI

This guide provides step-by-step instructions for using the BME (Burn-Mint Equilibrium).

In SDL, pricing must be specified in `uact` instead of `uakt`.

## How to get ACT
ACT becomes the only way to pay for deployment on Akash Network after BME upgrades come to the mainnet.

### How to mint/burn ACT

#### Mint
```shell
akash tx bme mint-act <akt to swap> --from=<your_key_name>
```

#### Burn
```shell
akash tx bme burn-act <uact to burn> --from=<your_key_name>
```

### How to check ACT balance

```shell
akash query bank balances <your key address>
```

ACT mint happens on epochs. Epoch happens at most `min_epoch_blocks` param, which defaults to 10 blocks. If a collateral ratio goes below 0.95
epochs period starts to increase.

## Check bme status

```shell
akash query bme status
```

## Query AKT price

```shell
akash query oracle aggregated-price akt
```
