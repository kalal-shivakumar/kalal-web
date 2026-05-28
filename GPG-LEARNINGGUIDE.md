# Complete Learning Guide: GPG, Signed Commits & GitHub Actions

Master GitHub automation with GPG signing, signed commits, and GitHub Actions workflows.

**How to Use This Guide:**
1. Read each lab section in this file
2. Copy the code block marked `COPY THIS INTO testinglab.yml`
3. Paste into `.github/workflows/testinglab.yml`
4. Commit and push to GitHub
5. Watch the workflow execute on the runner
6. Observe the output and learn

---

# SETUP: Installing and Configuring GPG on Windows

## Prerequisites: Where to Find and Install GPG

### Option 1: GPG via Git Installation (Recommended)
If you have **Git for Windows** installed, GPG is already included!

**Check if GPG is already installed:**
```powershell
Get-Command gpg -ErrorAction SilentlyContinue
```

**If not found, check common locations:**
```powershell
$paths = @(
    "C:\Program Files\GnuPG\bin\gpg.exe",
    "C:\Program Files (x86)\GnuPG\bin\gpg.exe",
    "C:\Program Files\Git\usr\bin\gpg.exe",
    "$env:USERPROFILE\AppData\Local\Programs\Git\usr\bin\gpg.exe"
)
foreach ($path in $paths) {
    if (Test-Path $path) {
        Write-Host "Found GPG at: $path"
        & $path --version
    }
}
```

### Option 2: Download Official GPG for Windows
Visit: https://www.gnupg.org/download/

**Available Downloads:**
- **Gpg4win** (Full GUI suite): https://gpg4win.org/
- **GnuPG Binaries** (Command-line): https://gnupg.org/download/
- **Via Package Managers**: Chocolatey, winget, or scoop

**Install via Chocolatey (if available):**
```powershell
choco install gnupg -y
```

**Install via Scoop (if available):**
```powershell
scoop install gpg
```

### Option 3: Verify GPG Installation
```powershell
# Check version
gpg --version

# Check GPG home directory
gpg --homedir

# List all installed keys
gpg --list-keys
```

---

## Updating Environment Variables

### Step 1: Find Your GPG Installation Path

```powershell
# Method 1: Using Get-Command (if GPG is in PATH)
Get-Command gpg

# Method 2: Search common locations
$gpgPath = "C:\Users\$env:USERNAME\AppData\Local\Programs\Git\usr\bin"
if (Test-Path "$gpgPath\gpg.exe") {
    Write-Host "Found at: $gpgPath"
}
```

### Step 2: Add GPG to User Environment Variables

**Method A: Using PowerShell (Recommended)**

```powershell
# Define GPG path
$gpgPath = "C:\Users\$env:USERNAME\AppData\Local\Programs\Git\usr\bin"

# Add to PATH (User-level)
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$gpgPath*") {
    $newPath = "$currentPath;$gpgPath"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "✓ Added GPG to PATH"
} else {
    Write-Host "✓ GPG already in PATH"
}

# Set GPG_HOME environment variable
$gpgHome = "$env:USERPROFILE\.gnupg"
[Environment]::SetEnvironmentVariable("GPG_HOME", $gpgHome, "User")
Write-Host "✓ Set GPG_HOME=$gpgHome"

# Set GPG_EXE environment variable
[Environment]::SetEnvironmentVariable("GPG_EXE", "$gpgPath\gpg.exe", "User")
Write-Host "✓ Set GPG_EXE=$gpgPath\gpg.exe"

Write-Host ""
Write-Host "IMPORTANT: Close and restart PowerShell for changes to take effect"
```

**Method B: Manual GUI Setup**

1. Press `Win + X` → Click "System"
2. Click "Advanced system settings"
3. Click "Environment Variables"
4. Under "User variables", click "New"
5. Create these variables:
   - **Variable name**: `GPG_HOME` → **Value**: `C:\Users\YOUR_USERNAME\.gnupg`
   - **Variable name**: `GPG_EXE` → **Value**: `C:\Users\YOUR_USERNAME\AppData\Local\Programs\Git\usr\bin\gpg.exe`
   - **Variable name**: `Path` (edit existing) → Add: `;C:\Users\YOUR_USERNAME\AppData\Local\Programs\Git\usr\bin`
6. Click "OK" on all dialogs
7. Restart PowerShell

### Step 3: Verify Environment Variables

```powershell
# After restarting PowerShell, verify:
Write-Host "Current Environment Variables:"
Write-Host "GPG_HOME = $env:GPG_HOME"
Write-Host "GPG_EXE = $env:GPG_EXE"
Write-Host ""
Write-Host "Testing GPG:"
gpg --version
```

---

## Useful GPG Commands Reference

### Basic Commands

```powershell
# Check GPG version
gpg --version

# List all public keys
gpg --list-keys

# List all secret (private) keys
gpg --list-secret-keys

# Show detailed key information
gpg --list-keys --with-subkey-fingerprint

# Show key with long format
gpg --list-keys --keyid-format=long

# Export public key
gpg --export --armor your.email@example.com > public-key.asc

# Export private key (CAREFUL!)
gpg --export-secret-key --armor your.email@example.com > private-key.asc

# Import key from file
gpg --import key-file.asc

# Delete a key
gpg --delete-keys your.email@example.com

# Sign a file
gpg --sign myfile.txt

# Verify a signature
gpg --verify myfile.txt.gpg

# Generate a key interactively
gpg --full-generate-key

# Generate key in batch mode (automated)
gpg --batch --generate-key batch-key.conf
```

### Key Management

```powershell
# Edit key (change expiration, add subkey, etc)
gpg --edit-key your.email@example.com

# Trust a key
gpg --edit-key keyid
# Then type: trust

# Revoke a key
gpg --gen-revoke your.email@example.com > revoke.asc
gpg --import revoke.asc

# Change key passphrase
gpg --passwd your.email@example.com

# Show key fingerprint
gpg --list-keys --fingerprint your.email@example.com

# Get key ID for Git configuration
gpg --list-keys --keyid-format=short your.email@example.com
```

### File Operations

```powershell
# Create cleartext signature (signature visible in text)
gpg --clearsign myfile.txt

# Create detached signature (separate signature file)
gpg --detach-sign myfile.txt

# Verify file signature
gpg --verify myfile.txt.gpg myfile.txt

# Encrypt file (symmetric - uses passphrase)
gpg --symmetric myfile.txt

# Encrypt file (asymmetric - uses recipient's public key)
gpg --encrypt --recipient your.email@example.com myfile.txt

# Decrypt file
gpg --decrypt myfile.txt.gpg > myfile.txt
```

### Git Integration

```powershell
# Configure Git to use GPG key for signing
git config --global user.signingkey KEYID

# Configure GPG program path (if needed)
git config --global gpg.program "C:\Users\YOUR_USERNAME\AppData\Local\Programs\Git\usr\bin\gpg.exe"

# Enable automatic commit signing
git config --global commit.gpgsign true

# Sign a commit
git commit -S -m "Your message"

# Verify commit signature
git verify-commit COMMIT_HASH

# View signed commit
git show --format=fuller COMMIT_HASH
```

---

# GENERATING AND MANAGING YOUR GPG KEYS

## Step 1: Generate Your GPG Key Pair

```powershell
# Interactive key generation
gpg --full-generate-key

# When prompted, answer:
# Key type: (1) RSA and RSA
# Key size: 3072 or 4096
# Expiration: 0 (never expires)
# Real name: Your Name
# Email: your.email@company.com
# Comment: (leave blank or add "GitHub Actions")
# Passphrase: (leave EMPTY - just press Enter twice)
```

**Or use batch mode for automation:**

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
```

---

## 🔐 GPG KEY SECURITY GUIDE: What to Save vs What to Add to GitHub

### ✅ **KEYS TO SAVE SECURELY (Private/Secret)**

#### **1. Private Key File** ⚠️ **MOST IMPORTANT - KEEP SECRET**

```powershell
# Export your PRIVATE KEY
gpg --export-secret-key --armor shivakumar.kalal@mnscorp.net > private-key.asc
```

**Storage Guidelines:**
- ❌ DO NOT commit to Git
- ❌ DO NOT email or upload to websites
- ❌ DO NOT share with anyone
- ✅ Save to Desktop (temporary)
- ✅ Store in password manager (LastPass, 1Password, Bitwarden)
- ✅ Backup to encrypted USB drive
- ✅ Store as GitHub Secret (content only)

**Why This Matters:**
- Your private key is your signing identity
- If leaked, attackers can impersonate you
- Anyone with this key can sign commits as you
- Can be revoked, but signed commits remain valid

---

### ✅ **KEYS TO ADD TO GITHUB (Public/Safe to Share)**

#### **1. Public Key** ✅ **SAFE - SHARE WITH GITHUB**

```powershell
# Export your PUBLIC KEY
gpg --export --armor shivakumar.kalal@mnscorp.net > public-key.asc
```

**Where to Add:**
1. Go to: `GitHub.com` → **Settings** → **SSH and GPG keys** → **GPG keys**
2. Click **New GPG key**
3. Copy entire contents of `public-key.asc` file
4. Paste into GitHub
5. Click **Add GPG key**

**What GitHub Does:**
- Stores your public key linked to your account
- Uses it to verify commits you sign
- Shows ✅ VERIFIED badge on your commits
- Anyone can see this key (it's public!)

---

#### **2. Key ID** ✅ **NEEDED FOR GIT CONFIGURATION**

```powershell
# Get your KEY ID
gpg --list-keys --keyid-format=short shivakumar.kalal@mnscorp.net

# Output example:
# pub   rsa3072/ABC123DEF456 2024-05-27 [SC]
#       ABC123DEF456 is your KEY ID (16 chars)
```

**Use KEY ID to configure Git:**

```powershell
# Configure Git with your KEY ID
git config --global user.signingkey ABC123DEF456
git config --global commit.gpgsign true
```

---

## 📋 COMPLETE SETUP WORKFLOW

### **Step 1: Export Your Keys**

After generating your keys, run these commands:

```powershell
# Export PRIVATE KEY (save securely - NOT in Git)
gpg --export-secret-key --armor shivakumar.kalal@mnscorp.net | Out-File -FilePath "$env:USERPROFILE\Desktop\private-key.asc" -Encoding UTF8

# Export PUBLIC KEY (will add to GitHub)
gpg --export --armor shivakumar.kalal@mnscorp.net | Out-File -FilePath "$env:USERPROFILE\Desktop\public-key.asc" -Encoding UTF8

# Get KEY ID
gpg --list-keys --keyid-format=short shivakumar.kalal@mnscorp.net
```

### **Step 2: Secure Your Private Key**

1. Copy `private-key.asc` from Desktop
2. Store in password manager (Bitwarden, LastPass, 1Password)
3. Or save to encrypted USB drive
4. Or keep in secure folder
5. **Delete the Desktop copy after backing up**

### **Step 3: Add Public Key to GitHub**

1. Go to: `GitHub.com` → **Settings** → **SSH and GPG keys** → **GPG keys**
2. Click **New GPG key**
3. Open `public-key.asc` (Desktop)
4. Copy entire contents
5. Paste into GitHub form
6. Click **Add GPG key**

**Verify:** You should see ✅ VERIFIED badge on your GitHub profile

### **Step 4: Store Private Key as GitHub Secret** (For Workflows)

1. Go to your GitHub repository
2. **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. **Name**: `GPG_PRIVATE_KEY`
5. **Value**: Copy entire contents of `private-key.asc`
6. Click **Add secret**

**Now workflows can:**
- Import your private key from secret
- Sign commits automatically
- Create verified commits in GitHub Actions

### **Step 5: Configure Git Locally**

```powershell
# Get your KEY ID (from step 1)
$keyId = "ABC123DEF456"  # Replace with your actual KEY ID

# Configure Git globally
git config --global user.name "shivakumar kalal"
git config --global user.email "shivakumar.kalal@mnscorp.net"
git config --global user.signingkey $keyId
git config --global commit.gpgsign true

