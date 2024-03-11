# Vérifiez la version de Windows
$osVersion = [System.Environment]::OSVersion.Version
if ($osVersion.Major -ne 10 -or $osVersion.Minor -lt 0) {
    Write-Host "Ce script est conçu pour Windows 10. La version actuelle de Windows n'est pas prise en charge."
    exit
}

# Spécifiez le répertoire de destination où vous souhaitez enregistrer le fichier.
$dir = 'C:\temp'

# Spécifiez le chemin du fichier de log.
$logFile = Join-Path -Path $dir -ChildPath 'installation.log'

# Créez un objet pour la journalisation.
$logger = [System.IO.StreamWriter]::new($logFile)

# Fonction pour écrire des messages de journalisation.
function LogMessage($message) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $message"
    $logger.WriteLine($logEntry)
    Write-Host $logEntry
}

# Spécifiez l'URL du fichier que vous souhaitez télécharger.
$url = 'https://go.microsoft.com/fwlink/?LinkID=799445'

# Spécifiez le chemin complet du fichier de destination.
$file = Join-Path -Path $dir -ChildPath 'Windows10Upgrade9252.exe'

# Vérifiez si le fichier existe déjà, si c'est le cas, sautez l'étape de téléchargement.
if (-not (Test-Path $file)) {
    # Log du début du téléchargement.
    LogMessage "Début du téléchargement du fichier depuis $url"

    # Ajoutez des gestionnaires d'erreurs pour le téléchargement
    try {
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $url -OutFile $file -UseBasicParsing

    } catch {
        LogMessage "Erreur lors du téléchargement du fichier : $_"
        exit
    }

    # Attendez jusqu'à ce que le fichier soit complètement téléchargé (vérification toutes les 2 secondes).
    while (-not (Test-Path $file)) {
        Start-Sleep -Seconds 2
    }

    # Log de la fin du téléchargement.
    LogMessage "Téléchargement terminé. Fichier enregistré sous $file"
} else {
    # Log indiquant que le fichier existe déjà.
    LogMessage "Le fichier $file existe déjà. Étape de téléchargement ignorée."
}

# Ajoutez des gestionnaires d'erreurs pour le démarrage du processus d'installation
try {
    # Log de l'installation.
    LogMessage "Début de l'installation de $file"
    Start-Process -FilePath $file -ArgumentList "/quietinstall /skipeula /auto upgrade /copylogs $dir" -Wait
    LogMessage "Installation terminée."
} catch {
    LogMessage "Erreur lors du démarrage du processus d'installation : $_"
}

# Fermez le fichier de log.
$logger.Close()
