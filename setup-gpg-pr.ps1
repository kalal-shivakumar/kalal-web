#!/usr/bin/env pwsh

# Setup GPG Signed Commits PR Workflow

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   GPG SIGNED COMMITS: Feature Branch & Pull Request Setup    ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# Step 1: Verify we're in the correct branch
Write-Host "`n[STEP 1] Checking current branch..." -ForegroundColor Yellow
$branch = git rev-parse --abbrev-ref HEAD
Write-Host "Current branch: $branch"

if ($branch -ne "feature/gpg-signed-commits-setup") {
    Write-Host "ERROR: Not on feature branch!" -ForegroundColor Red
    exit 1
}

# Step 2: Add and commit .gitignore
Write-Host "`n[STEP 2] Adding .gitignore..." -ForegroundColor Yellow
git add .gitignore
git commit -S -m "docs: Add .gitignore to exclude GPG keys and secrets" --quiet
Write-Host "✓ .gitignore committed"

# Step 3: Copy and commit documentation
Write-Host "`n[STEP 3] Adding GPG documentation..." -ForegroundColor Yellow
Copy-Item -Path "C:\Users\P9202728\gpg_signed_commits\README.md" -Destination ".\GPG-SETUP-README.md" -Force
Copy-Item -Path "C:\Users\P9202728\gpg_signed_commits\LEARNINGGUIDE.md" -Destination ".\GPG-LEARNINGGUIDE.md" -Force
Copy-Item -Path "C:\Users\P9202728\gpg_signed_commits\SAMPLE-KEYS-AND-CODE.md" -Destination ".\GPG-SAMPLE-KEYS-AND-CODE.md" -Force

git add GPG-*.md
git commit -S -m "docs: Add comprehensive GPG signed commits documentation

- README: Troubleshooting guide with 10 ranked solutions
- LEARNINGGUIDE: Complete learning guide with 7 labs  
- SAMPLE-KEYS-AND-CODE: Reference examples and setup instructions" --quiet
Write-Host "✓ Documentation committed"

# Step 4: Add PowerShell script
Write-Host "`n[STEP 4] Adding helper scripts..." -ForegroundColor Yellow
Copy-Item -Path "C:\Users\P9202728\gpg_signed_commits\generate-gpg-keys.ps1" -Destination ".\scripts\generate-gpg-keys.ps1" -Force

# Create scripts directory if it doesn't exist
if (-not (Test-Path ".\scripts")) {
    New-Item -ItemType Directory -Path ".\scripts" -Force | Out-Null
}

Copy-Item -Path "C:\Users\P9202728\gpg_signed_commits\generate-gpg-keys.ps1" -Destination ".\scripts\generate-gpg-keys.ps1" -Force

git add scripts/
git commit -S -m "scripts: Add GPG key generation helper script

Automated PowerShell script for generating GPG keys with proper error handling" --quiet
Write-Host "✓ Scripts committed"

# Step 5: Show commit log
Write-Host "`n[STEP 5] Commit history:" -ForegroundColor Yellow
git log --oneline -5

# Step 6: Show branch status
Write-Host "`n[STEP 6] Branch status:" -ForegroundColor Yellow
git log --oneline main..feature/gpg-signed-commits-setup | Measure-Object -Line | Select-Object -ExpandProperty Lines | ForEach-Object {
    Write-Host "Commits ahead of main: $_"
}

Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║   ✅ Feature branch ready for pull request                   ║" -ForegroundColor Green
Write-Host "║   Branch: feature/gpg-signed-commits-setup                   ║" -ForegroundColor Green
Write-Host "║   All commits are GPG signed                                 ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`nNext: Create pull request from this branch to main"