# Verify configuration
git config --global --list | Select-String "user\|gpg"
```

---

## 🔑 Complete Security Summary Table

| Item | What It Is | Where It Goes | Who Can Have It | Risk Level |
|------|-----------|---------------|-----------------|-----------|
| **Private Key** | Secret signing material | Desktop (temp), Password Manager, GitHub Secret | ONLY YOU | 🔴 CRITICAL |
| **Public Key** | Verification material | GitHub Settings (GPG Keys) | Everyone | 🟢 SAFE |
| **Key ID** | Reference to your keys | Git config, GitHub profile | Everyone | 🟢 SAFE |
| **KEY ID + Public Key** | Verification pair | Commits on GitHub | Everyone | 🟢 SAFE |

---

## ⚠️ Important Security Notes

### **Private Key Security:**
- Treat like a password
- Never share or expose
- Keep backed up in secure location
- If compromised, revoke immediately:
  ```powershell
  gpg --gen-revoke shivakumar.kalal@mnscorp.net > revoke.asc
  gpg --import revoke.asc
  ```

### **Public Key Distribution:**
- Safe to share everywhere
- Add to GitHub, Keybase, LinkedIn
- Include in email signature if desired
- Cannot be used to sign commits (only verify)

### **GitHub Secret Best Practices:**
- Store ONLY in private repositories
- Rotate keys annually
- Use separate keys for different purposes (personal vs work)
- Monitor GitHub Security Logs for suspicious activity

---

## Verification Checklist

After setup, verify everything works:

```powershell
# ✓ 1. Check key exists locally
gpg --list-keys shivakumar.kalal@mnscorp.net

# ✓ 2. Check Git configuration
git config --global user.signingkey
git config --global commit.gpgsign

# ✓ 3. Test signing a commit
cd your-repo
git commit --allow-empty -m "Test signed commit" -S

# ✓ 4. Verify the signature
git verify-commit HEAD

# ✓ 5. Push and check GitHub
git push
# Then view commit on GitHub - should show ✅ VERIFIED badge
```

---

# PART 1: GIT BASICS ON GITHUB RUNNER

## Lab 1.1: Basic Git Commands Execution

**Objective:** Learn and execute basic git commands on GitHub runner.

**Concepts:**
- Git configuration on runner
- Checking git version
- Viewing current directory
- Understanding runner environment

**COPY THIS INTO testinglab.yml:**

```yaml
name: Lab 1.1 - Basic Git Commands

on:
  workflow_dispatch:
  push:
    branches: [ main ]

jobs:
  basic-git:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout Repository
      uses: actions/checkout@v3
    
    - name: Check Git Version
      run: |
        echo "=== Git Version ==="
        git --version
    
    - name: Configure Git User
      run: |
        echo "=== Configuring Git User ==="
        git config --global user.name "GitHub Actions"
        git config --global user.email "actions@example.com"
        
        echo "User configured:"
        git config --global user.name
        git config --global user.email
    
    - name: Check Current Directory
      run: |
        echo "=== Current Working Directory ==="
        pwd
        echo ""
        echo "=== Files in Repository ==="
        ls -la
    
    - name: View Git Status
      run: |
        echo "=== Git Status ==="
        git status
    
    - name: View Git Log
      run: |
        echo "=== Last 5 Commits ==="
        git log --oneline -5
    
    - name: Get Current Branch
      run: |
        echo "=== Current Branch ==="
        git branch --show-current
        
        echo ""
        echo "=== All Branches ==="
        git branch -a
    
    - name: Get Repository Information
      run: |
        echo "=== Repository Information ==="
        git config --get remote.origin.url
        
        echo ""
        echo "=== HEAD Information ==="
        git rev-parse HEAD
        
        echo ""
        echo "=== Current Commit ==="
        git log -1 --oneline
```

**What You'll Learn:**
- How git is configured on the runner
- How to check git version
- How to view repository files
- How to see commit history
- How to check current branch

---

## Lab 1.2: Creating Files on the Runner

**Objective:** Create and manage files during workflow execution.

**Concepts:**
- Creating files dynamically
- Writing content to files
- Checking file contents
- Organizing created files

**COPY THIS INTO testinglab.yml:**

```yaml
name: Lab 1.2 - Creating Files

on:
  workflow_dispatch:
  push:
    branches: [ main ]

jobs:
  create-files:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout Repository
      uses: actions/checkout@v3
    
    - name: Configure Git
      run: |
        git config --global user.name "GitHub Actions"
        git config --global user.email "actions@example.com"
    
    - name: Create Project Directory
      run: |
        mkdir -p lab-test-files
        echo "✓ Created directory: lab-test-files"
    
    - name: Create First File
      run: |
        cat > lab-test-files/file1.txt << 'EOF'
        This is the first file created by GitHub Actions.
        Created on: $(date)
        Location: GitHub Runner
        EOF
        
        echo "✓ Created file1.txt"
    
    - name: Create Second File (with Variables)
      run: |
        cat > lab-test-files/file2.txt << EOF
        File Created by GitHub Actions
        ================================
        
        Repository: ${{ github.repository }}
        Branch: ${{ github.ref }}
        Commit: ${{ github.sha }}
        Actor: ${{ github.actor }}
        Run ID: ${{ github.run_id }}
        Created at: $(date)
        EOF
        
        echo "✓ Created file2.txt with dynamic content"
    
    - name: Create Configuration File
      run: |
        cat > lab-test-files/config.json << 'EOF'
        {
          "app_name": "Lab Test Application",
          "version": "1.0.0",
          "created_by": "GitHub Actions",
          "environment": "ci-cd"
        }
        EOF
        
        echo "✓ Created config.json"
    
    - name: Create Markdown Documentation
      run: |
        cat > lab-test-files/README.md << 'EOF'
        # Lab Test Project
        
        This project was created by a GitHub Actions workflow.
        
        ## Files
        - file1.txt: Simple text file
        - file2.txt: File with GitHub context variables
        - config.json: Configuration in JSON format
        EOF
        
        echo "✓ Created README.md"
    
    - name: List All Created Files
      run: |
        echo "=== Created Files ==="
        ls -lh lab-test-files/
    
    - name: Display File Contents
      run: |
        echo "=== file1.txt ==="
        cat lab-test-files/file1.txt
        
        echo ""
        echo "=== config.json ==="
        cat lab-test-files/config.json
```

**What You'll Learn:**
- Creating directories in workflows
- Writing files with cat and heredocs
- Using GitHub context variables in files
- Listing and displaying created files

---

## Lab 1.3: Staging and Committing Files

**Objective:** Create commits in the workflow without signing.

**Concepts:**
- Staging files with `git add`
- Creating commits with `git commit`
- Viewing commit history
- Understanding commit messages

**COPY THIS INTO testinglab.yml:**

```yaml
name: Lab 1.3 - Staging and Committing

on:
  workflow_dispatch:
  push:
    branches: [ main ]

jobs:
  git-commit:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout Repository
      uses: actions/checkout@v3
    
    - name: Configure Git
      run: |
        git config --global user.name "Lab Committer"
        git config --global user.email "lab@example.com"
    
    - name: Create Files to Commit
      run: |
        mkdir -p workflow-artifacts
        
        cat > workflow-artifacts/feature1.txt << 'EOF'
        Feature 1: User Authentication System
        
        - User registration
        - Login functionality
        - Password reset
        - Session management
        EOF
        
        cat > workflow-artifacts/feature2.txt << 'EOF'
        Feature 2: API Endpoints
        
        - GET /users
        - POST /users
        - PUT /users/:id
        - DELETE /users/:id
        EOF
        
        echo "✓ Files created for committing"
    
    - name: Check Git Status (Before Staging)
      run: |
        echo "=== Git Status Before Staging ==="
        git status
    
    - name: Stage Files (git add)
      run: |
        echo "=== Staging Files ==="
        git add workflow-artifacts/
        
        echo ""
        echo "=== Git Status After Staging ==="
        git status
    
    - name: Create First Commit
      run: |
        echo "=== Creating First Commit ==="
        git commit -m "Add feature files"
        
        echo ""
        echo "=== Commit Created ==="
        git log -1 --oneline
    
    - name: Create Second Commit
      run: |
        cat > workflow-artifacts/testing.md << 'EOF'
        # Testing Documentation
        
        ## Unit Tests
        - Feature 1 tests
        - Feature 2 tests
        - Integration tests
        EOF
        
        git add workflow-artifacts/testing.md
        git commit -m "Add testing documentation"
    
    - name: View Commit History
      run: |
        echo "=== Commit History ==="
        git log --oneline -5
```

**What You'll Learn:**
- Configuring git user on runner
- Staging files with `git add`
- Creating commits with `git commit`
- Writing commit messages
- Viewing commit history

---

# PART 2: GIT BRANCHES

## Lab 2.1: Creating and Switching Branches

**Objective:** Master branch operations in workflows.

**Concepts:**
- Creating new branches
- Listing branches
- Switching between branches
- Understanding branch structure

**COPY THIS INTO testinglab.yml:**

```yaml
name: Lab 2.1 - Creating and Switching Branches

on:
  workflow_dispatch:
  push:
    branches: [ main ]

jobs:
  branch-operations:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout Repository
      uses: actions/checkout@v3
      with:
        fetch-depth: 0
    
    - name: Configure Git
      run: |
        git config --global user.name "Branch Manager"
        git config --global user.email "branch@example.com"
    
    - name: Display Current Branch
      run: |
        echo "=== Current Branch ==="
        git branch --show-current
        
        echo ""
        echo "=== All Local Branches ==="
        git branch
    
    - name: Create Feature Branch
      run: |
        echo "=== Creating Feature Branch ==="
        BRANCH_NAME="feature/user-auth-$(date +%s)"
        git checkout -b $BRANCH_NAME
        
        echo "✓ Branch created: $BRANCH_NAME"
        echo "FEATURE_BRANCH=$BRANCH_NAME" >> $GITHUB_ENV
    
    - name: Verify Branch Creation
      run: |
        echo "=== Verifying Branch Creation ==="
        echo "Current branch: $(git branch --show-current)"
        
        echo ""
        echo "All branches:"
        git branch
    
    - name: Create Multiple Branches
      run: |
        echo "=== Creating Multiple Branches ==="
        
        BRANCHES=("develop" "feature/api" "feature/database" "hotfix/bug-fix")
        
        for branch in "${BRANCHES[@]}"; do
          git checkout -b $branch
          echo "✓ Created: $branch"
          git checkout main
        done
        
        echo ""
        echo "All created branches:"
        git branch
    
    - name: Switch Between Branches
      run: |
        echo "=== Switching Between Branches ==="
        
        git checkout develop
        echo "✓ Switched to: $(git branch --show-current)"
        
        git checkout feature/api
        echo "✓ Switched to: $(git branch --show-current)"
        
        git checkout main
        echo "✓ Back to: $(git branch --show-current)"
```

**What You'll Learn:**
- Creating branches with `git checkout -b`
- Listing branches
- Switching between branches
- Understanding branch hierarchy

---

## Lab 2.2: Making Changes in Feature Branches

**Objective:** Create files and commits in feature branches.

**Concepts:**
- Making changes in branches
- Committing in branches
- Keeping main branch clean
- Feature branch workflow

**COPY THIS INTO testinglab.yml:**

```yaml
name: Lab 2.2 - Making Changes in Feature Branches

on:
  workflow_dispatch:
  push:
    branches: [ main ]

