# Define paths
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$logDirectory = "C:\temp\win11"
$logPath = "$logDirectory\upgrade_$timestamp.log"
$msiFileName = "WindowsPCHealthCheckSetup.msi"
$downloadPath = "$logDirectory\Windows11InstallationAssistant.exe"
$msiFilePath = Join-Path $logDirectory $msiFileName

# Ensure directory exists
if (-not (Test-Path -Path $logDirectory)) {
    New-Item -Path $logDirectory -ItemType Directory
}

# Create log file
New-Item -Path $logPath -ItemType File -Force

# Function to write log
function Write-Log {
    param ([string]$message)
    Add-Content -Path $logPath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $message"
}

# Check if Windows PC Health Check is already installed
if (-not (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Windows PC Health Check")) {
    # Download and install Windows PC Health Check if not installed
    $msiDownloadUrl = "https://download.microsoft.com/download/d/5/9/d59a6828-52d9-4d08-a995-3c08cef7e802/3.7/x64/$msiFileName"
    try {
        # Download Windows PC Health Check MSI
        if (-not (Test-Path $msiFilePath)) {
            Invoke-WebRequest -Uri $msiDownloadUrl -OutFile $msiFilePath -ErrorAction Stop
            Write-Log "Downloaded Windows PC Health Check MSI to $msiFilePath"
        }

        # Install the software silently
        Start-Process -FilePath msiexec.exe -ArgumentList "/i `"$msiFilePath`" /qn" -Wait -ErrorAction Stop
        Write-Log "Installed Windows PC Health Check silently"
    } catch {
        Write-Log "An error occurred during download or installation of Windows PC Health Check: $_"
    }
} else {
    Write-Log "Windows PC Health Check is already installed."
}

# Check if Windows 11 Installation Assistant is already present
if (-not (Test-Path $downloadPath)) {
    # Download Win11 upgrade package
    $win11DownloadUrl = "https://go.microsoft.com/fwlink/?linkid=2171764"
    try {
        Invoke-WebRequest -Uri $win11DownloadUrl -OutFile $downloadPath -ErrorAction Stop
        Write-Log "Downloaded Windows 11 Installation Assistant to $downloadPath"
    } catch {
        Write-Log "An error occurred during download of Windows 11 Installation Assistant: $_"
    }
} else {
    Write-Log "Windows 11 Installation Assistant is already present."
}

# Continue with Windows 11 upgrade task
try {
    # Start the Windows 11 Installation Assistant with specified arguments
    Start-Process -FilePath $downloadPath -ArgumentList '/quietinstall', '/skipeula', '/auto upgrade' -Wait
} catch {
    Write-Log "An error occurred during Windows 11 upgrade: $_"
}
