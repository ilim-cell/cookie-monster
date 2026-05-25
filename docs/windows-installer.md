# Windows installer & shim Reference

Files:

- `platforms/windows/install.bat` — batch installer that downloads the release and extracts to `%LOCALAPPDATA%\cookie-monster`.
- `platforms/windows/cookie.bat` — shim that tries to run the installed POSIX `cookie` script with `bash` (Git Bash or WSL) if present.

Behavior & fallbacks

- Download: `curl` first; if that fails the script invokes PowerShell's `Invoke-WebRequest` as a fallback.
- Extract: `tar -xf` first; if that fails it calls PowerShell's `Expand-Archive` as a fallback.
- If neither path is available the script exits with an error and prints guidance.

Notes

- The Windows batch installer intentionally avoids PowerShell as the primary runtime but uses it as a robust fallback because many Windows systems have PowerShell even when they lack `curl`/`tar`.

Usage

```bat
platforms\windows\install.bat
```

Troubleshooting

- If extraction or download fails, ensure either `curl` and `tar` are available (Git for Windows provides them) or that PowerShell is present (it generally is). The installer prints helpful messages on failure.
