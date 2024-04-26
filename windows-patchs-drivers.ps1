# Definir le chemin du dossier pour le fichier de logs
$logFolderPath = 'C:\temp'

# Verifier si le dossier existe, sinon le creer
if (-not (Test-Path -Path $logFolderPath -PathType Container)) {
    Write-Host "Creating log folder: $logFolderPath"
    New-Item -Path $logFolderPath -ItemType Directory | Out-Null
}

# Definir le chemin du fichier de logs
$logFilePath = Join-Path -Path $logFolderPath -ChildPath 'installation_log.txt'

# Fonction pour ecrire dans le fichier de logs avec deetails des installations
function Write-Log {
    param(
        [string]$message
    )
    $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $message"
    $logMessage | Out-File -Append -FilePath $logFilePath
    Write-Host $logMessage
}

Write-Log "Script started"

# Verifier si le module PSWindowsUpdate est deja installe
if ($null -eq (Get-Module -Name PSWindowsUpdate -ListAvailable)) {
    Write-Log "Installing NuGet package provider"
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

    Write-Log "Installing PSWindowsUpdate module"
    Install-Module PSWindowsUpdate -Force
    Import-Module PSWindowsUpdate
    Write-Log "PSWindowsUpdate module installed"
}

Write-Log "Force-checking for updates"

# Verifier les mises a jour installees avec deetails
$installedUpdates = Get-WUInstall -AcceptAll -Install -AutoReboot

# Log pour chaque patch installee avec details
foreach ($update in $installedUpdates) {
    $updateDetails = "Installed patch: $($update.Title) (KB $($update.KnowledgebaseArticles))"
    Write-Log $updateDetails
    foreach ($detail in $update.Details) {
        Write-Log "    $detail"
    }
}

Write-Log "Windows Update installation completed"
Write-Log "Script finished"

Restart-Computer -Force