jobs:
  feature-branch-work:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout Repository
      uses: actions/checkout@v3
    
    - name: Configure Git
      run: |
        git config --global user.name "Feature Developer"
        git config --global user.email "developer@example.com"
    
    - name: Create Feature Branch
      run: |
        FEATURE_BRANCH="feature/add-auth-$(date +%s)"
        git checkout -b $FEATURE_BRANCH
        echo "FEATURE_BRANCH=$FEATURE_BRANCH" >> $GITHUB_ENV
        
        echo "✓ Working on: $FEATURE_BRANCH"
    
    - name: Create Auth Module Files
      run: |
        mkdir -p src/auth
        
        cat > src/auth/auth.py << 'EOF'
        """Authentication Module"""
        
        class AuthManager:
            def __init__(self):
                self.users = {}
            
            def register_user(self, username, password):
                self.users[username] = password
                return True
            
            def authenticate(self, username, password):
                return username in self.users and self.users[username] == password
        EOF
        
        echo "✓ Created auth.py"
    
    - name: Create Documentation
      run: |
        cat > src/auth/README.md << 'EOF'
        # Authentication Module
        
        Provides user authentication functionality.
        
        ## Usage
        ```python
        from auth import AuthManager
        auth = AuthManager()
        auth.register_user("user", "pass")
        ```
        EOF
        
        echo "✓ Created README.md"
    
    - name: Commit Changes
      run: |
        git add src/auth/
        git commit -m "Implement authentication module" \
          -m "- Add AuthManager class" \
          -m "- Implement user registration"
        
        echo "✓ Changes committed"
        git log -1 --oneline
    
    - name: Verify Main Branch is Clean
      run: |
        git checkout main
        
        echo "=== Main Branch ==="
        echo "Files in main (src/ should not exist):"
        ls -la | grep src || echo "✓ src/ not in main branch"
        
        echo ""
        git checkout ${{ env.FEATURE_BRANCH }}
        echo "✓ Feature branch contains changes"
```

**What You'll Learn:**
- Creating files in feature branches
- Making multiple commits
- Keeping main branch clean
- Feature branch workflow

---

# PART 3: GPG SIGNING

---

## Lab 3.0: Local GPG Key Management - Regenerate & Remove Keys

**Objective:** Learn how to remove old GPG keys and regenerate new ones locally on Windows.

**When to Use This:**
- Your old keys are compromised or expired
- You need to create a fresh key pair for GitHub
- You want to test GPG locally before using in workflows
- You have database lock errors preventing key generation

---

### Step 1: Remove Old Keys Completely

#### Option A: Using PowerShell Script (Recommended)

```powershell
# ============================================================================
# Remove Old GPG Keys - Complete Reset
# ============================================================================

Write-Host "Removing old GPG keys..." -ForegroundColor Yellow

# Step 1: Kill all GPG processes
Write-Host "Step 1: Terminating all GPG processes..."
Get-Process | Where-Object { $_.ProcessName -match 'gpg' } | ForEach-Object {
    Write-Host "  Killing: $($_.ProcessName) (PID: $($_.Id))"
    Stop-Process -Id $_.Id -Force -EA SilentlyContinue
}

# Alternative: Use Windows taskkill command
taskkill /F /IM gpg.exe 2>$null
taskkill /F /IM gpg-agent.exe 2>$null
Start-Sleep -Seconds 3
Write-Host "✓ All GPG processes terminated"

# Step 2: Kill GPG services using gpgconf
Write-Host "`nStep 2: Stopping GPG services..."
gpgconf --kill all 2>&1
Start-Sleep -Seconds 2
Write-Host "✓ GPG services stopped"

# Step 3: Remove old keys and database
Write-Host "`nStep 3: Removing old keys and database..."
$gnupgHome = "$env:USERPROFILE\.gnupg"

if (Test-Path $gnupgHome) {
    Write-Host "  Removing directory: $gnupgHome"
    Remove-Item $gnupgHome -Recurse -Force -EA SilentlyContinue
    Write-Host "✓ Old keys removed"
} else {
    Write-Host "✓ No old keys found (already clean)"
}

# Step 4: Remove any exported key files
Write-Host "`nStep 4: Removing exported key files..."
$keysToRemove = @(
    "C:\Users\$env:USERNAME\Desktop\*key.asc",
    "C:\Users\$env:USERNAME\Desktop\public-key.asc",
    "C:\Users\$env:USERNAME\Desktop\private-key.asc",
    "C:\Users\$env:USERNAME\gpg_signed_commits\*key.asc"
)

foreach ($pattern in $keysToRemove) {
    Get-Item $pattern -EA SilentlyContinue | Remove-Item -Force -EA SilentlyContinue
}
Write-Host "✓ Old key files removed"

Write-Host "`n" + ("=" * 70) -ForegroundColor Green
Write-Host "✅ OLD KEYS COMPLETELY REMOVED" -ForegroundColor Green
Write-Host ("=" * 70) -ForegroundColor Green
```

#### Option B: Manual Steps (If Script Doesn't Work)

```powershell
# Kill processes manually
Get-Process gpg* | Stop-Process -Force

# Wait a few seconds
Start-Sleep -Seconds 5

# Remove the .gnupg folder manually
$gnupgHome = "$env:USERPROFILE\.gnupg"
Remove-Item $gnupgHome -Recurse -Force

# Delete exported key files from Desktop
Get-ChildItem "$env:USERPROFILE\Desktop" -Filter "*key.asc" | Remove-Item -Force
```

---

### Step 2: Generate New GPG Key

#### Complete Key Generation Script

```powershell
# ============================================================================
# Generate New GPG Key - Complete Script
# ============================================================================

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║          GENERATING NEW GPG KEY PAIR                         ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# Step 1: Verify GPG is working
Write-Host "`nStep 1: Verifying GPG installation..."
$gpgVersion = gpg --version 2>&1 | Select-Object -First 1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ GPG not working. Install from: https://git-scm.com/download/win"
    exit 1
}
Write-Host "✓ $gpgVersion"

# Step 2: Create batch file for key generation
Write-Host "`nStep 2: Creating key generation batch file..."
$batchFile = "$env:TEMP\gpg-new-key.txt"
$batchContent = @"
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: shivakumar kalal
Name-Email: shivakumar.kalal@mnscorp.net
Name-Comment: GitHub
Expire-Date: 0
%no-protection
%commit
"@

$batchContent | Out-File $batchFile -Encoding ASCII -Force
Write-Host "✓ Batch file created at: $batchFile"

# Step 3: Generate key
Write-Host "`nStep 3: Generating RSA 4096-bit key pair..."
Write-Host "⏳ This may take 30-60 seconds..." -ForegroundColor DarkCyan

$generateOutput = gpg --batch --generate-key $batchFile 2>&1
Write-Host "✓ Key generation completed"

# Step 4: Verify key was created
Write-Host "`nStep 4: Verifying key creation..."
$keyList = gpg --list-keys shivakumar.kalal@mnscorp.net 2>&1

if ($keyList -match "rsa4096") {
    Write-Host "✓ Key successfully created!" -ForegroundColor Green
} else {
    Write-Host "⚠️ Could not verify key creation" -ForegroundColor Yellow
    Write-Host "Output: $keyList"
}

Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan
Write-Host "Key Information:" -ForegroundColor Green
Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host $keyList

# Step 5: Get Key ID
$keyInfo = gpg --list-keys --with-colons shivakumar.kalal@mnscorp.net 2>&1
$keyId = $keyInfo | Where-Object { $_ -match "^pub:" } | `
    ForEach-Object { ($_ -split ':')[4] }

Write-Host "`n✓ Key ID: $keyId" -ForegroundColor Green
```

---

### Step 3: Export Public and Private Keys

#### Export Script

```powershell
# ============================================================================
# Export Keys
# ============================================================================

Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║              EXPORTING KEYS                                  ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$workDir = "C:\Users\$env:USERNAME\gpg_signed_commits"
cd $workDir

# Export public key
Write-Host "`nExporting public key..."
gpg --export --armor shivakumar.kalal@mnscorp.net | `
    Out-File -Encoding UTF8 -FilePath public-key.asc -Force
Write-Host "✓ Public key saved to: $workDir\public-key.asc"

# Export private key
Write-Host "`nExporting private key..."
gpg --export-secret-key --armor shivakumar.kalal@mnscorp.net | `
    Out-File -Encoding UTF8 -FilePath private-key.asc -Force
Write-Host "✓ Private key saved to: $workDir\private-key.asc"

# Display public key
Write-Host "`n" + ("=" * 70) -ForegroundColor Green
Write-Host "PUBLIC KEY - COPY THIS TO GITHUB" -ForegroundColor Green
Write-Host ("=" * 70) -ForegroundColor Green
Get-Content public-key.asc

Write-Host "`n⚠️  Private key saved securely (not displayed)" -ForegroundColor Yellow
Write-Host "Location: $workDir\private-key.asc"
```

---

### Complete Combined Script: Remove + Generate + Export

Save this as `regenerate-gpg-keys.ps1`:

```powershell
# ============================================================================
# COMPLETE: Remove Old Keys, Generate New Ones, Export Both
# ============================================================================

param(
    [string]$Name = "shivakumar kalal",
    [string]$Email = "shivakumar.kalal@mnscorp.net",
    [string]$Comment = "GitHub"
)

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║    GPG KEY REGENERATION - COMPLETE WORKFLOW                 ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# ============================================================================
# PHASE 1: REMOVE OLD KEYS
# ============================================================================
Write-Host "`n[PHASE 1] Removing old keys and database..." -ForegroundColor Yellow

# Kill processes
Get-Process | Where-Object { $_.ProcessName -match 'gpg' } | `
    Stop-Process -Force -EA SilentlyContinue
gpgconf --kill all 2>&1
Start-Sleep -Seconds 3

# Remove database
$gnupgHome = "$env:USERPROFILE\.gnupg"
Remove-Item $gnupgHome -Recurse -Force -EA SilentlyContinue

# Remove exported files
Get-Item "C:\Users\$env:USERNAME\gpg_signed_commits\*key.asc" -EA SilentlyContinue | `
    Remove-Item -Force

Write-Host "✓ Old keys removed"

# ============================================================================
# PHASE 2: GENERATE NEW KEY
# ============================================================================
Write-Host "`n[PHASE 2] Generating new key pair..." -ForegroundColor Yellow

$batchFile = "$env:TEMP\gpg-new-key.txt"
@"
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: $Name
Name-Email: $Email
Name-Comment: $Comment
Expire-Date: 0
%no-protection
%commit
"@ | Out-File $batchFile -Encoding ASCII -Force

Write-Host "Generating key (this takes 30-60 seconds)..."
gpg --batch --generate-key $batchFile 2>&1
Start-Sleep -Seconds 5

Write-Host "✓ Key generated"

# ============================================================================
# PHASE 3: EXPORT KEYS
# ============================================================================
Write-Host "`n[PHASE 3] Exporting keys..." -ForegroundColor Yellow

$workDir = "C:\Users\$env:USERNAME\gpg_signed_commits"
cd $workDir

gpg --export --armor $Email | `
    Out-File -Encoding UTF8 -FilePath public-key.asc -Force
Write-Host "✓ Public key exported"

gpg --export-secret-key --armor $Email | `
    Out-File -Encoding UTF8 -FilePath private-key.asc -Force
Write-Host "✓ Private key exported"

# ============================================================================
# PHASE 4: DISPLAY RESULTS
# ============================================================================
Write-Host "`n" + ("=" * 70) -ForegroundColor Green
Write-Host "✅ REGENERATION COMPLETE!" -ForegroundColor Green
Write-Host ("=" * 70) -ForegroundColor Green

Write-Host "`nKey Information:"
gpg --list-keys $Email 2>&1

Write-Host "`nPublic Key (copy this to GitHub):"
Write-Host ("-" * 70)
Get-Content public-key.asc | Select-Object -First 10
Write-Host "..."
Write-Host ("-" * 70)

Write-Host "`n✅ Files Created:"
Write-Host "  Public key:  $workDir\public-key.asc"
Write-Host "  Private key: $workDir\private-key.asc (KEEP SECRET)"

Write-Host "`n📝 Next Steps:"
Write-Host "  1. Copy public key to GitHub Settings → SSH and GPG keys"
Write-Host "  2. Configure Git: git config --global user.signingkey <KEY_ID>"
Write-Host "  3. Test signing: git commit -S -m 'Test'"
```

**How to Use This Script:**

```powershell
# Run from PowerShell:
cd C:\Users\P9202728\gpg_signed_commits
.\regenerate-gpg-keys.ps1

# Or with custom values:
.\regenerate-gpg-keys.ps1 -Name "Your Name" -Email "your@email.com"
```

---

### Troubleshooting

| Issue | Solution |
|-------|----------|
| **Process 370 lock timeout** | Run: `gpgconf --kill all`, then wait 5 seconds, try again |
| **Key generation takes too long** | This is normal - can take 30-60 seconds for 4096-bit key |
| **"No agent running" error** | Close and restart PowerShell completely |
| **Files already exist** | Run removal script first to clean up |
| **Permission denied errors** | Run PowerShell as Administrator |

---

### Verification

After regeneration, verify everything worked:

```powershell
# List your new key
gpg --list-keys shivakumar.kalal@mnscorp.net

