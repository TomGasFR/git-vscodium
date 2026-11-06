# Aperçu sans suppression : .\scripts\nettoyage-pc-pret.ps1 -WhatIf
# Exécution : .\scripts\nettoyage-pc-pret.ps1
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
param()

$ErrorActionPreference = 'Stop'

$protectedPaths = @($PSCommandPath)
$directory = Get-Item -LiteralPath $PSScriptRoot
while ($null -ne $directory) {
    if (Test-Path -LiteralPath (Join-Path $directory.FullName '.git')) {
        $protectedPaths += $directory.FullName
        break
    }
    $directory = $directory.Parent
}

$browserProcesses = @(
    'brave',
    'chrome',
    'chromium',
    'firefox',
    'msedge',
    'opera',
    'vivaldi'
)

$browserProfiles = @(
    @{ Name = 'Google Chrome'; Path = (Join-Path $env:LOCALAPPDATA 'Google\Chrome\User Data') },
    @{ Name = 'Microsoft Edge'; Path = (Join-Path $env:LOCALAPPDATA 'Microsoft\Edge\User Data') },
    @{ Name = 'Brave'; Path = (Join-Path $env:LOCALAPPDATA 'BraveSoftware\Brave-Browser\User Data') },
    @{ Name = 'Chromium'; Path = (Join-Path $env:LOCALAPPDATA 'Chromium\User Data') },
    @{ Name = 'Vivaldi'; Path = (Join-Path $env:LOCALAPPDATA 'Vivaldi\User Data') },
    @{ Name = 'Firefox (itinérant)'; Path = (Join-Path $env:APPDATA 'Mozilla\Firefox') },
    @{ Name = 'Firefox (local)'; Path = (Join-Path $env:LOCALAPPDATA 'Mozilla\Firefox') },
    @{ Name = 'Opera'; Path = (Join-Path $env:APPDATA 'Opera Software\Opera Stable') },
    @{ Name = 'Opera (local)'; Path = (Join-Path $env:LOCALAPPDATA 'Opera Software\Opera Stable') },
    @{ Name = 'Opera GX'; Path = (Join-Path $env:APPDATA 'Opera Software\Opera GX Stable') },
    @{ Name = 'Opera GX (local)'; Path = (Join-Path $env:LOCALAPPDATA 'Opera Software\Opera GX Stable') }
)

$existingProfiles = @(
    $browserProfiles | Where-Object {
        Test-Path -LiteralPath $_.Path -PathType Container
    }
)

$foldersToEmpty = @(
    $env:TEMP,
    (Join-Path $env:LOCALAPPDATA 'Temp'),
    (Join-Path $env:APPDATA 'Microsoft\Windows\Recent'),
    (Join-Path $env:USERPROFILE 'Downloads'),
    [Environment]::GetFolderPath('Desktop'),
    [Environment]::GetFolderPath('MyDocuments'),
    [Environment]::GetFolderPath('MyPictures'),
    [Environment]::GetFolderPath('MyMusic'),
    (Join-Path $env:USERPROFILE 'Videos')
) | Where-Object { $_ } | Select-Object -Unique

$existingFolders = @(
    $foldersToEmpty | Where-Object {
        Test-Path -LiteralPath $_ -PathType Container
    }
)

function Test-ContainsProtectedPath {
    param([string]$Path)

    $candidate = [IO.Path]::GetFullPath($Path).TrimEnd('\') + '\'
    foreach ($protectedPath in $script:protectedPaths) {
        $protected = [IO.Path]::GetFullPath($protectedPath).TrimEnd('\') + '\'
        if ($protected.StartsWith($candidate, [StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }
    return $false
}

$runningBrowsers = @(
    Get-Process -Name $browserProcesses -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty ProcessName -Unique
)
if ($runningBrowsers.Count -gt 0) {
    throw "Ferme les navigateurs avant de continuer : $($runningBrowsers -join ', ')."
}

Write-Host 'Cette opération supprime les profils locaux complets des navigateurs,'
Write-Host 'les contenus de Téléchargements, Bureau, Documents, Images, Musique et Vidéos,'
Write-Host 'ainsi que des dossiers temporaires et récents.'
Write-Host 'Les favoris et mots de passe locaux non synchronisés seront perdus.'
Write-Host 'Le profil Windows complet n’est pas supprimé.'
Write-Host ''
Write-Host 'Profils de navigateurs détectés :'
foreach ($profile in $existingProfiles) {
    Write-Host "  $($profile.Name) : $($profile.Path)"
}
Write-Host 'Dossiers dont le contenu sera vidé :'
foreach ($folder in $existingFolders) {
    Write-Host "  $folder"
}

if (-not $WhatIfPreference) {
    $confirmation = Read-Host 'Tape EFFACER pour confirmer'
    if ($confirmation -cne 'EFFACER') {
        Write-Host 'Annulé. Aucune donnée n’a été supprimée.'
        exit 0
    }
}

foreach ($profile in $existingProfiles) {
    $profileItem = Get-Item -LiteralPath $profile.Path -Force
    if ($profileItem.Attributes -band [IO.FileAttributes]::ReparsePoint) {
        Write-Warning "Profil ignoré car il s'agit d'un lien ou d'une jonction : $($profile.Path)"
        continue
    }
    if ($PSCmdlet.ShouldProcess($profile.Path, "Supprimer le profil complet de $($profile.Name)")) {
        Remove-Item -LiteralPath $profile.Path -Recurse -Force
    }
}

foreach ($folder in $existingFolders) {
    $items = @(Get-ChildItem -LiteralPath $folder -Force)
    foreach ($item in $items) {
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            Write-Warning "Élément ignoré car il s'agit d'un lien ou d'une jonction : $($item.FullName)"
            continue
        }
        if (Test-ContainsProtectedPath -Path $item.FullName) {
            Write-Host "Dépôt ou script conservé : $($item.FullName)"
            continue
        }
        if ($PSCmdlet.ShouldProcess($item.FullName, 'Supprimer')) {
            Remove-Item -LiteralPath $item.FullName -Recurse -Force
        }
    }
}

Write-Host 'Nettoyage terminé pour le compte Windows courant.'
Write-Host 'Les données synchronisées dans les comptes en ligne ne sont pas supprimées.'
