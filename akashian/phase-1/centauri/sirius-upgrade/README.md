# Sirius upgrade

## Context - Why Sirius Upgrade?
Centauri network launch was smooth, the first block was produced within 2 seconds and that's remarkable. Later the day, a few validators reported the issues with block rewards and querying distributions. There was a bug in distribution module integration and all the jailed (previously) validators were facing the issues due to that. A new version is released and Sirius upgrade is to upgrade the network to new binary (v0.6.4)

## Schedule
- Upgrade proposal time: 11 May, 00:19 UTC
- Binary release : 11 May, 16:00 UTC
- Voting Period : 11, May - 13 May, 16:00 UTC
- Network Upgrade Time: 15 May, 16:00 UTC

## Proposal Details
|    |            |
|----------|:-------------:|
| Proposal ID |  2 |
| Name |    sirius   |
| Title | Sirius Upgrade | 
| Description | The first ever on-chain upgrade on Akash Network. Sirius upgrade fixes the issues with withdraw rewards txs and double-sign slashing |
| Proposal Time | 2020-05-11 00:19 UTC |
| Voting Start Time | 2020-05-12 16:00 UTC |
| Voting End Time | 2020-05-13 16:00 UTC |
| Network Upgrade Time | 15 May, 16:00 UTC |
| Link | https://akash.aneka.io/proposals/2 |   

## Querying the proposal

Use the following command to query the proposal

```sh
akashctl query gov proposal 2 --chain-id centauri --node http://akash-rpc.vitwit.com:26657 -o json
```

You can query the votes using following command.

```sh
akashctl query gov votes 2 --chain-id centauri --node http://akash-rpc.vitwit.com:26657 -o json
```

## Voting for proposal

Use the following command to vote on the proposal.
```sh
akashctl tx gov vote 2 yes --chain-id centauri --node http://akash-rpc.vitwit.com:26657 --from <key-name>
```

Though you have `yes`/`no`/`abstain`/`no_with_veto` options to vote, it is recommended to choose only `yes` option as this will fix existing bugs on the network.


## How to Upgrade

If the proposal goes through, everyone gets to switch/update their binaries to new version (v0.6.4). The old binary (v0.6.3) will stop working from 15 May, 16:00 UTC and it won't be able to sync/sign new blocks from then.

Note: We should use new binaries only after 15 May, 16:00UTC, if you try to update it before, it fails.

### Download the binaries


### Build from source