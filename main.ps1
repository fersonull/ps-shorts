# ==============================================================================
# PowerShell Profile Setup Wizard
# ==============================================================================

Clear-Host

# 1. Display a clean UI Header
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "   PowerShell Developer Environment Setup Wizard       " -ForegroundColor White
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host ""

# 2. Ensure Profile Exists
Write-Host "[*] Checking PowerShell profile..." -ForegroundColor Yellow
if (!(Test-Path -Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
    Write-Host "    -> Created new profile at: $PROFILE" -ForegroundColor Green
} else {
    Write-Host "    -> Profile found at: $PROFILE" -ForegroundColor Green
}

# 3. Get and Validate Development Directory
Write-Host ""
Write-Host "[*] Workspace Configuration" -ForegroundColor Yellow
$validPath = $false

while (-not $validPath) {
    $developmentDir = Read-Host "    -> Enter your main development directory path"
    
    if ([string]::IsNullOrWhiteSpace($developmentDir)) {
        Write-Host "       Path cannot be empty. Please try again." -ForegroundColor Red
        continue
    }

    if (!(Test-Path -Path $developmentDir)) {
        $create = Read-Host "       Path does not exist. Create it? (y/n)"
        if ($create -match "^[yY]$") {
            New-Item -ItemType Directory -Path $developmentDir -Force | Out-Null
            Write-Host "       Created directory: $developmentDir" -ForegroundColor Green
            $validPath = $true
        }
    } else {
        $validPath = $true
    }
}

Write-Host "    -> Projects will be initialized in: $developmentDir" -ForegroundColor Cyan
Write-Host ""

# 4. Generate the Profile Payload
Write-Host "[*] Injecting configuration into profile..." -ForegroundColor Yellow

# Using double quotes so $developmentDir is injected, but escaping PS variables with backticks
$commands = @"

# ---------------------------------------------------------
# Custom PowerShell Profile Configuration
# - by https://github.com/fersonull
# ---------------------------------------------------------

# Force UTF-8 Encoding for terminal output
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- Help Menu ---
function psh {
    param(
        [Parameter(Position=0)]
        [string]`$comm = "help"
    )

    switch (`$comm) {
        "help" {
            Write-Host "=========================================================" -ForegroundColor Cyan
            Write-Host " PowerShell Custom Shortcuts                             " -ForegroundColor White
            Write-Host "=========================================================" -ForegroundColor Cyan
            Write-Host "Git:" -ForegroundColor Yellow
            Write-Host "  gs        -> git status"
            Write-Host "  ga        -> git add ."
            Write-Host "  gc <msg>  -> git commit -m 'msg'"
            Write-Host "  gl        -> git log --oneline --graph --decorate --all`n"
            
            Write-Host "PHP / Laravel:" -ForegroundColor Yellow
            Write-Host "  mklara <name> -> Create new Laravel project"
            Write-Host "  pa <args>     -> php artisan <args>`n"
            
            Write-Host "React Native:" -ForegroundColor Yellow
            Write-Host "  mkrnative <name> [version] -> Create new ReactNative project`n"
            
            Write-Host "Utility:" -ForegroundColor Yellow
            Write-Host "  reload    -> Reload PowerShell profile"
            Write-Host "  dev       -> Go to development directory"
            Write-Host "=========================================================" -ForegroundColor Cyan
        }
        default {
            Write-Host "Unknown command. Type 'psh help' to see available shortcuts." -ForegroundColor Red
        }
    }
}

# --- Git Shortcuts ---
function gs { git status }
function ga { git add . }
function gc { param([string]`$msg) git commit -m "`$msg" }
function gl { git log --oneline --graph --decorate --all }

# --- PHP / Laravel Shortcuts ---
function mklara {
    param(
        [Parameter(Mandatory=`$true, Position=0)]
        [string]`$projectName = "./"
    )

    `$targetDir = Join-Path "$developmentDir" "laravel"
    if (!(Test-Path `$targetDir)) { New-Item -ItemType Directory -Path `$targetDir -Force | Out-Null }
    
    Set-Location `$targetDir
    laravel new `$projectName
}

function pa { php artisan `$args }

# --- React Native Shortcuts ---
function mkrnative {
    param(
        [Parameter(Mandatory=`$true, Position=0)]
        [string]`$projectName,

        [Parameter(Position=1)]
        [string]`$version = "0.83.1"
    )

    `$targetDir = Join-Path "$developmentDir" "react-native"
    if (!(Test-Path `$targetDir)) { New-Item -ItemType Directory -Path `$targetDir -Force | Out-Null }
    
    Set-Location `$targetDir
    npx @react-native-community/cli@latest init `$projectName --version `$version
}

# --- Utility ---
function reload { . `$PROFILE ; Write-Host "Profile Reloaded!" -ForegroundColor Green }
function dev { Set-Location "$developmentDir" }

# Print welcome message on startup
Write-Host "Dev Environment Loaded. Type 'psh' for shortcuts." -ForegroundColor DarkGray
Write-Host ""
Write-Host "Visit https://github.com/fersonull for more." -ForegroundColor DarkGray
"@

# 5. Overwrite the profile
Set-Content -Path $PROFILE -Value $commands -Encoding UTF8

Write-Host "    -> Profile successfully updated!" -ForegroundColor Green
Write-Host ""
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host " Setup Complete! Restart PowerShell or run '. `$PROFILE' " -ForegroundColor White
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host ""