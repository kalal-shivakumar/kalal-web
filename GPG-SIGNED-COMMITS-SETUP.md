# GPG Signed Commits Setup Guide

## Overview
This guide documents the complete setup process for GPG signed commits with GitHub integration on Windows.

## Prerequisites
- Git for Windows (includes GPG)
- GitHub account with SSH access
- PowerShell 5.1+
- GPG 2.4.9 or later

## Installation & Configuration

### 1. Verify GPG Installation
```powershell
gpg --version
```

### 2. Generate GPG Key (if not already done)
```powershell
gpg --full-generate-key
# Select: RSA and RSA (default)
# Key size: 4096
# Expiration: 0 (never expires)
# Name: Your Name
# Email: your.email@example.com
```

### 3. Configure Git with GPG Key
```powershell
# Get your key ID (last 16 characters of fingerprint)
gpg --list-keys --with-colons your.email@example.com | Select-String "^pub" 

# Configure Git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global user.signingkey YOUR_KEY_ID
git config --global gpg.program "C:\Users\YourUsername\AppData\Local\Programs\Git\usr\bin\gpg.exe"
git config --global commit.gpgsign true
```

### 4. Export Public Key for GitHub
```powershell
gpg --armor --export your.email@example.com > public-key.asc
```

### 5. Add Public Key to GitHub
1. Navigate to GitHub Settings → SSH and GPG keys
2. Click "New GPG key"
3. Copy the contents of public-key.asc
4. Paste and save

### 6. Create Signed Commit
```powershell
git add .
git commit -m "Your commit message"
# Enter your GPG passphrase when prompted
```

### 7. Verify Signature
```powershell
git verify-commit HEAD
git log --oneline --graph --all
```

## Troubleshooting

### Issue: "No secret key found"
- Verify key exists: `gpg --list-keys`
- Check configuration: `git config --global user.signingkey`
- Regenerate key if needed using the scripts provided

### Issue: "GPG command failed"
- Restart GPG agent: `gpgconf --kill all`
- Check GPG path: `git config --global gpg.program`

### Issue: "Couldn't load public key"
- Verify key in GPG keyring: `gpg --list-keys`
- Export and re-import if needed

## Security Notes

- **Never commit private keys** - `.gitignore` prevents accidental commits
- Use strong passphrases for GPG keys
- Keep private keys backed up securely
- Rotate keys annually or as needed

## GitHub Verification Badge

When you push signed commits:
1. GitHub will show a "Verified" badge next to your commits
2. This indicates the commit was signed with your verified GPG key
3. The badge appears only if the commit email matches your GitHub account

## Files in This Repository

- **GPG-SETUP-README.md**: Comprehensive troubleshooting guide
- **GPG-LEARNINGGUIDE.md**: Detailed learning materials with 7 labs
- **GPG-SAMPLE-KEYS-AND-CODE.md**: Code examples and sample keys
- **scripts/generate-gpg-keys.ps1**: Automated key generation script
- **.gitignore**: Prevents accidental key commits

## Additional Resources

- [GitHub Signing Commits](https://docs.github.com/en/authentication/managing-commit-signature-verification)
- [GPG Documentation](https://gnupg.org/documentation/)
- [Git-GPG Configuration](https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work)
