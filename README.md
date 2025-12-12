# Zucoin (ZUCOIN) — Clarity Smart Contract

A SIP-010 compatible fungible token smart contract written in **Clarity** and developed with **Clarinet**.

## Requirements

- **Clarinet** (installed):
  - Verify: `clarinet --version`

## Project layout

- `Clarinet.toml` — Clarinet project manifest
- `contracts/zucoin.clar` — Zucoin token contract
- `settings/` — network configuration templates
- `tests/` — TypeScript test scaffold (optional)

## Quick start

From the repo root:

```powershell
clarinet check -m .\Clarinet.toml
```

(Optional) open a REPL:

```powershell
clarinet console -m .\Clarinet.toml
```

## Contract: `zucoin`

### Token metadata

- **Name:** `Zucoin`
- **Symbol:** `ZUCOIN`
- **Decimals:** `6`

### SIP-010 functions

These follow the SIP-010 fungible token trait interface.

- `transfer(amount, sender, recipient, memo) -> (response bool uint)`
  - Requires `sender == tx-sender`.
- `get-name() -> (response (string-ascii 32) uint)`
- `get-symbol() -> (response (string-ascii 32) uint)`
- `get-decimals() -> (response uint uint)`
- `get-balance(who) -> (response uint uint)`
- `get-total-supply() -> (response uint uint)`

### Admin / supply functions

- `mint(recipient, amount) -> (response bool uint)`
  - **Owner only**.
- `burn(amount) -> (response bool uint)`
  - Burns tokens from `tx-sender`.
- `set-owner(new-owner) -> (response bool uint)`
  - **Owner only**.
- `get-owner() -> (response principal uint)`

### Error codes

| Code | Constant | Meaning |
|------|----------|---------|
| `u100` | `ERR-NOT-AUTHORIZED` | Caller not permitted |
| `u101` | `ERR-NOT-ENOUGH-BALANCE` | Insufficient balance |
| `u102` | `ERR-INVALID-AMOUNT` | Amount must be > 0 |
| `u103` | `ERR-SAME-PRINCIPAL` | Sender and recipient must differ |

## Development

### Format the contract

```powershell
clarinet format -m .\Clarinet.toml
```

### TypeScript tests (optional)

Clarinet scaffolds a TypeScript test runner configuration.

```powershell
npm install
npm test
```

## Notes / security model

- The deployer (`tx-sender` at deploy time) is the initial **contract owner**.
- Only the owner can mint and transfer ownership.
- This implementation intentionally does **not** include allowance/approval logic; `transfer` requires `sender == tx-sender`.
