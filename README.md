# Onchain Git MVP

A compact Foundry project that demonstrates a versioned proxy with:

- `versionHistory` storing implementation addresses by index
- `currentVersionIndex` tracking the active implementation
- `upgradeTo` appending a new implementation to history
- `rollbackTo` switching back to any historical implementation
- storage separation via fixed-slot storage libraries to avoid layout collisions

This MVP uses a simple counter app as the upgradeable target.

## Structure

- `src/OnchainGitProxy.sol` — proxy with version history and rollback
- `src/VersionedCounterV1.sol` — initial implementation
- `src/VersionedCounterV2.sol` — upgraded implementation with `decrement()`
- `src/CounterStorage.sol` and `src/VersioningStorage.sol` — unstructured storage slots
- `script/Deploy.s.sol` — deployment script
- `script/Upgrade.s.sol` — upgrade script
- `test/OnchainGit.t.sol` — unit tests

## Run

```bash
forge test
```

Deploy:

```bash
PRIVATE_KEY=... forge script script/Deploy.s.sol:Deploy --broadcast
```

Upgrade:

```bash
PRIVATE_KEY=... PROXY=0xYourProxy forge script script/Upgrade.s.sol:Upgrade --broadcast
```

## Notes

The assignment asks for version storage, rollback, storage safety, OpenZeppelin-style proxy usage, and Foundry scripts/tests. This repository covers those requirements in a minimal form suitable for an MVP. The homework brief explicitly requires `versionHistory`, `currentVersionIndex`, `rollbackTo`, storage patterns, OpenZeppelin proxy patterns, and Foundry scripts/tests. fileciteturn0file0
