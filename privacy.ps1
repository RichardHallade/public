# Définir le chemin du fichier de log
$logFile = "C:\Temp\windows_update_log_advanced.txt"

# Créer le dossier C:\Temp s'il n'existe pas
if (-Not (Test-Path "C:\Temp")) {
    New-Item -Path "C:\Temp" -ItemType Directory
}

# Fonction pour écrire dans le log
function Write-Log {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $message"
    Write-Host $logMessage
    Add-Content -Path $logFile -Value $logMessage
}

# Étape 1 : Vérification et correction de la date et de l'heure système
Write-Log "Vérification et correction de la date et de l'heure système..."
try {
    w32tm /resync
    Write-Log "Synchronisation de l'heure réussie."
} catch {
    Write-Log "Erreur lors de la synchronisation de l'heure : $_"
}

# Étape 2 : Réinitialisation complète des composants Windows Update
Write-Log "Arrêt des services Windows Update..."
try {
    Stop-Service -Name wuauserv -Force -ErrorAction Stop
    Stop-Service -Name cryptSvc -Force -ErrorAction Stop
    Stop-Service -Name bits -Force -ErrorAction Stop
    Stop-Service -Name msiserver -Force -ErrorAction Stop

    Start-Sleep -Seconds 5 # Attendre quelques secondes pour s'assurer que les services sont bien arrêtés

    # Prendre possession du dossier et modifier les permissions
    takeown /F "C:\Windows\SoftwareDistribution\Download" /R /D Y
    icacls "C:\Windows\SoftwareDistribution\Download" /grant Administrators:F /T

    # Supprimer les fichiers temporaires de mise à jour
    $downloadPath = "C:\Windows\SoftwareDistribution\Download"
    Get-ChildItem -Path $downloadPath -Recurse | ForEach-Object {
        try {
            Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction Stop
            Write-Log "Fichier supprimé : $($_.FullName)"
        } catch {
            Write-Log "Erreur lors de la suppression de : $($_.FullName) - $_"
        }
    }

    Write-Log "Tous les fichiers de mise à jour supprimés (si possible)."
} catch {
    Write-Log "Erreur lors de l'arrêt des services ou de la suppression des fichiers : $_"
}

# Étape 3 : Réenregistrement des fichiers DLL Windows Update supplémentaires
Write-Log "Réenregistrement des fichiers DLL Windows Update..."
$dlls = @("atl.dll", "urlmon.dll", "mshtml.dll", "shdocvw.dll", "browseui.dll", "jscript.dll", "vbscript.dll", "scrrun.dll", "msxml.dll", "msxml3.dll", "msxml6.dll", "actxprxy.dll", "softpub.dll", "wintrust.dll", "dssenh.dll", "rsaenh.dll", "gpkcsp.dll", "sccbase.dll", "slbcsp.dll", "cryptdlg.dll", "oleaut32.dll", "ole32.dll", "shell32.dll", "wuapi.dll", "wuaueng.dll", "wucltui.dll", "wups.dll", "wups2.dll", "wuweb.dll")

foreach ($dll in $dlls) {
    try {
        regsvr32.exe /s $dll
        Write-Log "Réenregistrement réussi pour : $dll"
    } catch {
        Write-Log "Échec du réenregistrement pour : $dll : $_"
    }
}

# Étape 4 : Exécution de DISM /Cleanup-Image /ResetBase
Write-Log "Exécution de DISM avec /ResetBase..."
try {
    dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase | Out-Null
    Write-Log "DISM exécuté avec succès."
} catch {
    Write-Log "Erreur lors de l'exécution de DISM : $_"
}

# Vérification du service Windows Update (wuauserv)
$windowsUpdateStatus = Get-Service -Name wuauserv
if ($windowsUpdateStatus.Status -ne 'Running') {
    Write-Log "Le service Windows Update est arrêté. Tentative de démarrage..."
    try {
        Start-Service -Name wuauserv -ErrorAction Stop
        Write-Log "Le service Windows Update a démarré avec succès."
    } catch {
        Write-Log "Erreur lors du démarrage du service Windows Update : $_"
    }
} else {
    Write-Log "Le service Windows Update est déjà en cours d'exécution."
}

# Vérification du service Windows Installer (msiserver)
$windowsInstallerStatus = Get-Service -Name msiserver
if ($windowsInstallerStatus.Status -ne 'Running') {
    Write-Log "Le service Windows Installer est arrêté. Tentative de démarrage..."
    try {
        Start-Service -Name msiserver -ErrorAction Stop
        Write-Log "Le service Windows Installer a démarré avec succès."
    } catch {
        Write-Log "Erreur lors du démarrage du service Windows Installer : $_"
    }
} else {
    Write-Log "Le service Windows Installer est déjà en cours d'exécution."
}

# Étape 5 : Détection des mises à jour et affichage des correctifs trouvés
Write-Log "Détection des mises à jour disponibles..."
try {
    $updatesSession = New-Object -ComObject Microsoft.Update.Session
    $updatesSearcher = $updatesSession.CreateUpdateSearcher()
    $searchResult = $updatesSearcher.Search("IsInstalled=0")

    Write-Log "Nombre de mises à jour trouvées : $($searchResult.Updates.Count)"
    if ($searchResult.Updates.Count -eq 0) {
        Write-Log "Aucune mise à jour disponible."
    } else {
        foreach ($update in $searchResult.Updates) {
            Write-Log "Mise à jour trouvée : $($update.Title)"
        }
    }
} catch {
    Write-Log "Erreur lors de la détection des mises à jour : $_"
}

# Redémarrage de l'ordinateur à la fin du script
Write-Log "Redémarrage de l'ordinateur..."
try {
    #Restart-Computer -Force
} catch {
    Write-Log "Erreur lors du redémarrage de l'ordinateur : $_"
}

Write-Log "Script terminé. Veuillez vérifier les résultats dans C:\Temp\windows_update_log_advanced.txt"
