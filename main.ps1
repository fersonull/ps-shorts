# 1. First, make sure the profile file actually exists. If not, create it.
if (!(Test-Path -Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force
}

# Path to folder where user puts their source codes
$developmentDir = Read-Host "Enter your development directory path "

Write-Host "All your projects will be initialized inside $developmentDir" -ForegroundColor Blue

# 2. Define the text you want to inject using a Here-String
$commands = @"

# ---------------------------------------------------------
# Custom PowerShell Profile Configuration
# - by https://github.com/fersonull
# ---------------------------------------------------------

# --- Git Shortcuts ---
function gs { git status }
function ga { git add . }
function gc { param([string]`$msg) git commit -m "`$msg" }
function gl { git log --oneline --graph --decorate --all }

# --- PHP / Laravel Shortcuts ---
# Make a laravel project using laravel installer
function mklara {
    param(
        [Parameter(Mandatory=`$true, Position=0)]
        [string]`$projectName
    )

    mkdir laravel
    
    Set-Location "$developmentDir\laravel"

    laravel new `$projectName
}

# PHP Artisan command shortcut: php artisan -> paj
function pa { php artisan @Args }

# --- React Native Shortcuts ---
# Create a new React Native project
function mkrnative {
    param(
        [Parameter(Mandatory=`$true, Position=0)]
        [string]`$projectName,

        [Parameter(Position=1)]
        [string]`$version = "0.83.1"
    )

    $path = "$developmentDir\react-native"

    mkdir react-native

    Set-Location "$developmentDir\react-native"

    npx @react-native-community/cli@latest `$projectName --version `$version
}

# --- Utility ---
# Quick command to reload the profile after making changes
function reload { . $PROFILE }

# Change into Development Directory
function dev { Set-Location $developmentDir }

"@

# 3. Append the text to the profile file
Set-Content -Path $PROFILE -Value $commands

Write-Host "Profile updated successfully! Restart PowerShell or run '. `$PROFILE' to apply changes." -ForegroundColor Green