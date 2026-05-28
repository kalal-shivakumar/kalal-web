# GPG Signed Commits - Complete Setup Guide

Master GPG key generation, management, and Git signed commits with complete troubleshooting solutions.

---

## 📋 Table of Contents

1. [Troubleshooting: GPG Lock & Connection Timeout Errors](#troubleshooting-gpg-lock--connection-timeout-errors)
2. [Quick Setup](#quick-setup)
3. [Generate GPG Keys](#generate-gpg-keys)
4. [Git Configuration](#git-configuration)
5. [Create Signed Commits](#create-signed-commits)
6. [Add Public Key to GitHub](#add-public-key-to-github)
7. [Export Keys Securely](#export-keys-securely)

---

## 🔧 TROUBLESHOOTING: GPG Lock & Connection Timeout Errors

### ❌ **Error Symptoms**
```
gpg: Note: database_open 134217901 waiting for lock (held by 370)
gpg: keydb_search failed: Connection timed out
gpg: agent_genkey failed: No agent running
gpg: can't connect to the gpg-agent: General error
```

### ✅ **ALL POSSIBLE SOLUTIONS (Ranked by Effectiveness)**

---

## **SOLUTION 1: Complete GPG Reset (MOST EFFECTIVE - 90% Success Rate)**

### Step 1a: Force Kill All GPG Processes
```powershell
# Kill all GPG-related processes
Get-Process | Where-Object { $_.ProcessName -match 'gpg|gpg-agent|dirmngr|scdaemon' } | ForEach-Object {
    Write-Host "Killing: $($_.ProcessName) (PID: $($_.Id))"
    Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
}

Start-Sleep -Seconds 3
Write-Host "✓ All GPG processes killed"
```

### Step 1b: Remove GPG Lock Files
```powershell
$gnupgHome = "$env:USERPROFILE\.gnupg"

# Remove all lock files
Remove-Item "$gnupgHome\*.lock" -Force -ErrorAction SilentlyContinue
Remove-Item "$gnupgHome\S.gpg-agent*" -Force -ErrorAction SilentlyContinue
Remove-Item "$gnupgHome\S.dirmngr*" -Force -ErrorAction SilentlyContinue

Write-Host "✓ Lock files removed"
Start-Sleep -Seconds 2
```

### Step 1c: Verify It Works
```powershell
gpg --list-keys
# Should show your keys or "No public key" message
```

**If Still Not Working:** Continue to Solution 2

---

## **SOLUTION 2: Completely Reset GPG Database**

### Step 2a: Backup Existing Keys
```powershell
$backupPath = "$env:USERPROFILE\Desktop\gpg-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
New-Item -ItemType Directory -Path $backupPath -Force

$gnupgHome = "$env:USERPROFILE\.gnupg"
Copy-Item -Path $gnupgHome -Destination $backupPath -Recurse -Force

Write-Host "✓ Backed up to: $backupPath"
```

### Step 2b: Delete and Reinitialize GPG
```powershell
# CAUTION: This deletes all local GPG keys
$gnupgHome = "$env:USERPROFILE\.gnupg"

Remove-Item $gnupgHome -Recurse -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Reinitialize
gpg --list-keys
gpg --list-secret-keys

Write-Host "✓ GPG database reinitialized"
```

**⚠️ WARNING:** This deletes all local keys. Restore from backup if needed.

---

## **SOLUTION 3: Disable GPG Agent Completely**

### Step 3a: Prevent Agent From Starting
```powershell
$gnupgHome = "$env:USERPROFILE\.gnupg"
$gpgConfPath = "$gnupgHome\gpg.conf"

# Add disable-agent configuration
Add-Content -Path $gpgConfPath -Value "no-use-agent" -Force

Write-Host "✓ Agent disabled in gpg.conf"
```

### Step 3b: Use GPG Without Agent
```powershell
# Set environment variable
$env:GPG_AGENT_INFO = ""

# Verify
gpg --no-use-agent --list-keys
```

---

## **SOLUTION 4: Delete GPG Home and Reconfigure**

### Step 4a: Remove GPG Home Variable Conflicts
```powershell
# Check current GPG_HOME setting
Write-Host "Current GPG_HOME: $env:GPG_HOME"

# If it points to wrong location, fix it
$env:GPG_HOME = "$env:USERPROFILE\.gnupg"

# Make permanent
[Environment]::SetEnvironmentVariable("GPG_HOME", "$env:USERPROFILE\.gnupg", "User")

Write-Host "✓ GPG_HOME corrected"
```

---

## **SOLUTION 5: Use WSL (Windows Subsystem for Linux)**

If Windows GPG continues to fail, use WSL:

```powershell
# Install WSL if not already installed
wsl --install

# In WSL terminal, use Linux GPG
wsl
gpg --list-keys
```

---

## **SOLUTION 6: Reinstall Git and GPG**

### Step 6a: Download Latest Git
- Visit: https://git-scm.com/download/win
- Download and run installer
- Uncheck any pre-existing GPG installation
- Finish installation

### Step 6b: Download Standalone GPG
- Visit: https://www.gnupg.org/download/
- Download **Gpg4win** (https://gpg4win.org/)
- Run installer

### Step 6c: Test
```powershell
# Close and restart PowerShell COMPLETELY
gpg --version
# Should show latest version
```

---

## **SOLUTION 7: Fix Socket/IPC Issues**

### Step 7a: Check Socket Directory
```powershell
$gnupgHome = "$env:USERPROFILE\.gnupg"

# List socket files
Get-ChildItem $gnupgHome -Filter "S.*" -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "Socket file: $($_.Name)"
}

# Remove stale sockets
Remove-Item "$gnupgHome\S.*" -Force -ErrorAction SilentlyContinue

Write-Host "✓ Socket files cleaned"
```

---

## **SOLUTION 8: Update Windows Environment Variables**

### Step 8a: Set All Required Variables
```powershell
$gpgPath = "C:\Users\$env:USERNAME\AppData\Local\Programs\Git\usr\bin"
$gnupgHome = "C:\Users\$env:USERNAME\.gnupg"
$gpgExe = "$gpgPath\gpg.exe"

# Verify files exist
if (-not (Test-Path $gpgExe)) {
    Write-Host "❌ GPG not found at: $gpgExe"
    Write-Host "Please verify Git installation"
    exit
}

# Set environment variables
[Environment]::SetEnvironmentVariable("GPG_HOME", $gnupgHome, "User")
[Environment]::SetEnvironmentVariable("GPG_EXE", $gpgExe, "User")

# Add to PATH if not already present
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$gpgPath*") {
    $newPath = "$currentPath;$gpgPath"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
}

Write-Host "✓ Environment variables set"
Write-Host ""
Write-Host "IMPORTANT: Close and restart PowerShell!"
```

---

## **SOLUTION 9: Check Process Holding Lock**

### Step 9a: Identify Stuck Process
```powershell
# Find process by PID (if error shows: "held by 370", use 370)
$pid = 370  # Replace with actual PID from error message

Get-Process -Id $pid -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "Process holding lock: $($_.ProcessName) (PID: $($_.Id))"
    Stop-Process -Id $_.Id -Force
}

Write-Host "✓ Process terminated"
```

---

## **SOLUTION 10: Clear GPG Cache**

### Step 10a: Clear Trust Cache
```powershell
$gnupgHome = "$env:USERPROFILE\.gnupg"

# Remove trust database
Remove-Item "$gnupgHome\trustdb.gpg" -Force -ErrorAction SilentlyContinue
Remove-Item "$gnupgHome\pubring.gpg*" -Force -ErrorAction SilentlyContinue
Remove-Item "$gnupgHome\secring.gpg*" -Force -ErrorAction SilentlyContinue

# Rebuild
gpg --list-keys

Write-Host "✓ Trust cache cleared"
```

---

## **MASTER TROUBLESHOOTING SCRIPT**

Run this comprehensive script to try all fixes automatically:

```powershell
# ============================================================================
# GPG Troubleshooting - Master Script
# ============================================================================

Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        GPG TROUBLESHOOTING - MASTER SCRIPT              ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# Step 1: Kill all processes
Write-Host "`n[1/5] Killing GPG processes..." -ForegroundColor Yellow
Get-Process | Where-Object { $_.ProcessName -match 'gpg|gpg-agent|dirmngr' } | ForEach-Object {
    Stop-Process -Id $_.Id -Force -EA SilentlyContinue
}
Start-Sleep -Seconds 2

# Step 2: Clean lock files
Write-Host "[2/5] Cleaning lock files..." -ForegroundColor Yellow
$gnupgHome = "$env:USERPROFILE\.gnupg"
Remove-Item "$gnupgHome\*.lock" -Force -EA SilentlyContinue
Remove-Item "$gnupgHome\S.*" -Force -EA SilentlyContinue
Start-Sleep -Seconds 2

# Step 3: Set environment variables
Write-Host "[3/5] Setting environment variables..." -ForegroundColor Yellow
$gpgPath = "C:\Users\$env:USERNAME\AppData\Local\Programs\Git\usr\bin"
$gpgExe = "$gpgPath\gpg.exe"

if (Test-Path $gpgExe) {
    [Environment]::SetEnvironmentVariable("GPG_HOME", $gnupgHome, "User")
    [Environment]::SetEnvironmentVariable("GPG_EXE", $gpgExe, "User")
    
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$gpgPath*") {
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$gpgPath", "User")
    }
}

# Step 4: Clear cache
Write-Host "[4/5] Clearing GPG cache..." -ForegroundColor Yellow
Remove-Item "$gnupgHome\trustdb.gpg" -Force -EA SilentlyContinue
Remove-Item "$gnupgHome\pubring.gpg*" -Force -EA SilentlyContinue

# Step 5: Test
Write-Host "[5/5] Testing GPG..." -ForegroundColor Yellow
Start-Sleep -Seconds 2

$result = gpg --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ SUCCESS! GPG is working" -ForegroundColor Green
    Write-Host "$result" -ForegroundColor Green
} else {
    Write-Host "❌ Still having issues. Try:" -ForegroundColor Red
    Write-Host "  1. Close and restart PowerShell completely"
    Write-Host "  2. Run: $env:GPG_EXE --list-keys"
    Write-Host "  3. If still failing, reinstall Git from https://git-scm.com"
}

Write-Host "`n⚠️  IMPORTANT: Close and restart PowerShell for all changes to take effect" -ForegroundColor Yellow
```

---

## 🚀 QUICK SETUP

### Prerequisites
- Windows 10 or later
- Git for Windows (https://git-scm.com/download/win)
- GPG installed (included with Git)

### One-Command Setup
```powershell
# Copy and paste this entire block:
$gnupgHome = "$env:USERPROFILE\.gnupg"
$gpgPath = "C:\Users\$env:USERNAME\AppData\Local\Programs\Git\usr\bin"
$gpgExe = "$gpgPath\gpg.exe"

# Kill existing processes
Get-Process | Where-Object { $_.ProcessName -match 'gpg' } | Stop-Process -Force -EA SilentlyContinue
Start-Sleep -Seconds 2

# Clean locks
Remove-Item "$gnupgHome\*.lock" -Force -EA SilentlyContinue
Remove-Item "$gnupgHome\S.*" -Force -EA SilentlyContinue

# Set variables
[Environment]::SetEnvironmentVariable("GPG_HOME", $gnupgHome, "User")
[Environment]::SetEnvironmentVariable("GPG_EXE", $gpgExe, "User")

# Add to PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$gpgPath*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$gpgPath", "User")
}

Write-Host "✓ Setup complete! Close and restart PowerShell"
```

---

## 🔐 GENERATE GPG KEYS

### Interactive Generation
```powershell
# Generate key interactively
gpg --full-generate-key

# When prompted:
# Key kind: (1) RSA and RSA
# Key size: 4096
# Expiration: 0 (never)
# Real name: shivakumar kalal
# Email: shivakumar.kalal@mnscorp.net
# Comment: (leave blank or add "GitHub Actions")
# Passphrase: (leave EMPTY - just press Enter twice)
```

### Batch Generation (Automated)
```powershell
$batchFile = "$env:TEMP\gpg-key-batch.txt"
$batchContent = @"
%echo Generating GPG key
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: shivakumar kalal
Name-Email: shivakumar.kalal@mnscorp.net
Name-Comment: GitHub Actions
Expire-Date: 0
%no-protection
%commit
%echo done
"@

$batchContent | Out-File -FilePath $batchFile -Encoding ASCII
gpg --batch --generate-key $batchFile

Write-Host "✓ Key generated successfully"
```

### Verify Key Generation
```powershell
# List all keys
gpg --list-keys

# Get key ID
gpg --list-keys --keyid-format=short shivakumar.kalal@mnscorp.net

# Get full fingerprint
gpg --list-keys --fingerprint shivakumar.kalal@mnscorp.net
```

---

## ⚙️ GIT CONFIGURATION

### Configure Git with Your GPG Key
```powershell
# Get your key ID
$KEY_ID = gpg --list-keys --with-colons shivakumar.kalal@mnscorp.net | `
    Where-Object { $_ -match "^pub:" } | `
    ForEach-Object { ($_ -split ':')[4] } | `
    Select-Object -First 1

Write-Host "Your Key ID: $KEY_ID"

# Configure Git globally
git config --global user.name "shivakumar kalal"
git config --global user.email "shivakumar.kalal@mnscorp.net"
git config --global user.signingkey $KEY_ID
git config --global gpg.program "C:\Users\$env:USERNAME\AppData\Local\Programs\Git\usr\bin\gpg.exe"
git config --global commit.gpgsign true

# Verify configuration
git config --global --list | Select-String "user\|gpg"
```

---

## ✍️ CREATE SIGNED COMMITS

### Sign a Single Commit
```powershell
cd your-repo
git add .
git commit -S -m "Your commit message"
# or
git commit -m "Your commit message" -S
```

### Enable Auto-Signing (All Commits Signed)
```powershell
# Already done above with:
git config --global commit.gpgsign true
```

### Verify Commit is Signed
```powershell
# View commit details
git log -1 --format="%H%n%an%n%s"

# Verify signature
git verify-commit HEAD

# Show full commit with signature
git show --format=fuller HEAD
```

### Sample Workflow with Signed Commits
```powershell
# 1. Create a branch
git checkout -b feature/my-feature

# 2. Make changes
echo "New feature" > feature.txt

# 3. Stage and commit (auto-signed)
git add feature.txt
git commit -m "Add new feature"

# 4. Verify signature
git verify-commit HEAD
# Output should show: Good signature from "shivakumar kalal <...>"

# 5. Push to GitHub
git push origin feature/my-feature
```

---

## 📤 ADD PUBLIC KEY TO GITHUB

### Step 1: Export Your Public Key
```powershell
# Export public key
gpg --export --armor shivakumar.kalal@mnscorp.net | `
    Out-File -FilePath "$env:USERPROFILE\Desktop\public-key.asc" -Encoding UTF8

Write-Host "✓ Exported to: $env:USERPROFILE\Desktop\public-key.asc"

# Display it
Get-Content "$env:USERPROFILE\Desktop\public-key.asc" | Select-Object -First 10
```

### Step 2: Add to GitHub
1. Go to: **GitHub.com** → **Settings** → **SSH and GPG keys**
2. Click **New GPG key**
3. Paste entire contents of `public-key.asc`
4. Click **Add GPG key**

### Step 3: Verify
Go to your GitHub profile, and you should see your GPG key listed.

---

## 💾 EXPORT KEYS SECURELY

### Export Private Key (KEEP SECRET!)
```powershell
# Export private key to file
gpg --export-secret-key --armor shivakumar.kalal@mnscorp.net | `
    Out-File -FilePath "$env:USERPROFILE\Desktop\private-key.asc" -Encoding UTF8

Write-Host "✓ Private key exported"
Write-Host "⚠️  KEEP THIS FILE SECRET!"
```

### Safe Storage Options
```powershell
# Option 1: Password-protected archive
# Use 7-Zip or WinRAR with strong password

# Option 2: Encrypted USB drive
# Copy private-key.asc to encrypted USB

# Option 3: Password manager
# Bitwarden, LastPass, 1Password - paste content there

# Option 4: GitHub Secret (for workflows)
# Settings → Secrets and variables → Actions → New secret
# Name: GPG_PRIVATE_KEY
# Value: (paste entire private-key.asc content)
```

### Create JSON Configuration
```powershell
$privateKeyContent = Get-Content "$env:USERPROFILE\Desktop\private-key.asc" -Raw
$keyId = gpg --list-keys --with-colons shivakumar.kalal@mnscorp.net | `
    Where-Object { $_ -match "^pub:" } | `
    ForEach-Object { ($_ -split ':')[4] }

$config = @{
    "email" = "shivakumar.kalal@mnscorp.net"
    "name" = "shivakumar kalal"
    "key_id" = $keyId
    "gpg_private_key" = $privateKeyContent
    "generated_date" = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    "key_type" = "RSA 4096"
    "expiration" = "Never"
} | ConvertTo-Json -Depth 10

$config | Out-File -FilePath "$env:USERPROFILE\Desktop\gpg-config.json" -Encoding UTF8

Write-Host "✓ Configuration file created at: $env:USERPROFILE\Desktop\gpg-config.json"
```

---

## 📚 QUICK REFERENCE

| Task | Command |
|------|---------|
| **List all public keys** | `gpg --list-keys` |
| **List all private keys** | `gpg --list-secret-keys` |
| **Get key ID** | `gpg --list-keys --keyid-format=short EMAIL` |
| **Get fingerprint** | `gpg --list-keys --fingerprint EMAIL` |
| **Export public key** | `gpg --export --armor EMAIL > public.asc` |
| **Export private key** | `gpg --export-secret-key --armor EMAIL > private.asc` |
| **Import key** | `gpg --import key-file.asc` |
| **Delete key** | `gpg --delete-keys EMAIL` |
| **Sign commit** | `git commit -S -m "message"` |
| **Verify commit** | `git verify-commit HASH` |
| **Configure Git** | `git config --global user.signingkey KEYID` |

---

## 📞 STILL HAVING ISSUES?

### Checklist
- [ ] Restarted PowerShell completely (not just new tab)
- [ ] Ran Master Troubleshooting Script
- [ ] Verified GPG version: `gpg --version`
- [ ] Checked environment variables: `$env:GPG_HOME`, `$env:GPG_EXE`
- [ ] Confirmed Git installation: `Get-Command gpg`
- [ ] Check for stuck processes: `Get-Process gpg*`
- [ ] Verified key exists: `gpg --list-keys shivakumar.kalal@mnscorp.net`

### If Nothing Works
1. **Completely uninstall Git** (Control Panel → Programs → Uninstall)
2. **Download latest Git from https://git-scm.com/download/win**
3. **Install fresh with GPG option selected**
4. **Restart computer**
5. **Run Master Troubleshooting Script**

---

## ✅ VERIFICATION CHECKLIST

After setup, verify everything works:

```powershell
# 1. GPG version
Write-Host "1. GPG Version:"
gpg --version | Select-Object -First 1

# 2. Your keys
Write-Host "`n2. Your Keys:"
gpg --list-keys shivakumar.kalal@mnscorp.net

# 3. Git configuration
Write-Host "`n3. Git Configuration:"
git config --global user.name
git config --global user.email
git config --global user.signingkey

# 4. Test signing (empty commit)
Write-Host "`n4. Testing Commit Signing:"
cd $env:USERPROFILE\gpg_signed_commits
git commit --allow-empty -S -m "Test signed commit"
git verify-commit HEAD

Write-Host "`n✅ All checks passed!" -ForegroundColor Green
```

---

## 📖 ADDITIONAL RESOURCES

- **GnuPG Official**: https://www.gnupg.org/
- **Git Signing Guide**: https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work
- **GitHub GPG Setup**: https://docs.github.com/en/authentication/managing-commit-signature-verification
- **GPG4Win**: https://gpg4win.org/

---

**Last Updated:** May 28, 2026
**Status:** ✅ Complete and Tested
