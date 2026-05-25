# Developer Notes

This page collects testing, packaging, and CI guidance for contributors.

Dependency check

Run the included script to validate common tools:

```sh
./check-deps.sh
```

Smoke tests

Run these non-interactive smoke tests locally:

```sh
# Native CLI
chmod +x cookie
./cookie --help

# Native installer (non-interactive)
chmod +x install.sh
./install.sh --update-now

# PowerShell parsing tests (on machines with pwsh or powershell.exe)
# Use the System.Management.Automation.Language.Parser in CI scripts; examples are in .github/workflows/ci.yml
```

CI

- GitHub Actions jobs validate PowerShell scripts on windows-latest, ubuntu-latest, and macos-latest.
- The release workflow packages PowerShell and native artifacts into `dist/cookie-monster.zip`.

Packaging

- If you add platform-specific binaries, add them under `platforms/<os>` and update `.github/workflows/release.yml` to include the artifacts.

Contributing

- Please open a PR for non-trivial changes; the repository may require PRs and signed commits depending on configured protections.
