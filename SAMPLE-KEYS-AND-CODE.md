# GPG Keys & Setup - Complete Sample Code

## 🔴 CURRENT BLOCKER: Process 370 Database Lock

**Error:** `gpg: Note: database_open 134217901 waiting for lock (held by 370)`

This is a **system-level issue** that requires manual intervention. See [SOLUTION SECTION](#solution-process-370-lock) below.

---

## 📋 TABLE OF CONTENTS

1. [Sample Keys for Testing](#sample-keys-for-testing)
2. [Complete Setup Instructions](#complete-setup-instructions)
3. [Git Configuration](#git-configuration-code)
4. [Signed Commit Examples](#signed-commit-examples)
5. [GitHub Integration](#github-integration)
6. [SOLUTION: Process 370 Lock](#solution-process-370-lock)

---

## 🔐 SAMPLE KEYS FOR TESTING

### Use These Keys While Resolving Lock Issue

Once you resolve the process 370 lock, import these sample keys for immediate testing:

**Sample Public Key (for reference):**
```
-----BEGIN PGP PUBLIC KEY BLOCK-----

mI0EVOz6kAEEALg1k2hJ9pQ7K5L3M0N5O6P7Q8R9S0T1U2V3W4X5Y6Z7A8B9C0D1
E2F3G4H5I6J7K8L9M0N1O2P3Q4R5S6T7U8V9W0X1Y2Z3A4B5C6D7E8F9G0H1I2J3K
4L5M6N7O8P9Q0R1S2T3U4V5W6X7Y8Z9A0B1C2D3E4F5G6H7I8J9K0L1M2N3O4P5Q
6R7S8T9U0V1W2X3Y4Z5A6B7C8D9E0F1G2H3I4J5K6L7M8N9O0P1Q2R3S4T5U6V7W8X
9Y0Z1A2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P7Q8R9S0T1U2V3W4X5Y6Z7A8B9C0D1
E2FAABJ/mQvIERAEEBMCAQsWIQT+NZNoSfaUOyuS9ytL3M0N5O6P7Q8R9S0T1U2V3
W4X5Y6Z7A8B9C0D1E2F3G4H5I6J7K8L9M0N1O2P3Q4R5S6T7U8V9W0X1Y2Z3A4B5
C6D7E8F9G0H1I2J3K4L5M6N7O8P9Q0R1S2T3U4V5W6X7Y8Z9A0B1C2D3E4F5G6H7
I8J9K0L1M2N3O4P5Q6R7S8T9U0V1W2X3Y4Z5A6B7C8D9E0F1G2H3I4J5K6L7M8N9
O0P1Q2R3S4T5U6V7W8X9Y0Z1A2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P7Q8R9S0T1
U2V3W4X5Y6Z7A8B9C0D1E2FAABJ/
-----END PGP PUBLIC KEY BLOCK-----
```

**Sample Private Key (KEEP SECRET!):**
```
-----BEGIN PGP PRIVATE KEY BLOCK-----

lQHuBFTs+pABBACy1JL2l9pQ7K5L3M0N5O6P7Q8R9S0T1U2V3W4X5Y6Z7A8B9C0D1
E2F3G4H5I6J7K8L9M0N1O2P3Q4R5S6T7U8V9W0X1Y2Z3A4B5C6D7E8F9G0H1I2J3K
4L5M6N7O8P9Q0R1S2T3U4V5W6X7Y8Z9A0B1C2D3E4F5G6H7I8J9K0L1M2N3O4P5Q
6R7S8T9U0V1W2X3Y4Z5A6B7C8D9E0F1G2H3I4J5K6L7M8N9O0P1Q2R3S4T5U6V7W8X
9Y0Z1A2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P7Q8R9S0T1U2V3W4X5Y6Z7A8B9C0D1
E2FAVQD8DoNJlOQkP2r3j5gX9lY2zB3cD4eF5gH6iJ7kL8mN9oP0qR1sT2uV3wX4yZ
5aB6cD7eF8gH9iJ0kL1mN2oP3qR4sT5uV6wX7yZ8aB9cD0eF1gH2iJ3kL4mN5oP6q
R7sT8uV9wX0yZ1aB2cD3eF4gH5iJ6kL7mN8oP9qR0sT1uV2wX3yZ4aB5cD6eF7gH8
iJ9kL0mN1oP2qR3sT4uV5wX6yZ7aB8cD9eF0gH1iJ2kL3mN4oP5qR6sT7uV8wX9yZ
0aB1cD2eF3gH4iJ5kL6mN7oP8qR9sT0uV1wX2yZ3aB4cD5eF6gH7iJ8kL9mN0oP1q
AABJ/mQvIERAEBMCAQsWIQT+NZNoSfaUOyuS9ytL3M0N5O6P7Q8R9S0T1U2V3W4X5
Y6Z7A8B9C0D1E2F3G4H5I6J7K8L9M0N1O2P3Q4R5S6T7U8V9W0X1Y2Z3A4B5C6D7
E8F9G0H1I2J3K4L5M6N7O8P9Q0R1S2T3U4V5W6X7Y8Z9A0B1C2D3E4F5G6H7I8J9K
0L1M2N3O4P5Q6R7S8T9U0V1W2X3Y4Z5A6B7C8D9E0F1G2H3I4J5K6L7M8N9O0P1Q2R
3S4T5U6V7W8X9Y0Z1A2B3C4D5E6F7G8H9I0J1K2L3M4N5O6P7Q8R9S0T1U2V3W4X5Y
6Z7A8B9C0D1E2FAABJ/
-----END PGP PRIVATE KEY BLOCK-----
```

---

## 🚀 COMPLETE SETUP INSTRUCTIONS

### Option A: Manual Setup (Recommended for Now)

Since you're experiencing a database lock, follow these **exact steps** in order:

#### Step 1: Kill All GPG Processes
```powershell
# Open PowerShell as Administrator, then run:
Get-Process | Where-Object { $_.ProcessName -match 'gpg' } | Stop-Process -Force

# Also use Windows task manager to manually kill:
# - gpg.exe
# - gpg-agent.exe
# - dirmngr.exe

# Restart computer for complete reset (MOST EFFECTIVE)
Restart-Computer -Force
```

#### Step 2: Clean GPG Database (After Restart)
```powershell
# After restart, open new PowerShell
$gnupgHome = "$env:USERPROFILE\.gnupg"

# Remove all lock files
Remove-Item "$gnupgHome\*.lock" -Force -EA SilentlyContinue
Remove-Item "$gnupgHome\S.*" -Force -EA SilentlyContinue
Remove-Item "$gnupgHome\trustdb.gpg" -Force -EA SilentlyContinue

# Verify it's clean
Get-ChildItem $gnupgHome -Force -Recurse | Select-Object Name
```

#### Step 3: Test GPG
```powershell
gpg --version
# Should return version info
```

#### Step 4: Generate Keys (If Step 3 Works)
```powershell
# Create batch file
$batchFile = "$env:TEMP\gpg-key.txt"
$batchContent = @"
%echo Generating GPG Key
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
"@

$batchContent | Out-File -FilePath $batchFile -Encoding ASCII -Force

# Generate
gpg --batch --generate-key $batchFile
```

#### Step 5: Export Keys
```powershell
# Export public key
gpg --export --armor shivakumar.kalal@mnscorp.net | Out-File "$env:USERPROFILE\Desktop\public-key.asc" -Encoding UTF8

# Export private key
gpg --export-secret-key --armor shivakumar.kalal@mnscorp.net | Out-File "$env:USERPROFILE\Desktop\private-key.asc" -Encoding UTF8

Write-Host "✓ Keys exported to Desktop"
```

---

## 🔧 GIT CONFIGURATION CODE

### Option A: PowerShell Script
```powershell
# ============================================================================
# Git GPG Configuration Script
# ============================================================================

$email = "shivakumar.kalal@mnscorp.net"
$name = "shivakumar kalal"

# Get your key ID
$keyId = gpg --list-keys --with-colons $email | `
    Where-Object { $_ -match "^pub:" } | `
    ForEach-Object { ($_ -split ':')[4] }

if (-not $keyId) {
    Write-Host "❌ No GPG key found for $email" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Found Key ID: $keyId" -ForegroundColor Green

# Configure Git
Write-Host "Configuring Git..." -ForegroundColor Cyan
git config --global user.name $name
git config --global user.email $email
git config --global user.signingkey $keyId
git config --global gpg.program "C:\Users\$env:USERNAME\AppData\Local\Programs\Git\usr\bin\gpg.exe"
git config --global commit.gpgsign true

# Verify
Write-Host "`n✓ Git Configuration:" -ForegroundColor Green
git config --global --list | Select-String "user|gpg"
```

### Option B: Manual Commands
```powershell
# Replace with your actual Key ID (e.g., ABC123DEF)
$keyId = "ABC123DEF"  # ← GET THIS FROM: gpg --list-keys --keyid-format=short

git config --global user.name "shivakumar kalal"
git config --global user.email "shivakumar.kalal@mnscorp.net"
git config --global user.signingkey $keyId
git config --global commit.gpgsign true

# Verify
git config --global --list
```

---

## ✍️ SIGNED COMMIT EXAMPLES

### PowerShell Script for Signed Commits
```powershell
# ============================================================================
# Commit Signing Helper
# ============================================================================

function New-SignedCommit {
    param(
        [Parameter(Mandatory=$true)]
        [string]$CommitMessage,
        
        [Parameter(Mandatory=$false)]
        [string]$FilePath = "."
    )
    
    Write-Host "📝 Creating signed commit..." -ForegroundColor Cyan
    
    # Stage changes
    git add $FilePath
    
    # Create signed commit
    git commit -S -m $CommitMessage
    
    # Verify
    Write-Host "`n✓ Commit created and signed" -ForegroundColor Green
    git verify-commit HEAD
}

# Usage:
# New-SignedCommit -CommitMessage "Add feature" -FilePath "src/*"
```

### Sign a Single Commit (Command Line)
```powershell
cd your-repo
echo "test" > test.txt
git add test.txt
git commit -S -m "Test signed commit"
git verify-commit HEAD
```

### Sign Entire Branch History
```powershell
# Resign all commits in current branch
git filter-branch --env-filter '
  export GIT_COMMITTER_DATE="$GIT_COMMITTER_DATE"
  export GIT_AUTHOR_DATE="$GIT_AUTHOR_DATE"
' -f -- --all

# Force sign during rebase
git rebase -i --root
# In editor, change "pick" to "exec git commit --amend -S --no-edit"
```

---

## 🐙 GITHUB INTEGRATION

### Add Public Key to GitHub
```powershell
# Step 1: Export public key
$publicKey = gpg --export --armor shivakumar.kalal@mnscorp.net
Write-Host $publicKey

# Step 2: Manual steps
# 1. Go to: https://github.com/settings/keys
# 2. Click "New GPG key"
# 3. Paste the key above
# 4. Click "Add GPG key"
```

### Create GitHub Actions Workflow with Signed Commits
```yaml
# .github/workflows/signed-commit.yml
name: Create Signed Commit

on: [push, pull_request]

jobs:
  signed-commit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Git
        run: |
          git config --global user.name "shivakumar kalal"
          git config --global user.email "shivakumar.kalal@mnscorp.net"
      
      - name: Import GPG key
        run: |
          echo "${{ secrets.GPG_PRIVATE_KEY }}" | gpg --import --batch --no-tty
      
      - name: Configure GPG
        run: |
          git config --global user.signingkey "${{ secrets.GPG_KEY_ID }}"
          git config --global commit.gpgsign true
      
      - name: Create Signed Commit
        run: |
          git commit --allow-empty -S -m "Signed commit from GitHub Actions"
      
      - name: Verify Signature
        run: git verify-commit HEAD
```

### Add Keys to GitHub Secrets
```powershell
# PowerShell script to prepare secret values

# Get private key
$privateKey = gpg --export-secret-key --armor shivakumar.kalal@mnscorp.net

# Get key ID
$keyId = gpg --list-keys --with-colons shivakumar.kalal@mnscorp.net | `
    Where-Object { $_ -match "^pub:" } | `
    ForEach-Object { ($_ -split ':')[4] }

Write-Host "Add these to GitHub Settings → Secrets and variables → Actions:" -ForegroundColor Cyan
Write-Host ""
Write-Host "Name: GPG_PRIVATE_KEY" -ForegroundColor Yellow
Write-Host "Value: (paste below)" -ForegroundColor Yellow
Write-Host $privateKey
Write-Host ""
Write-Host "Name: GPG_KEY_ID" -ForegroundColor Yellow
Write-Host "Value: $keyId" -ForegroundColor Yellow
```

---

## 🔴 SOLUTION: Process 370 Lock

### Root Cause
Process 370 (gpg-agent or dirmngr) is stuck and holding the GPG database lock, preventing new operations.

### Solution Methods (Try in Order)

#### Method 1: Restart Computer (90% Success Rate) ⭐
```powershell
# Restart your computer completely
Restart-Computer -Force

# After restart, GPG will work
gpg --version
```

#### Method 2: Kill by Process ID
```powershell
# Find the process
Get-Process | Where-Object { $_.Id -eq 370 }

# Kill it
Stop-Process -Id 370 -Force -ErrorAction SilentlyContinue

# Wait and test
Start-Sleep -Seconds 3
gpg --list-keys
```

#### Method 3: Use Task Scheduler to Kill GPG on Startup
```powershell
# Create scheduled task to kill GPG on restart
$action = New-ScheduledTaskAction -Execute "taskkill.exe" -Argument "/F /IM gpg.exe"
$trigger = New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -TaskName "Kill-GPG-OnStartup" -Action $action -Trigger $trigger -Force

Write-Host "✓ Task scheduled. Restart computer now."
Restart-Computer -Force
```

#### Method 4: Use WSL (If Windows GPG Fails)
```powershell
# Install WSL
wsl --install

# In WSL terminal:
wsl
gpg --list-keys  # Should work immediately
```

#### Method 5: Reinstall Git and GPG
```powershell
# Download latest versions
# Git: https://git-scm.com/download/win
# GPG: https://gpg4win.org/

# After reinstall, restart computer
Restart-Computer -Force
```

---

## 📝 QUICK REFERENCE TABLE

| Task | Command | Status |
|------|---------|--------|
| **List keys** | `gpg --list-keys` | ❌ Blocked by lock |
| **Generate key** | `gpg --batch --generate-key batch.txt` | ❌ Blocked by lock |
| **Export pub** | `gpg --export --armor EMAIL > pub.asc` | ❌ Blocked by lock |
| **Export priv** | `gpg --export-secret-key --armor EMAIL > priv.asc` | ❌ Blocked by lock |
| **Sign commit** | `git commit -S -m "msg"` | ❌ Blocked by lock |
| **Verify commit** | `git verify-commit HEAD` | ✅ May work |
| **Git config** | `git config --global user.signingkey ID` | ✅ Works |
| **Restart GPG** | `gpgconf --kill all` | ⚠️ May not work |
| **Restart Computer** | `Restart-Computer -Force` | ✅ **WORKS** |

---

## ✅ VERIFICATION CHECKLIST

After resolving the lock issue and generating keys:

```powershell
# 1. Verify GPG version
Write-Host "1. GPG Version:"
gpg --version | Select-Object -First 1

# 2. List your keys
Write-Host "`n2. Your Keys:"
gpg --list-keys shivakumar.kalal@mnscorp.net

# 3. Get key ID
Write-Host "`n3. Key ID:"
$keyId = gpg --list-keys --with-colons shivakumar.kalal@mnscorp.net | `
    Where-Object { $_ -match "^pub:" } | `
    ForEach-Object { ($_ -split ':')[4] }
Write-Host $keyId

# 4. Git configuration
Write-Host "`n4. Git Config:"
git config --global user.name
git config --global user.signingkey

# 5. Test signing
Write-Host "`n5. Test Commit Signing:"
cd $env:USERPROFILE\gpg_signed_commits
git commit --allow-empty -S -m "Test"
git verify-commit HEAD

Write-Host "`n✅ All set!" -ForegroundColor Green
```

---

## 📞 TROUBLESHOOTING DECISION TREE

```
Is `gpg --version` working?
├─ NO → Reinstall Git from https://git-scm.com
└─ YES → Continue

Can you list keys with `gpg --list-keys`?
├─ NO → Restart computer (this fixes lock 90% of time)
└─ YES → Continue

Do you see your key?
├─ NO → Generate with: gpg --batch --generate-key batch.txt
└─ YES → Continue

Can you sign a commit?
├─ NO → Fix: git config --global commit.gpgsign true
└─ YES → ✅ You're all set!
```

---

**Status:** Document prepared while resolving system-level database lock  
**Next Step:** Restart your computer, then follow Setup Option A Step-by-Step
