# ============================================================================
# GPG Key Generation Script - No Agent Mode
# ============================================================================

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║      GPG KEY GENERATION - COMPLETE SOLUTION FOR WINDOWS      ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green

# ============================================================================
# Step 1: Verify GPG Installation
# ============================================================================
Write-Host "`n[1/6] Verifying GPG Installation..." -ForegroundColor Cyan
$gpgVersion = gpg --version 2>&1 | Select-Object -First 1
Write-Host "✓ $gpgVersion"

# ============================================================================
# Step 2: Prepare GPG Home
# ============================================================================
Write-Host "`n[2/6] Preparing GPG home directory..." -ForegroundColor Cyan
$gnupgHome = "$env:USERPROFILE\.gnupg"

if (-not (Test-Path $gnupgHome)) {
    New-Item -ItemType Directory -Path $gnupgHome -Force | Out-Null
    Write-Host "✓ Created GPG home at: $gnupgHome"
} else {
    Write-Host "✓ GPG home exists at: $gnupgHome"
}

# ============================================================================
# Step 3: Generate Key Pair
# ============================================================================
Write-Host "`n[3/6] Generating RSA 4096-bit key pair..." -ForegroundColor Cyan
Write-Host "⏳ This will take 30-60 seconds..." -ForegroundColor DarkCyan

$batchFile = "$env:TEMP\gpg-keygen-batch.txt"
$batchContent = @"
%echo Generating GPG Key Pair
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

# Generate key
$output = gpg --batch --generate-key $batchFile 2>&1
if ($LASTEXITCODE -eq 0 -or $output -match "generated") {
    Write-Host "✓ Key generation completed"
} else {
    Write-Host "⚠ Generation output: $output" -ForegroundColor Yellow
}

# ============================================================================
# Step 4: List Keys Generated
# ============================================================================
Write-Host "`n[4/6] Retrieving key information..." -ForegroundColor Cyan

$secretKeysOutput = gpg --list-secret-keys shivakumar.kalal@mnscorp.net 2>&1
$publicKeysOutput = gpg --list-keys shivakumar.kalal@mnscorp.net 2>&1

if ($secretKeysOutput -match "sec") {
    Write-Host "✓ Secret key found"
} else {
    Write-Host "⚠ Secret key status: $secretKeysOutput" -ForegroundColor Yellow
}

# ============================================================================
# Step 5: Display Keys
# ============================================================================
Write-Host "`n[5/6] SECRET KEYS:" -ForegroundColor Yellow
Write-Host $secretKeysOutput

Write-Host "`n[5/6] PUBLIC KEYS:" -ForegroundColor Yellow
Write-Host $publicKeysOutput

# Get Key ID
$keyId = $publicKeysOutput | Where-Object { $_ -match "^pub" } | ForEach-Object { ($_ -split '\s+')[1] } | Select-Object -First 1

if ($keyId) {
    Write-Host "`n✓ Your Key ID: $keyId" -ForegroundColor Green
    
    # Get fingerprint
    Write-Host "`nKey Fingerprint:" -ForegroundColor Cyan
    gpg --fingerprint $keyId 2>&1 | Select-Object -Last 2
}

# ============================================================================
# Step 6: Export Keys
# ============================================================================
Write-Host "`n[6/6] Exporting keys..." -ForegroundColor Cyan

$desktopPath = "$env:USERPROFILE\Desktop"
$publicKeyPath = "$desktopPath\public-key.asc"
$privateKeyPath = "$desktopPath\private-key.asc"

# Export public key
gpg --export --armor shivakumar.kalal@mnscorp.net | Out-File -FilePath $publicKeyPath -Encoding UTF8 -Force
Write-Host "✓ Public key exported to: $publicKeyPath"

# Export private key
gpg --export-secret-key --armor shivakumar.kalal@mnscorp.net | Out-File -FilePath $privateKeyPath -Encoding UTF8 -Force
Write-Host "✓ Private key exported to: $privateKeyPath"

# ============================================================================
# Display Summary
# ============================================================================
Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan
Write-Host "✅ GPG KEY GENERATION COMPLETE!" -ForegroundColor Green
Write-Host ("=" * 70) -ForegroundColor Cyan

Write-Host "`nSUMMARY:" -ForegroundColor Green
Write-Host "  Email:        shivakumar.kalal@mnscorp.net"
Write-Host "  Key Type:     RSA 4096-bit"
Write-Host "  Expiration:   Never"
Write-Host "  Key ID:       $keyId"
Write-Host ""
Write-Host "FILES CREATED:" -ForegroundColor Green
Write-Host "  Public Key:   $publicKeyPath"
Write-Host "  Private Key:  $privateKeyPath"
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Green
Write-Host "  1. View public key:    Get-Content $publicKeyPath | Select-Object -First 5"
Write-Host "  2. Add to GitHub:      Go to GitHub Settings → SSH and GPG keys"
Write-Host "  3. Configure Git:      git config --global user.signingkey $keyId"
Write-Host ""
Write-Host ("=" * 70) -ForegroundColor Cyan
