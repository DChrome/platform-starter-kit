# Bootstrap Scripts

This directory contains self-bootstrapping scripts for configuring GitHub repositories
with consistent, declarative policies. The scripts are **zero-configuration** and
auto-detect the repository owner, name, and default branch from the local Git clone.

## Scripts

### `bootstrap-base.sh`
Applies a **baseline production profile**:
- Protects the default branch (PRs only, admins included)
- Enforces resolved conversations
- Configures merge strategy (squash-only by default, adjust as needed)

Use this for any internal or private repository.

### `bootstrap-oss.sh`
Extends the base profile with **open-source policies**:
- Marks the repository as a template
- Validates presence of recommended OSS files (LICENSE, SECURITY.md, etc.)
- Prepares the repo for public, MIT-licensed distribution

## Usage

Ensure GitHub CLI is installed and authenticated:

```bash
gh auth status >/dev/null 2>&1 || gh auth login
```

Run either script from the repository root:

```bash
./scripts/bootstrap-base.sh
```

or

```bash
./scripts/bootstrap-oss.sh
```

## Idempotency

These scripts are **idempotent**: re-running them will enforce the desired state and
overwrite manual changes to GitHub protection settings.