# Should show:
# pub   rsa4096 2026-05-28 [SCEAR]
#       <KEY_ID>
# uid           [ultimate] shivakumar kalal (GitHub) <shivakumar.kalal@mnscorp.net>
```

---

## Lab 3.1: Generating GPG Keys on Runner

**Objective:** Generate and manage GPG keys in workflows.

**Why Do We Need GPG?**

GPG (GNU Privacy Guard) solves a critical trust problem in software development:

**The Problem:**
- When someone commits code, how can others verify it actually came from them?
- What if someone impersonates another developer and pushes malicious code?
- Git allows anyone to commit with any name and email without verification
- Attackers could commit code as you and push security vulnerabilities

**Example of the Problem:**
```bash
# Without GPG, anyone can do this:
git config user.name "John Developer"
git config user.email "john@company.com"
git commit -m "Fix critical bug"  # Everyone thinks John did this!

# But it was actually an attacker!
```

**How GPG Solves This:**
- GPG uses **cryptographic signatures** to prove you created the commit
- Your private key signs commits (only you have it)
- Your public key verifies signatures (everyone can check)
- GitHub shows a "Verified" badge for signed commits
- Commits can be cryptographically traced back to you

**Visual Representation:**
```
┌─────────────────┐
│  Your Private   │  (KEEP SECRET - on your machine)
│      Key        │  Signs commits
└────────┬────────┘
         │ Signs with private key
         ▼
    ┌─────────┐
    │ Commit  │  ← Cryptographically signed
    │ + Sig   │
    └────┬────┘
         │
    ┌────▼────────────────────────┐
    │ Public Key (on GitHub)       │
    │ Verifies: Yes, this is from  │
    │ the person with private key  │
    └─────────────────────────────┘
         ▼
    ┌──────────────┐
    │ ✅ VERIFIED  │  Shown in GitHub UI
    │ Signed by    │
    │ You          │
    └──────────────┘
```

**The Role of GPG in Workflows:**

1. **Authentication**: Prove commits came from your automation
2. **Non-Repudiation**: Can't deny you made a commit
3. **Integrity**: Ensures commits weren't tampered with
4. **Audit Trail**: Track exactly who committed what
5. **Security**: Enforce signed commits in organizations

**Why Use GPG in GitHub Actions?**

- **Automation Verification**: Show that actions ran with your identity
- **Release Signing**: Sign releases so users trust they're legitimate
- **Policy Enforcement**: Organizations can require all commits be signed
- **Supply Chain Security**: Prevents unauthorized code injection
- **Compliance**: Meets security/regulatory requirements

**Real-World Example:**
```
Scenario: Company publishes a library on npm

WITHOUT signed commits:
- Attacker gains access to CI/CD
- Pushes malicious code
- Publishes package as official release
- Users download compromised library
- Breach happens, no audit trail

WITH signed commits:
- Release must be signed by authorized key
- Attacker can't impersonate without private key
- Commit shows as "Unverified" (red flag)
- Team notices immediately
- Prevents release
```

**Concepts:**
- GPG key generation
- Key components (public/private)
- Key IDs and fingerprints
- Listing keys
- Cryptographic signing

---

### **Important: Two Different Approaches to GPG Signing**

Before you run Lab 3.1, understand the two approaches and which one is right for you:

#### **APPROACH 1: Generate Keys INSIDE the Workflow (What Lab 3.1 Does)**

**How it works:**
- GPG key is generated on GitHub runner during workflow execution
- Key only exists temporarily during the job
- Key is deleted when job completes
- Username/email are just for that temporary key
- Perfect for learning and testing

**Pros:**
- ✅ No setup needed on your machine
- ✅ Each run can use a fresh key
- ✅ Safe - keys don't persist
- ✅ Good for learning
- ✅ No secrets to manage

**Cons:**
- ❌ Commits NOT signed with your personal key
- ❌ GitHub won't show "Verified" badge with your identity
- ❌ Not suitable for production
- ❌ Each workflow run generates new keys (not consistent)

**Example Output:**
```
GitHub Web UI shows:
✖ Unverified commit
Signed by: "GitHub Actions Lab" <actions@github.local>
(Not your real identity!)
```

**Use this if:**
- You're just learning
- You want to understand how GPG works
- You don't need verified badges yet
- You want to experiment without setup

---

#### **APPROACH 2: Pre-Generate Keys on YOUR Machine, Store as Secrets (Production)**

**How it works:**
1. You generate GPG key on your local Windows machine
2. You export the private key
3. You store it as a GitHub secret in your repository
4. Workflow imports the key from secret and uses it
5. Commits are signed with YOUR personal key
6. GitHub shows "Verified" badge with your name

**Pros:**
- ✅ Commits show YOUR verified identity
- ✅ GitHub displays "Verified" badge
- ✅ Production-ready
- ✅ Consistent identity across all workflow runs
- ✅ Professional and trustworthy

**Cons:**
- ❌ Private key stored in GitHub (secured but exists)
- ❌ More setup required
- ❌ Need to manage key lifecycle
- ❌ If key leaked, need to revoke and regenerate

**Example Output:**
```
GitHub Web UI shows:
✅ Verified commit
Signed by: Your Real Name <your.email@company.com>
(Your actual GitHub identity!)
```

**Use this if:**
- You want production commits signed
- You need verified badges on GitHub
- You're contributing to real projects
- You want professional security practices

---

### **Step-by-Step Comparison**

**APPROACH 1 (Lab 3.1 - Temporary Key):**
```
┌─────────────────────────────────────────┐
│  GitHub Actions Workflow Runs           │
│                                         │
│  Step 1: Generate key (temporary)       │
│  Step 2: Sign commit with temp key      │
│  Step 3: Job completes                  │
│  Step 4: Key is deleted ❌              │
│                                         │
│  Result: Commits signed by               │
│          "GitHub Actions Lab"           │
│          (NOT verified as you)          │
└─────────────────────────────────────────┘
```

**APPROACH 2 (Production - Your Personal Key):**
```
┌──────────────────────┐
│  Your Windows PC     │
│                      │
│  1. Generate GPG key │
│  2. Export private   │
│  3. Copy key content │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  GitHub Repository   │
│  Secrets Section     │
│                      │
│  Secret: GPG_KEY     │
│  (stores private key)│
└──────────┬───────────┘
           │
           ▼
┌─────────────────────────────────────────┐
│  GitHub Actions Workflow Runs           │
│                                         │
│  Step 1: Import key from secret         │
│  Step 2: Sign commit with YOUR key      │
│  Step 3: Job completes                  │
│  Step 4: Key stays in secret 🔒         │
│                                         │
│  Result: Commits signed by              │
│          Your Real Name                 │
│          ✅ VERIFIED on GitHub          │
└─────────────────────────────────────────┘
```

---

### **Which Approach Should You Use?**

**For THIS Learning Guide (Labs 1-6):**
- Use **APPROACH 1** (temporary keys)
- Lab 3.1 teaches concepts
- You see how GPG works
- No setup needed
- Perfect for learning

**For Real Projects After Learning:**
- Use **APPROACH 2** (your personal key)
- Setup once on your machine
- Store as GitHub secret
- Get verified badges
- Professional workflows

---

### **How to Transition from Learning to Production**

When you finish the labs and want real signed commits:

#### **Step-by-Step: Generate GPG Key on Your Windows Machine**

**Prerequisites:**
- GPG installed on Windows (Download from https://www.gnupg.org/download/)
- PowerShell (Windows 10+)

**Step 1: Generate Key on Your Windows PC**

Open PowerShell and run:
```powershell
# Generate GPG key interactively
gpg --full-generate-key

# When prompted, answer:
# - Key kind: RSA (press Enter for default)
# - Key size: 4096
# - Expiration: 0 (never expires - best for CI/CD)
# - Real name: Your Name
# - Email: your.email@company.com
# - Comment: GitHub Actions (optional)
# - Passphrase: Leave EMPTY for automation (just press Enter twice)
```

**OR use batch mode (automated):**
```powershell
# Create batch file for automated generation
$batchContent = @'
%echo Generating GPG key for GitHub
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: Your Name
Name-Email: your.email@company.com
Name-Comment: GitHub Actions
Expire-Date: 0
%no-protection
%commit
%echo done
'@

# Save to temporary file
$batchContent | Out-File -FilePath "$env:TEMP\gen-key.batch" -Encoding UTF8

# Generate key
gpg --batch --generate-key "$env:TEMP\gen-key.batch"

# Verify key was created
gpg --list-keys your.email@company.com
```

**Step 2: Export Your Private Key**

```powershell
# Replace your.email@company.com with your actual email
$email = "your.email@company.com"

# Export private key to file
gpg --export-secret-key --armor $email | Out-File -FilePath "$env:USERPROFILE\Desktop\private-key.asc" -Encoding UTF8

# Verify file was created
Get-Item "$env:USERPROFILE\Desktop\private-key.asc"

# Show first few lines
(Get-Content "$env:USERPROFILE\Desktop\private-key.asc" -Head 5)
```

**Step 3: Create JSON Configuration File**

```powershell
# Read private key content
$privateKeyContent = Get-Content "$env:USERPROFILE\Desktop\private-key.asc" -Raw

# Get key ID
$keyOutput = gpg --list-keys --with-colons $email
$keyId = ($keyOutput -split '\n' | Where-Object { $_ -match "^pub:" } | Select-Object -First 1) -split ':' | Select-Object -Index 4

# Create JSON configuration
$config = @{
    "email" = $email
    "key_id" = $keyId
    "gpg_private_key" = $privateKeyContent
    "generated_date" = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    "key_type" = "RSA 4096"
    "expiration" = "Never"
    "passphrase" = "none"
} | ConvertTo-Json -Depth 10

# Save to JSON file
$config | Out-File -FilePath "$env:USERPROFILE\Desktop\gpg-config.json" -Encoding UTF8

# Verify file
Get-Content "$env:USERPROFILE\Desktop\gpg-config.json"

Write-Host "✓ Configuration file created at: $env:USERPROFILE\Desktop\gpg-config.json"
```

**Step 4: Securely Store in GitHub Secrets**

```powershell
# Option 1: Manual (Recommended for first time)
# 1. Go to your GitHub repository
# 2. Click Settings → Secrets and variables → Actions
# 3. Click "New repository secret"
# 4. Name: GPG_PRIVATE_KEY
# 5. Value: Copy entire content of private-key.asc file
# 6. Click "Add secret"

# Option 2: Via GitHub CLI (requires 'gh' installed)
$privateKey = Get-Content "$env:USERPROFILE\Desktop\private-key.asc" -Raw
$privateKey | gh secret set GPG_PRIVATE_KEY

Write-Host "✓ Secret stored in GitHub"
```

**Complete PowerShell Script (All-in-One)**

Save this as `setup-gpg.ps1`:

```powershell
# ============================================================================
# GPG Key Setup for GitHub Actions on Windows
# ============================================================================
# This script generates GPG keys and creates GitHub secrets configuration
# ============================================================================

param(
    [Parameter(Mandatory=$true)]
    [string]$Email,
    
    [Parameter(Mandatory=$true)]
    [string]$Name,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "$env:USERPROFILE\Desktop"
)

# Colors for output
$colors = @{
    Success = 'Green'
    Error = 'Red'
    Info = 'Cyan'
    Warning = 'Yellow'
}

function Write-Status {
    param([string]$Message, [string]$Status = "Info")
    $color = $colors[$Status]
    Write-Host "[$Status] $Message" -ForegroundColor $color
}

