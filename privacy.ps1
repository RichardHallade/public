# Créer le dossier de log s'il n'existe pas déjà
$logDir = 'C:\temp'
if (-not (Test-Path -Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir
}

# Fichier de log
$logFile = "$logDir\privacy.log"

# Fonction pour écrire dans le fichier de log
function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logEntry = "$timestamp [$Level] $Message"
    Add-Content -Path $logFile -Value $logEntry
}

# Fonction pour supprimer un package Appx et le déprovisionner
function Remove-AppxPackageAndDeprovision {
    param (
        [string]$PackageName,
        [string]$RegistryKeyPath
    )

    # Supprimer le package Appx
    Write-Log "Removing $PackageName..."
    try {
        Get-AppxPackage -Name $PackageName | Remove-AppxPackage
        Write-Log "Successfully removed $PackageName."
    } catch {
        Write-Log "Failed to remove $PackageName: $($_.Exception.Message)" "ERROR"
    }

    # Déprovisionner le package
    $registryHive = $RegistryKeyPath.Split('\')[0]
    $registryPath = "$($registryHive):$($RegistryKeyPath.Substring($registryHive.Length))"

    if (Test-Path $registryPath) {
        Write-Log "Skipping, no action needed, registry path '$registryPath' already exists."
        return
    }

    try {
        New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null
        Write-Log "Successfully created the registry key at path '$registryPath'."
    } catch {
        Write-Log "Failed to create the registry key at path '$registryPath': $($_.Exception.Message)" "ERROR"
    }
}

# Début du script
Write-Log "Script started."

# Supprimer "Microsoft Windows Client Web Experience"
Remove-AppxPackageAndDeprovision -PackageName 'MicrosoftWindows.Client.WebExperience' -RegistryKeyPath 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\MicrosoftWindows.Client.WebExperience_cw5n1h2txyewy'

# Supprimer l'icône "Meet Now" de la barre des tâches
Write-Log "Removing 'Meet Now' icon from taskbar..."
try {
    Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name 'HideSCAMeetNow' -Value 1 -Type DWord
    Write-Log "'Meet Now' icon removed from taskbar."
} catch {
    Write-Log "Failed to remove 'Meet Now' icon: $($_.Exception.Message)" "ERROR"
}

# Configurer le serveur NTP
Write-Log "Setting NTP (time) server to 'pool.ntp.org'..."
try {
    w32tm /config /syncfromflags:manual /manualpeerlist:"0.pool.ntp.org,1.pool.ntp.org,2.pool.ntp.org,3.pool.ntp.org"
    if ((Get-Service -Name w32time).Status -eq 'Running') {
        Stop-Service -Name w32time
    }
    Start-Service -Name w32time
    w32tm /config /update
    w32tm /resync
    Write-Log "NTP server configured successfully."
} catch {
    Write-Log "Failed to configure NTP server: $($_.Exception.Message)" "ERROR"
}

# Liste des packages à supprimer
$packagesToRemove = @{
    'king.com.CandyCrushSaga' = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\king.com.CandyCrushSaga_kgqvnymyfvs32'
    'king.com.CandyCrushSodaSaga' = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\king.com.CandyCrushSodaSaga_kgqvnymyfvs32'
    'ShazamEntertainmentLtd.Shazam' = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\ShazamEntertainmentLtd.Shazam_pqbynwjfrbcg4'
    'Flipboard.Flipboard' = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Flipboard.Flipboard_3f5azkryzdbc4'
    '9E2F88E3.Twitter' = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\9E2F88E3.Twitter_wgeqdkkx372wm'
    'ClearChannelRadioDigital.iHeartRadio' = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\ClearChannelRadioDigital.iHeartRadio_a76a11dkgb644'
    'D5EA27B7.Duolingo-LearnLanguagesforFree' = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\D5EA27B7.Duolingo-LearnLanguagesforFree_yx6k7tf7xvsea'
    'AdobeSystemsIncorporated.AdobePhotoshopExpress' = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\AdobeSystemsIncorporated.AdobePhotoshopExpress_ynb6jyjzte8ga'
    'PandoraMediaInc.29680B314EFC2' = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\PandoraMediaInc.29680B314EFC2_n619g4d5j0fnw'
    '46928bounde.EclipseManager' = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\46928bounde.EclipseManager_a5h4egax66k6y'
    'ActiproSoftwareLLC.562882FEEB491' = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\ActiproSoftwareLLC.562882FEEB491_24pqs290vpjk0'
    'SpotifyAB.SpotifyMusic' = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\SpotifyAB.SpotifyMusic_zpdnekdrzrea0'
    'Microsoft.Appconnector' = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.Appconnector_8wekyb3d8bbwe'
}

# Supprimer les packages spécifiés
foreach ($package in $packagesToRemove.Keys) {
    Remove-AppxPackageAndDeprovision -PackageName $package -RegistryKeyPath $packagesToRemove[$package]
}

# Fin du script
Write-Log "Script completed."

# Pause pour visualiser l'état final
Read-Host -Prompt "Press Enter to continue..."

# Sortir du script avec succès
exit 0