try {
    Write-Status "Starting GPG setup..." "Info"
    
    # Check if GPG is installed
    $gpgVersion = gpg --version 2>&1 | Select-Object -First 1
    Write-Status "Found: $gpgVersion" "Success"
    
    # Step 1: Generate Key
    Write-Status "Generating GPG key pair..." "Info"
    
    $batchContent = @"
%echo Generating GPG key for GitHub
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: $Name
Name-Email: $Email
Name-Comment: GitHub Actions
Expire-Date: 0
%no-protection
%commit
%echo done
"@
    
    $batchFile = "$env:TEMP\gen-key-$(Get-Random).batch"
    $batchContent | Out-File -FilePath $batchFile -Encoding UTF8
    
    gpg --batch --generate-key $batchFile
    Remove-Item $batchFile
    
    Write-Status "GPG key generated successfully" "Success"
    
    # Step 2: Get Key ID
    Write-Status "Extracting key information..." "Info"
    
    $keyOutput = gpg --list-keys --with-colons $Email
    $keyId = ($keyOutput -split "`n" | Where-Object { $_ -match "^pub:" } | Select-Object -First 1) -split ':' | Select-Object -Index 4
    
    Write-Status "Key ID: $keyId" "Success"
    
    # Step 3: Export Private Key
    Write-Status "Exporting private key..." "Info"
    
    $privateKeyFile = "$OutputPath\private-key.asc"
    gpg --export-secret-key --armor $Email | Out-File -FilePath $privateKeyFile -Encoding UTF8
    
    Write-Status "Private key exported to: $privateKeyFile" "Success"
    
    # Step 4: Create JSON Configuration
    Write-Status "Creating JSON configuration..." "Info"
    
    $privateKeyContent = Get-Content $privateKeyFile -Raw
    
    $config = @{
        "github_repository" = ""
        "email" = $Email
        "name" = $Name
        "key_id" = $keyId
        "gpg_private_key" = $privateKeyContent
        "generated_date" = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        "key_type" = "RSA 4096"
        "expiration" = "Never"
        "passphrase" = "none (for automation)"
        "instructions" = @{
            "step_1" = "Copy GPG_PRIVATE_KEY value to GitHub Secrets"
            "step_2" = "Use Lab 7 workflow for production commits"
            "step_3" = "Commits will show as Verified with your name"
        }
    } | ConvertTo-Json -Depth 10
    
    $jsonFile = "$OutputPath\gpg-config.json"
    $config | Out-File -FilePath $jsonFile -Encoding UTF8
    
    Write-Status "JSON configuration created: $jsonFile" "Success"
    
    # Step 5: Display Summary
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║           GPG KEY SETUP COMPLETE                           ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "✓ Email: $Email" -ForegroundColor Green
    Write-Host "✓ Name: $Name" -ForegroundColor Green
    Write-Host "✓ Key ID: $keyId" -ForegroundColor Green
    Write-Host ""
    Write-Host "FILES CREATED:" -ForegroundColor Yellow
    Write-Host "  1. $privateKeyFile" -ForegroundColor White
    Write-Host "  2. $jsonFile" -ForegroundColor White
    Write-Host ""
    Write-Host "NEXT STEPS:" -ForegroundColor Yellow
    Write-Host "  1. Go to GitHub repository Settings" -ForegroundColor White
    Write-Host "  2. Click 'Secrets and variables' → 'Actions'" -ForegroundColor White
    Write-Host "  3. Click 'New repository secret'" -ForegroundColor White
    Write-Host "  4. Name: GPG_PRIVATE_KEY" -ForegroundColor White
    Write-Host "  5. Value: Copy contents of private-key.asc" -ForegroundColor White
    Write-Host "  6. Add secret" -ForegroundColor White
    Write-Host ""
    Write-Host "VERIFY:" -ForegroundColor Yellow
    Write-Host "  gpg --list-keys $Email" -ForegroundColor White
    Write-Host ""
    
} catch {
    Write-Status "Error: $_" "Error"
    exit 1
}
```

**Run the script:**
```powershell
# Make sure to allow script execution
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Run the script
.\setup-gpg.ps1 -Name "Your Name" -Email "your.email@company.com"
```

**Step 5: Add to GitHub Secrets**

```
1. Go to GitHub Repository → Settings
2. Click "Secrets and variables" → "Actions"
3. Click "New repository secret"
4. Name: GPG_PRIVATE_KEY
5. Value: Copy entire content of private-key.asc file
6. Click "Add secret"
```

**Verify Setup:**
```powershell
# List your GPG keys
gpg --list-keys your.email@company.com

# View key fingerprint
gpg --list-keys --fingerprint your.email@company.com
```

---

---

### **CRITICAL SECURITY CONCEPTS: Public Keys, Trust, and Validation**

Before you generate keys, you MUST understand how GitHub validates GPG keys and prevents impersonation.

#### **Question 1: Public Keys are NOT Stored in GitHub - How Does GitHub Recognize Them?**

**The Answer: You Must Manually Upload Your Public Key to GitHub**

This is a crucial step most guides skip! Here's the complete flow:

**Step 1: Generate GPG Key Pair (Private + Public)**
```
Your Windows Machine:
┌──────────────────────────────────┐
│  GPG Key Generation              │
│                                  │
│  Private Key: ABC123... (secret) │
│  Public Key:  ABC123... (public) │
│                                  │
│  Both stored locally in:          │
│  C:\Users\YourName\AppData\Roaming\gnupg\
└──────────────────────────────────┘
```

**Step 2: YOU Must Upload Public Key to GitHub**
```
Your Browser:
1. Go to GitHub Settings → SSH and GPG Keys
2. Click "New GPG Key"
3. Paste your PUBLIC KEY (abc.asc file)
4. Click "Add GPG key"

GitHub Now Stores:
┌──────────────────────────────────┐
│  GitHub's Key Storage            │
│                                  │
│  Your Public Key: ABC123...      │
│  (linked to your GitHub account) │
└──────────────────────────────────┘
```

**Step 3: When You Push Commits**
```
┌─────────────────────────────────────────────────────────┐
│  Git Push with Signed Commit                            │
│                                                          │
│  1. Your local key signs the commit                     │
│  2. Git includes signature in commit                    │
│  3. Commit pushed to GitHub                            │
│  4. GitHub receives commit + signature                 │
└─────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────┐
│  GitHub Verification Process                            │
│                                                          │
│  1. GitHub looks up the KEY ID in the commit           │
│  2. Searches for matching key in YOUR GitHub account   │
│  3. Found! Retrieves YOUR PUBLIC KEY                   │
│  4. Uses public key to verify the signature            │
│  5. Shows ✅ VERIFIED badge                            │
└─────────────────────────────────────────────────────────┘
```

**Why This Works (Cryptography Magic):**
- Private key signs → creates unique signature
- Public key verifies → only works if matching private key created it
- GitHub never needs your private key!
- Public key is safe to share (it's public)

**Real Example:**
```
Scenario: You sign a commit with your private key

Private Key ABC123 (only you have):
  Signs commit "Add feature X"
  Creates signature: "XYZ789SIGNATURE"

GitHub Verification:
  1. Receives commit with signature XYZ789SIGNATURE
  2. Gets public key ABC123 from your GitHub profile
  3. Tests: Does public ABC123 verify signature XYZ789SIGNATURE?
  4. YES! → Shows ✅ VERIFIED
  5. Proof: Only someone with matching private key could create this
```

**CRITICAL: You MUST Upload Public Key**
```
❌ WRONG (won't verify):
1. Generate GPG key locally
2. Push signed commit
3. Nothing happens - no verified badge

✅ CORRECT:
1. Generate GPG key locally
2. Upload PUBLIC key to GitHub Settings
3. Push signed commit
4. ✅ VERIFIED badge appears
```

**Complete Checklist:**
- [ ] Generate GPG key on Windows
- [ ] Export public key
- [ ] Upload public key to GitHub Settings → GPG Keys
- [ ] Export private key
- [ ] Store private key as GitHub Secret
- [ ] Now commits will show as VERIFIED

---

#### **Question 2: How Are GPG Keys Validated? What Prevents Impersonation?**

**The Problem You're Asking About:**
```
Attacker thinks:
"I can generate a GPG key with name 'Satya Nadella' and email 'satya@microsoft.com'
Then sign commits as if I'm him! 🤔"

Reality:
This is ACTUALLY POSSIBLE! ⚠️
```

**This is Why: GPG Has No Built-In Validation**

GPG itself does NOT verify "are you really Satya Nadella?"
- GPG only checks: "Does this private key match this public key?"
- Anyone can create a key with any name/email

**But GitHub PREVENTS This Impersonation:**

Here's how GitHub actually validates:

```
┌──────────────────────────────────────────────────────────┐
│  IMPERSONATION ATTEMPT                                   │
│                                                          │
│  Attacker generates:                                     │
│  - Private Key: ATTACKER_SECRET                         │
│  - Public Key: ATTACKER_PUBLIC                          │
│  - Name: "Satya Nadella"                                │
│  - Email: "satya@microsoft.com"                         │
│                                                          │
│  (Anyone can do this! No validation needed!)            │
└──────────────────────────────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────────────────────────┐
│  ATTACKER TRIES TO UPLOAD TO GITHUB                      │
│                                                          │
│  Steps:                                                  │
│  1. Go to GitHub.com/SatyaNadella account               │
│  2. Click Settings → GPG Keys                           │
│  3. Try to add attacker's public key                    │
│                                                          │
│  RESULT: ❌ CANNOT DO IT!                               │
│                                                          │
│  Why? They don't have access to Satya's account!        │
└──────────────────────────────────────────────────────────┘
```

**GitHub's Real Validation (Account-Based):**

```
The Protection Chain:

┌─────────────────────────────────────────┐
│  GitHub Account Security                │
│                                         │
│  1. GitHub account is login-protected   │
│  2. Login requires password             │
│  3. Add GPG key requires account access │
│  4. Only YOU can access YOUR account    │
└─────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  GPG Key Upload                         │
│                                         │
│  Only logged-in users can:              │
│  - Upload GPG keys                      │
│  - Add SSH keys                         │
│  - Configure settings                  │
│                                         │
│  Attacker would need YOUR password!     │
└─────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  Commit Signing                         │
│                                         │
│  Once key is uploaded:                  │
│  - ONLY commits signed with matching    │
│    private key will verify              │
│  - Attacker's commits won't verify      │
│    (different private key)              │
└─────────────────────────────────────────┘
```

**Real-World Scenarios:**

**Scenario 1: Normal User (You)**
```
You:
✅ Have access to your GitHub account
✅ Upload YOUR public key
✅ Sign commits with YOUR private key
✅ GitHub verifies: Public key matches
✅ Result: ✅ VERIFIED as you

Attacker:
❌ Doesn't have your account password
❌ Can't upload fake key to your account
❌ If they try to use their own account, commits
   show "Verified as [Attacker Name]"
```

**Scenario 2: If Someone Hacks Your GitHub Account**
```
Attacker hacks your GitHub password:
❌ They CAN upload their own GPG public key
❌ They CAN sign commits
✅ BUT: Commits show "Verified by [their key fingerprint]"
✅ AND: You'll see new GPG keys in your account
✅ You can DELETE those keys immediately

Protection: GitHub email verification
- When key uploaded, GitHub sends verification email
- You notice immediately
- You change password
- Attacker's key access revoked
```

**Scenario 3: The Real Risk**

```
⚠️ REAL VULNERABILITY:
An attacker can:
1. Create GitHub account as "satya-nadella-official"
2. Generate GPG key with name "Satya Nadella"
3. Push commits to their own repo
4. Commits show: ✅ VERIFIED (by their account)

Visual Result:
"✅ Verified by Satya Nadella"

Users see this and think it's the real Satya!

PREVENTION:
- GitHub shows account name, not just signer name
- User profiles have verification badges (blue checkmark)
- Satya's real account: github.com/satya (official)
- Fake account: github.com/satya-nadella-official (obvious)
- Organization members have badges
- Commits show: Account name + GPG key fingerprint
```

**GitHub's Defense Layers:**

```
Layer 1: Account Access
├─ Password authentication
├─ 2FA (two-factor authentication)
├─ SSH keys (separate from GPG)
└─ Email verification

Layer 2: GPG Key Management
├─ Keys linked to authenticated account
├─ Can view all keys on profile
├─ Can revoke keys
└─ Email notification on new key

Layer 3: Commit Display
├─ Shows GitHub account name
├─ Shows GPG key fingerprint
├─ Shows commit author (may differ from committer)
├─ Shows timestamp
└─ Shows "Verified" status

Layer 4: Organization Security
├─ Org members have badges
├─ Require signed commits (can be enforced)
├─ Require branch protection
├─ Audit logs show all activities
└─ Admin can remove users
```

**How GitHub Shows Commit Details:**

When you click a commit on GitHub:
```
✅ Verified
Signed by: Your Name <your.email@company.com>

Signature Details:
─────────────────
Key ID: ABC123DEF456 (last 16 chars shown)
GPG Key Fingerprint: 
  ABC1 2345 6789 ABCD EFGH IJKL MNOP QRST (full)

Committer: github_username
Author: your.email@company.com
```

**Attack Prevention Summary:**

| Attack Type | How It's Prevented |
|------------|-------------------|
| **Fake key on real account** | Requires account password + 2FA |
| **Fake account impersonation** | Account name is public, easy to verify |
| **Key tampering** | Cryptographic validation impossible to fake |
| **Commit tampering** | Signature becomes invalid if commit is modified |
| **Key theft** | Only you have private key (stored locally) |
| **Key leakage** | Can revoke key immediately, old commits stay verified |

**What This Means:**

```
✅ GPG prevents:
- Commit tampering (signature invalid if modified)
- False signatures (only real private key works)
- Replay attacks (signature tied to specific commit)

❌ GPG does NOT prevent:
- Name/email spoofing in local repo
- Account hacking (if account compromised)
- Social engineering (tricking you into adding attacker's key)

✅ GitHub adds protection:
- Account authentication (password + 2FA)
- Public key verification (see who keys belong to)
- Audit logs (track all changes)
- Organization controls (enforce policies)
```

**The Gold Standard: Verified Public Profile + Organization Badge**

Most secure commits:
```
✅ VERIFIED
Signed by: Your Name <your.email@company.com>

✅ Your GitHub profile is verified
✅ You're member of trusted organization
✅ Organization requires signed commits
✅ Commit is to official organization repo

Result: Very high trust that this is really you
```

---

### **Practical Example: How Your Local Key Becomes GitHub Verified**

**Step-by-Step Complete Flow:**

```
1. ON YOUR WINDOWS MACHINE (Generate):
   ┌─────────────────────────────────────┐
   │ gpg --full-generate-key             │
   │ Name: Your Real Name                │
   │ Email: your@email.com               │
   │ Passphrase: (empty for automation)  │
   │                                     │
   │ Creates:                            │
   │ - Private Key (stored locally)      │
   │ - Public Key (exported to .asc)     │
   └─────────────────────────────────────┘

2. EXPORT PUBLIC KEY (on Windows):
   ┌─────────────────────────────────────┐
   │ gpg --export --armor your@email.com │
   │                                     │
   │ Creates: public-key.asc             │
   │ Contains: PUBLIC key data           │
   └─────────────────────────────────────┘

3. UPLOAD TO GITHUB (via browser):
   ┌─────────────────────────────────────┐
   │ GitHub Settings → GPG Keys          │
   │ New GPG Key                         │
   │ Paste: public-key.asc content       │
   │                                     │
   │ GitHub now stores:                  │
   │ - Public key                        │
   │ - Linked to your account            │
   │ - Fingerprint recorded              │
   └─────────────────────────────────────┘

4. IN GITHUB WORKFLOW (use private key):
   ┌─────────────────────────────────────┐
   │ GitHub Secret: GPG_PRIVATE_KEY      │
   │                                     │
   │ Workflow imports private key        │
   │ Signs commit with private key       │
   │ Signature: XYZ789...                │
   │ Pushes to GitHub                    │
   └─────────────────────────────────────┘

5. GITHUB VERIFICATION (automatic):
   ┌─────────────────────────────────────┐
   │ GitHub receives commit + signature  │
   │ Looks up key ID from signature      │
   │ Finds YOUR public key in settings   │
   │ Verifies: Signature matches         │
   │ Displays: ✅ VERIFIED               │
   └─────────────────────────────────────┘
```

**What GitHub Actually Stores:**

```
GitHub Database (Your Account):
┌────────────────────────────────────┐
│ User: your_github_username         │
│                                    │
│ Email: your@email.com              │
│ Password: hashed                   │
│                                    │
│ GPG Keys:                          │
│ ├─ Key ID: ABC123DEF456            │
│ ├─ Public Key: (long encoded text) │
│ ├─ Fingerprint: (short ID)         │
│ ├─ Created: 2024-01-15             │
│ └─ Linked Emails: your@email.com   │
│                                    │
│ Private Key: NOT STORED HERE! 🔐   │
│                                    │
│ (Private key stays ONLY on your PC)│
└────────────────────────────────────┘
```

**Why This is Secure:**

```
✅ Private key never leaves your Windows machine
✅ GitHub never needs your private key
✅ Public key is safe to store anywhere
✅ Signature proves key ownership
✅ Only your private key can create matching signature
✅ Attacker needs BOTH GitHub account + your private key
```

---



# PART 7: PRODUCTION - Using Your Personal GPG Key

## Lab 7: Production Workflow with Your Personal GPG Key

**Objective:** Use your real GPG key from Windows to sign commits in GitHub Actions.

**Prerequisites:**
- Complete "How to Transition from Learning to Production" steps above
- Your GPG_PRIVATE_KEY stored as GitHub Secret
- Email and name configured

**COPY THIS INTO testinglab.yml:**

```yaml
name: Lab 7 - Production Signed Commits

on:
  workflow_dispatch:
  push:
    branches: [ main ]

jobs:
  production-signed-commits:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
    
    steps:
    - name: Checkout Repository
      uses: actions/checkout@v3
      with:
        fetch-depth: 0
    
    - name: Import GPG Private Key
      run: |
        echo "=== Importing GPG Private Key ==="
        
        # Import the private key from secret
        echo "${{ secrets.GPG_PRIVATE_KEY }}" | gpg --import
        
        echo "✓ Private key imported"
    
    - name: List Imported Keys
      run: |
        echo "=== Imported GPG Keys ==="
        gpg --list-secret-keys
    
    - name: Configure Git with Personal Key
      run: |
        echo "=== Configuring Git with Your Personal Key ==="
        
        # Extract key ID from the imported key
        # Use your actual email here
        KEY_ID=$(gpg --list-keys --with-colons "your.email@company.com" | grep "^pub" | cut -d: -f5)
        
        # Configure git with your details
        git config --global user.name "Your Name"
        git config --global user.email "your.email@company.com"
        git config --global user.signingkey $KEY_ID
        git config --global gpg.program gpg
        git config --global commit.gpgsign true
        
        echo "✓ Git configured with your personal key"
        echo "Key ID: $KEY_ID"
    
    - name: Create Production Branch
      run: |
        BRANCH="production/release-$(date +%s)"
        git checkout -b $BRANCH
        echo "PROD_BRANCH=$BRANCH" >> $GITHUB_ENV
        
        echo "✓ Production branch created: $BRANCH"
    
    - name: Create Production Files
      run: |
        mkdir -p production-release
        
        cat > production-release/version.txt << 'EOF'
        Version: 1.0.0
        Release Date: $(date)
        Signed By: Your Name
        Status: Production
        EOF
        
        cat > production-release/CHANGELOG.md << 'EOF'
        # Changelog
        
        ## [1.0.0] - $(date +%Y-%m-%d)
        
        ### Added
        - Production release
        - GPG signed commits
        - Automated workflow
        
        ### Security
        - All commits cryptographically signed
        - Verified by: Your Name
        EOF
        
        echo "✓ Production files created"
    
    - name: Commit with Your Personal Signature
      run: |
        echo "=== Creating Signed Commit ==="
        
        git add production-release/
        
        git commit -m "chore: Production release v1.0.0" \
          -m "- Signed with personal GPG key" \
          -m "- Ready for production deployment"
        
        echo "✓ Signed commit created"
    
    - name: Verify Commit Signature
      run: |
        echo "=== Verifying Commit Signature ==="
        
        COMMIT_HASH=$(git rev-parse HEAD)
        
        echo "Commit Hash: $COMMIT_HASH"
        echo ""
        
        git verify-commit $COMMIT_HASH 2>&1 || echo "✓ Signature verification complete"
        
        echo ""
        echo "=== Commit Details ==="
        git show --format="%H|%an|%ae|%s" -s
    
    - name: View Full Commit with Signature
      run: |
        echo "=== Full Commit Information ==="
        git log -1 --pretty=format:"%H%n%an <%ae>%n%ad%n%s%n%b" --date=short
    
    - name: Configure Git Token for Push
      run: |
        git config --global credential.helper store
        echo "https://token:${{ secrets.GITHUB_TOKEN }}@github.com" > ~/.git-credentials
    
    - name: Push Production Branch
      run: |
        git push origin ${{ env.PROD_BRANCH }}
        echo "✓ Production branch pushed"
    
    - name: Create Production Release PR
      run: |
        gh pr create \
          --title "🚀 Release: v1.0.0 (Signed)" \
          --body "## Production Release v1.0.0

        ✅ **Security:**
        - All commits signed with personal GPG key
        - Cryptographically verified
        - Ready for production
        
        ✅ **Status:**
        - Branch: ${{ env.PROD_BRANCH }}
        - Signed By: Your Name
        - Date: $(date)
        
        ✅ **Ready to:**
        - Merge to main
        - Deploy to production
        - Tag as release" \
          --base main \
          --head ${{ env.PROD_BRANCH }} \
          --label "production,release,verified,security"
        
        echo "✓ Production PR created!"
      env:
        GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Add Review Comment
      run: |
        PR_NUMBER=$(gh pr list --head ${{ env.PROD_BRANCH }} --json number -q '.[0].number')
        
        gh pr comment $PR_NUMBER \
          --body "✅ **Production Release Verification**
        
        - [x] Commits signed with personal GPG key
        - [x] All changes reviewed
        - [x] Ready for merge
        - [x] GitHub shows ✅ Verified badge
        
        **Next Step:** Merge to main and create GitHub Release"
      env:
        GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Summary - What to Expect on GitHub
      run: |
        echo ""
        echo "╔════════════════════════════════════════════════════════════╗"
        echo "║              PRODUCTION RELEASE CREATED                    ║"
        echo "╚════════════════════════════════════════════════════════════╝"
        echo ""
        echo "✅ YOUR PERSONAL GPG KEY WAS USED"
        echo ""
        echo "What you'll see on GitHub:"
        echo "  1. Commits show ✅ VERIFIED"
        echo "  2. Signed by: Your Name <your.email@company.com>"
        echo "  3. PR created with production details"
        echo "  4. Review comments added automatically"
        echo ""
        echo "Next Steps:"
        echo "  1. Go to GitHub and view the Pull Request"
        echo "  2. Check the commit - it shows VERIFIED badge"
        echo "  3. Merge to main"
        echo "  4. Create GitHub Release"
        echo ""
        echo "Branch: ${{ env.PROD_BRANCH }}"
        echo "Repository: ${{ github.repository }}"
        echo ""
```

**What You'll Learn:**
- Importing your personal GPG key from secrets
- Configuring Git with your real identity
- Creating production-ready signed commits
- Verifying signatures in workflow
- Creating professional release PRs
- Understanding verified badges on GitHub

**After Running Lab 7:**

Go to GitHub repository and check:
1. **Commits Tab** - Click the commit, you should see:
   ```
   ✅ VERIFIED
   Signed by: Your Name <your.email@company.com>
   ```

2. **Pull Requests** - View the created PR showing:
   - All commits are verified
   - Green checkmarks on each commit
   - Your real identity as signer

3. **GitHub's Verification** - Shows:
   - "This commit was signed with a verified signature"
   - Your name and email
   - Green badge throughout the UI

---

### **Troubleshooting Lab 7**

**Problem: "Key not found" error**
```
Solution: 
- Check GitHub Secret is named exactly: GPG_PRIVATE_KEY
- Verify private-key.asc file is complete (includes BEGIN and END lines)
- Re-export key from Windows machine
```

**Problem: "Unverified" badge still shows**
```
Solution:
- Email in git config must match email in GPG key
- Check: git config user.email
- Check: gpg --list-keys (email must match)
```

**Problem: "No such file or directory" on gpg**
```
Solution:
- Ubuntu runners have GPG pre-installed
- Try: gpg --version (in workflow step)
```

**Problem: Can't remember key ID**
```
Solution:
- Check gpg-config.json file created on Windows
- Or run: gpg --list-keys your.email@company.com
```

---

## COMPARISON: Lab 3.1 vs Lab 7

| Aspect | Lab 3.1 (Learning) | Lab 7 (Production) |
|--------|-------------------|-------------------|
| **Key Generated** | Inside workflow (temporary) | Your Windows machine |
| **Key Storage** | Deleted after job | GitHub Secrets |
| **Signed By** | "GitHub Actions Lab" | Your Real Name |
| **GitHub Badge** | ❌ Unverified | ✅ Verified |
| **Use Case** | Learning concepts | Real projects |
| **Setup Required** | None | Setup once on Windows |
| **Key Consistency** | Different each run | Same key every run |
| **Professional** | No | Yes |

---

### **When to Use Each Lab**

**Use Lab 3.1 if:**
- You're learning GPG concepts
- You want to understand how signing works
- You don't need verified badges
- You want zero setup

**Use Lab 7 if:**
- You're working on real projects
- You need verified badges on GitHub
- You want professional security
- You're in a team/organization
- You need audit trail



**COPY THIS INTO testinglab.yml:**

```yaml
name: Lab 3.1 - Generating GPG Keys

on:
  workflow_dispatch:
  push:
    branches: [ main ]

jobs:
  gpg-generation:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout Repository
      uses: actions/checkout@v3
    
    - name: Check GPG Installation
      run: |
        echo "=== Checking GPG ==="
        gpg --version | head -3
    
    - name: Generate GPG Key Pair
      run: |
        echo "=== Generating GPG Key Pair ==="
        
        cat > /tmp/gen-key.batch << 'EOF'
        %echo Generating a key pair
        Key-Type: RSA
        Key-Length: 4096
        Subkey-Type: RSA
        Subkey-Length: 4096
        Name-Real: GitHub Actions Lab
        Name-Email: actions@github.local
        Expire-Date: 0
        %no-protection
        %commit
        %echo done
        EOF
        
        gpg --batch --generate-key /tmp/gen-key.batch
        echo "✓ Key pair generated"
    
    - name: List Generated Keys
      run: |
        echo "=== Public Keys ==="
        gpg --list-keys
        
        echo ""
        echo "=== Private Keys ==="
        gpg --list-secret-keys
    
    - name: Display Key Fingerprint
      run: |
        echo "=== Key Fingerprint ==="
        gpg --list-keys --fingerprint actions@github.local
        
        echo ""
        echo "=== Key ID ==="
        gpg --list-keys --with-colons actions@github.local | grep "^pub" | cut -d: -f5
    
    - name: Export Public Key
      run: |
        echo "=== Exporting Public Key ==="
        gpg --export --armor actions@github.local > /tmp/public-key.asc
        
        echo "Public key exported:"
        head -3 /tmp/public-key.asc
        echo "... (key data continues)"
```

**What You'll Learn:**
- Generating GPG keys on runner
- Understanding key structure
- Extracting key IDs
- Exporting public keys

---

## Lab 3.2: Signing Files with GPG

**Objective:** Create and verify digital signatures.

**Concepts:**
- Clearsigned messages
- Detached signatures
- Signature verification
- Tampering detection

**COPY THIS INTO testinglab.yml:**

```yaml
name: Lab 3.2 - Signing Files with GPG

on:
  workflow_dispatch:
  push:
    branches: [ main ]

jobs:
  gpg-signing:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout Repository
      uses: actions/checkout@v3
    
    - name: Generate GPG Key
      run: |
        cat > /tmp/gen-key.batch << 'EOF'
        %echo Generating key
        Key-Type: RSA
        Key-Length: 4096
        Subkey-Type: RSA
        Subkey-Length: 4096
        Name-Real: Signer
        Name-Email: signer@example.com
        Expire-Date: 0
        %no-protection
        %commit
        %echo done
        EOF
        
        gpg --batch --generate-key /tmp/gen-key.batch
        echo "✓ Key generated"
    
    - name: Create Test Message
      run: |
        mkdir -p gpg-demo
        
        cat > gpg-demo/message.txt << 'EOF'
        This is a test message for GPG signing.
        
        It demonstrates digital signatures.
        Created by GitHub Actions workflow.
        EOF
        
        echo "✓ Message file created"
    
    - name: Create Clearsigned Message
      run: |
        echo "=== Creating Clearsigned Message ==="
        gpg --clearsign --batch --yes --default-key signer@example.com gpg-demo/message.txt
        
        echo "✓ Clearsigned message created"
        head -15 gpg-demo/message.txt.asc
    
    - name: Verify Clearsigned Message
      run: |
        echo "=== Verifying Clearsigned Message ==="
        gpg --verify gpg-demo/message.txt.asc
        echo "✓ Signature verified"
    
    - name: Create Detached Signature
      run: |
        echo "=== Creating Detached Signature ==="
        gpg --detach-sign --armor --batch --yes --default-key signer@example.com gpg-demo/message.txt
        
        echo "✓ Detached signature created"
        cat gpg-demo/message.txt.sig
    
    - name: Verify Detached Signature
      run: |
        echo "=== Verifying Detached Signature ==="
        gpg --verify gpg-demo/message.txt.sig gpg-demo/message.txt
        echo "✓ Detached signature verified"
    
    - name: Test Tampering Detection
      run: |
        echo "=== Testing Tampering Detection ==="
        
        echo "Modifying message..."
        echo "TAMPERED" >> gpg-demo/message.txt
        
        echo ""
        echo "Attempting to verify modified message:"
        gpg --verify gpg-demo/message.txt.sig gpg-demo/message.txt 2>&1 || echo "✓ Tampering detected"
```

**What You'll Learn:**
- Creating clearsigned messages
- Creating detached signatures
- Verifying signatures
- Detecting tampering

---

## Alternatives to GPG - Comparison

While GPG is powerful, there are alternatives. Here's how they compare:

### 1. **SSH Keys for Signing** ✅ Modern Alternative
**How it works:**
- Use SSH keys to sign commits instead of GPG
- Git supports SSH signing natively (Git 2.34+)
- Simpler than GPG, uses same keys for authentication

**Pros:**
- ✅ Simpler than GPG
- ✅ Same key for authentication + signing
- ✅ Faster verification
- ✅ Easier to manage

**Cons:**
- ❌ Newer (less mature)
- ❌ GitHub/GitLab support still evolving
- ❌ Less encryption flexibility

**Example:**
```bash
# Configuration for SSH signing
git config user.signingKey 'ssh-ed25519 AAAAC3NzaC...'
git config gpg.format ssh
```

### 2. **S/MIME (Secure/Multipurpose Internet Mail Extensions)**
**How it works:**
- Uses X.509 certificates instead of GPG
- Common in enterprise environments
- Requires certificate authority

**Pros:**
- ✅ Enterprise standard
- ✅ Works with certificate authorities
- ✅ Wide tool support

**Cons:**
- ❌ Requires certificate infrastructure
- ❌ More complex to setup
- ❌ Licensing costs possible

### 3. **Keybase Integration**
**How it works:**
- Uses Keybase keys for GitHub signing
- Keybase manages key distribution

**Pros:**
- ✅ Simpler key management
- ✅ Social proof verification
- ✅ Key recovery possible

**Cons:**
- ❌ Depends on Keybase service
- ❌ Added complexity
- ❌ Third-party dependency

### 4. **Artifact Signing (Alternative Approach)**
**How it works:**
- Instead of signing commits, sign releases/artifacts
- Use tools like Sigstore for artifact signing
- Don't sign every commit, just final releases

**Pros:**
- ✅ Minimal overhead
- ✅ Focus on production security
- ✅ Works with modern tooling

**Cons:**
- ❌ Doesn't sign development commits
- ❌ Less comprehensive audit trail

**Example:**
```bash
# Sign a release artifact
cosign sign-blob --key cosign.key release.tar.gz > release.tar.gz.sig
```

---

### **Comparison Table**

| Feature | GPG | SSH Keys | S/MIME | Keybase | Artifact Only |
|---------|-----|----------|--------|---------|---------------|
| **Ease of Setup** | 🟡 Medium | 🟢 Easy | 🔴 Hard | 🟡 Medium | 🟢 Easy |
| **GitHub Support** | 🟢 Full | 🟡 Partial | 🟢 Full | 🟡 Limited | 🟡 Partial |
| **Security Level** | 🟢 Strong | 🟢 Strong | 🟢 Strong | 🟡 Good | 🟢 Strong |
| **Enterprise Ready** | 🟢 Yes | 🟡 Growing | 🟢 Yes | 🟡 No | 🟡 Yes |
| **Audit Trail** | 🟢 Full | 🟢 Full | 🟢 Full | 🟡 Good | 🟡 Partial |
| **Key Management** | 🟡 Complex | 🟢 Simple | 🟡 Complex | 🟢 Simple | 🟢 Simple |

---

### **Why We Use GPG in This Lab**

1. **Industry Standard**: Most used for commit signing
2. **Complete**: Provides full cryptographic coverage
3. **Flexible**: Works for multiple purposes (commits, files, messages)
4. **Learning Value**: Understanding GPG teaches cryptography concepts
5. **Mature**: Battle-tested, well-documented
6. **No Dependencies**: Works offline, no external service required

### **When to Use Each Alternative**

**Use GPG if:**
- You need to sign commits in regulated environments
- You want complete cryptographic coverage
- You need maximum compatibility
- You want to sign files outside git

**Use SSH Keys if:**
- You're using modern Git (2.34+)
- You want simplicity
- You already use SSH for GitHub
- You prefer minimal key management

**Use S/MIME if:**
- Your organization requires certificates
- You're in a corporate environment with PKI
- You need interoperability with email systems

**Use Artifact Signing if:**
- You only care about release security
- You want minimal overhead
- You focus on production verification

**Use No Signing if:**
- You're in a private/trusted team
- You're just learning (not production)
- You accept the identity verification risk

---

# PART 4: SIGNED COMMITS

## Lab 4.1: Configuring Git for Signed Commits

**Objective:** Setup Git with GPG key for automatic signing.

**Concepts:**
- Git GPG configuration
- Auto-signing commits
- Key ID configuration
- Configuration verification

**COPY THIS INTO testinglab.yml:**

```yaml
name: Lab 4.1 - Configure Git for Signed Commits

on:
  workflow_dispatch:
  push:
    branches: [ main ]

jobs:
  configure-signed-commits:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout Repository
      uses: actions/checkout@v3
    
    - name: Generate GPG Key
      run: |
        cat > /tmp/gen-key.batch << 'EOF'
        %echo Generating key
        Key-Type: RSA
        Key-Length: 4096
        Subkey-Type: RSA
        Subkey-Length: 4096
        Name-Real: Signed Commit User
        Name-Email: signed@example.com
        Expire-Date: 0
        %no-protection
        %commit
        %echo done
        EOF
        
        gpg --batch --generate-key /tmp/gen-key.batch
        echo "✓ GPG key generated"
    
    - name: Extract Key ID and Configure Git
      run: |
        KEY_ID=$(gpg --list-keys --with-colons signed@example.com | grep "^pub" | cut -d: -f5)
        
        git config --global user.name "Lab User"
        git config --global user.email "signed@example.com"
        git config --global user.signingkey $KEY_ID
        git config --global gpg.program gpg
        git config --global commit.gpgsign true
        
        echo "✓ Git configured for signing"
    
    - name: Verify Configuration
      run: |
        echo "=== Git Configuration ==="
        git config --global user.name
        git config --global user.email
        git config --global user.signingkey
        git config --global commit.gpgsign
        
        echo ""
        echo "✓ Configuration verified"
```

**What You'll Learn:**
- Configuring Git user settings
- Setting GPG signing key
- Enabling automatic signing
- Verifying configuration

---

## Lab 4.2: Creating Signed Commits

**Objective:** Create and verify commits signed with GPG.

**Concepts:**
- Creating signed commits
- Verifying commit signatures
- Viewing commit details
- Signature status display

**COPY THIS INTO testinglab.yml:**

```yaml
name: Lab 4.2 - Creating Signed Commits

on:
  workflow_dispatch:
  push:
    branches: [ main ]

jobs:
  signed-commits:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout Repository
      uses: actions/checkout@v3
    
    - name: Setup GPG and Git
      run: |
        cat > /tmp/gen-key.batch << 'EOF'
        %echo Generating signing key
        Key-Type: RSA
        Key-Length: 4096
        Subkey-Type: RSA
        Subkey-Length: 4096
        Name-Real: Commit Signer
        Name-Email: commit@example.com
        Expire-Date: 0
        %no-protection
        %commit
        %echo done
        EOF
        
        gpg --batch --generate-key /tmp/gen-key.batch
        
        KEY_ID=$(gpg --list-keys --with-colons commit@example.com | grep "^pub" | cut -d: -f5)
        
        git config --global user.name "Commit Signer"
        git config --global user.email "commit@example.com"
        git config --global user.signingkey $KEY_ID
        git config --global gpg.program gpg
        git config --global commit.gpgsign true
        
        echo "✓ Setup complete"
    
    - name: Create Branch for Commits
      run: |
        BRANCH="signed-commits-$(date +%s)"
        git checkout -b $BRANCH
        echo "WORK_BRANCH=$BRANCH" >> $GITHUB_ENV
        
        echo "✓ Working on: $BRANCH"
    
    - name: Create and Commit Files
      run: |
        mkdir -p signed-demo
        
        cat > signed-demo/feature1.md << 'EOF'
        # Feature 1: User Profile
        - User registration
        - Profile management
        - Avatar support
        EOF
        
        git add signed-demo/feature1.md
        git commit -m "Add user profile feature" || true
        
        cat > signed-demo/feature2.md << 'EOF'
        # Feature 2: Dashboard
        - User dashboard
        - Statistics display
        EOF
        
        git add signed-demo/feature2.md
        git commit -m "Add dashboard feature" || true
        
        echo "✓ Commits created"
    
    - name: View Commit History
      run: |
        echo "=== Commit History ==="
        git log --oneline -5
        
        echo ""
        git log --format="%h | %an | %s" -3
```

**What You'll Learn:**
- Creating signed commits in workflows
- Configuring automatic signing
- Viewing commit history
- Creating feature branches with commits

---

# PART 5: GITHUB ACTIONS TOKENS & PR CREATION

## Lab 5.1: Understanding GitHub Tokens

**Objective:** Learn about GITHUB_TOKEN and how it works.

**Concepts:**
- GITHUB_TOKEN availability
- Token permissions
- Token usage in workflows
- Security considerations

**COPY THIS INTO testinglab.yml:**

```yaml
name: Lab 5.1 - Understanding GitHub Tokens

on:
  workflow_dispatch:
  push:
    branches: [ main ]

jobs:
  github-token:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout Repository
      uses: actions/checkout@v3
    
    - name: Token Information
      run: |
        echo "=== GitHub Token in Workflows ==="
        echo ""
        echo "GITHUB_TOKEN is automatically available:"
        echo "✓ Access via: \${{ secrets.GITHUB_TOKEN }}"
        echo "✓ Scope: Current repository only"
        echo "✓ Expiration: After job completion"
        echo "✓ Permissions: Based on workflow settings"
    
    - name: Check Token Availability
      run: |
        echo "=== Token Availability ==="
        
        if [ ! -z "${{ secrets.GITHUB_TOKEN }}" ]; then
          echo "✓ GITHUB_TOKEN is available"
          TOKEN_LENGTH=${#GITHUB_TOKEN}
          echo "✓ Token length: $TOKEN_LENGTH characters"
        fi
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Use Token for Git
      run: |
        echo "=== Using Token for Git Authentication ==="
        
        git config --global credential.helper store
        echo "https://token:${{ secrets.GITHUB_TOKEN }}@github.com" > ~/.git-credentials
        
        echo "✓ Git authenticated with GITHUB_TOKEN"
    
    - name: API Call with Token
      run: |
        echo "=== GitHub API Call with Token ==="
        
        curl -s -H "Authorization: token ${{ secrets.GITHUB_TOKEN }}" \
          https://api.github.com/repos/${{ github.repository }} | \
          grep -o '"name":"[^"]*' | head -1
        
        echo "✓ API call successful"
```

**What You'll Learn:**
- How GITHUB_TOKEN works
- Token availability
- Using token for Git authentication
- Making API calls with token

---

## Lab 5.2: Pushing Branches and Creating PRs

**Objective:** Push branches and create pull requests from workflows.

**Concepts:**
- Pushing branches from workflows
- Creating pull requests via GitHub CLI
- PR with descriptions and labels
- PR automation

**COPY THIS INTO testinglab.yml:**

```yaml
name: Lab 5.2 - Push Branches and Create PRs

on:
  workflow_dispatch:
  push:
    branches: [ main ]

jobs:
  push-and-pr:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
    
    steps:
    - name: Checkout Repository
      uses: actions/checkout@v3
      with:
        fetch-depth: 0
    
    - name: Configure Git with Token
      run: |
        git config --global user.name "Lab Automation"
        git config --global user.email "automation@lab.local"
        git config --global credential.helper store
        echo "https://token:${{ secrets.GITHUB_TOKEN }}@github.com" > ~/.git-credentials
    
    - name: Create Feature Branch
      run: |
        BRANCH="feature/lab-feature-$(date +%s)"
        git checkout -b $BRANCH
        echo "FEATURE_BRANCH=$BRANCH" >> $GITHUB_ENV
        
        echo "✓ Branch created: $BRANCH"
    
    - name: Create and Commit Files
      run: |
        mkdir -p feature-files
        
        cat > feature-files/feature.md << 'EOF'
        # Feature Implementation
        
        This feature was created by GitHub Actions.
        EOF
        
        cat > feature-files/code.py << 'EOF'
        def new_feature():
            return "Feature works!"
        EOF
        
        git add feature-files/
        git commit -m "Implement new feature from workflow"
        
        echo "✓ Changes committed"
    
    - name: Push Feature Branch
      run: |
        git push origin ${{ env.FEATURE_BRANCH }}
        echo "✓ Branch pushed"
    
    - name: Create Pull Request
      run: |
        gh pr create \
          --title "Feature: Automated PR from workflow" \
          --body "This PR was created automatically by GitHub Actions." \
          --base main \
          --head ${{ env.FEATURE_BRANCH }} \
          --label "automated,github-actions"
        
        echo "✓ Pull Request created!"
      env:
        GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**What You'll Learn:**
- Pushing branches from workflows
- Creating pull requests via GitHub CLI
- Adding PR descriptions and labels
- Automating the PR process

---

# PART 6: COMPLETE END-TO-END WORKFLOW

## Lab 6: Complete Workflow - Branch, Commit, Sign, and Create PR

**Objective:** Implement a complete automation workflow combining all concepts.

**Concepts:**
- Full automation pipeline
- Branch creation
- Signed commits
- Token usage
- PR creation
- Verification

**COPY THIS INTO testinglab.yml:**

```yaml
name: Lab 6 - Complete End-to-End Workflow

on:
  workflow_dispatch:
  push:
    branches: [ main ]

jobs:
  complete-workflow:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
    
    steps:
    - name: "1. Checkout Repository"
      uses: actions/checkout@v3
      with:
        fetch-depth: 0
    
    - name: "2. Generate GPG Key"
      run: |
        cat > /tmp/gen-key.batch << 'EOF'
        %echo Generating key
        Key-Type: RSA
        Key-Length: 4096
        Subkey-Type: RSA
        Subkey-Length: 4096
        Name-Real: Complete Workflow
        Name-Email: workflow@complete.local
        Expire-Date: 0
        %no-protection
        %commit
        %echo done
        EOF
        
        gpg --batch --generate-key /tmp/gen-key.batch
        
        KEY_ID=$(gpg --list-keys --with-colons workflow@complete.local | grep "^pub" | cut -d: -f5)
        echo "KEY_ID=$KEY_ID" >> $GITHUB_ENV
        
        echo "✓ GPG key generated"
    
    - name: "3. Configure Git"
      run: |
        git config --global user.name "Workflow Bot"
        git config --global user.email "workflow@complete.local"
        git config --global user.signingkey ${{ env.KEY_ID }}
        git config --global gpg.program gpg
        git config --global commit.gpgsign true
        
        git config --global credential.helper store
        echo "https://token:${{ secrets.GITHUB_TOKEN }}@github.com" > ~/.git-credentials
        
        echo "✓ Git configured"
    
    - name: "4. Create Feature Branch"
      run: |
        BRANCH="complete-feature-$(date +%s)"
        git checkout -b $BRANCH
        echo "FEATURE_BRANCH=$BRANCH" >> $GITHUB_ENV
        
        echo "✓ Branch created"
    
    - name: "5. Create Project Files"
      run: |
        mkdir -p complete-project
        
        cat > complete-project/main.py << 'EOF'
        """Complete Workflow Project"""
        
        class Application:
            def __init__(self):
                self.name = "Complete Workflow"
                self.version = "1.0.0"
            
            def run(self):
                print(f"{self.name} v{self.version}")
                print("Created by GitHub Actions")
        
        if __name__ == "__main__":
            app = Application()
            app.run()
        EOF
        
        cat > complete-project/README.md << 'EOF'
        # Complete Workflow Project
        
        This project was created entirely by GitHub Actions automation.
        
        ## Features
        - Automated branch creation
        - GPG signed commits
        - Automated PR creation
        EOF
        
        echo "✓ Project files created"
    
    - name: "6. Commit Changes (Signed)"
      run: |
        git add complete-project/
        
        git commit -m "feat: Complete workflow project" \
          -m "- Add main application" \
          -m "- Add documentation"
        
        echo "✓ Signed commit created"
    
    - name: "7. Push Feature Branch"
      run: |
        git push origin ${{ env.FEATURE_BRANCH }}
        echo "✓ Branch pushed"
    
    - name: "8. Create Pull Request"
      run: |
        gh pr create \
          --title "Complete: Automated workflow #${{ github.run_number }}" \
          --body "## Complete Workflow Automation

        This PR demonstrates a complete automated workflow:
        
        ✅ Branch creation
        ✅ File creation
        ✅ GPG signed commits
        ✅ Token authentication
        ✅ Automated PR creation
        
        ### Files
        - main.py: Application code
        - README.md: Documentation" \
          --base main \
          --head ${{ env.FEATURE_BRANCH }} \
          --label "automated,github-actions,complete-workflow"
        
        echo "✓ Pull Request created!"
      env:
        GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    
    - name: "9. Add PR Comment"
      run: |
        PR_NUMBER=$(gh pr list --head ${{ env.FEATURE_BRANCH }} --json number -q '.[0].number')
        
        gh pr comment $PR_NUMBER \
          --body "✅ Workflow complete! All steps executed successfully."
      env:
        GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    
    - name: "10. Summary"
      run: |
        echo ""
        echo "╔════════════════════════════════════════════════════╗"
        echo "║       COMPLETE WORKFLOW - ALL STEPS DONE          ║"
        echo "╚════════════════════════════════════════════════════╝"
        echo ""
        echo "✅ GPG key generation"
        echo "✅ Git configuration"
        echo "✅ Branch creation"
        echo "✅ File creation"
        echo "✅ Signed commits"
        echo "✅ Branch pushed"
        echo "✅ PR created"
        echo "✅ Comment added"
        echo ""
        echo "Branch: ${{ env.FEATURE_BRANCH }}"
        echo "Repository: ${{ github.repository }}"
        echo ""
```

**What You'll Learn:**
- Complete automation pipeline
- Combining all previous concepts
- Branch to PR workflow
- Signed commits in workflows
- Full GitHub integration

---

## Quick Reference

**Run Any Workflow:**
1. Push to `main` branch, or
2. Click "Run workflow" in Actions tab

**Check Results:**
1. Go to Actions tab
2. Click the workflow run
3. Expand each step to see output
4. Check "Annotations" for errors

**Learn from Output:**
Each step prints what it's doing. Read the output carefully to understand Git and GPG behavior.

---

**Happy Learning! 🎓**

Complete labs sequentially for best results.
