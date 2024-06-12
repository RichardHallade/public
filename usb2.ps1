# Sets Volume to max level
$k = [Math]::Ceiling(100/2)
$o = New-Object -ComObject WScript.Shell
for ($i = 0; $i -lt $k; $i++) {
    $o.SendKeys([char]175)
}

# Sets up speech module
$s = New-Object -ComObject SAPI.SpVoice

# Set the voice (change 'Microsoft Zira Desktop - English (United States)' to a female voice on your system)
$desiredVoice = 'Microsoft Zira Desktop - English (United States)'
$availableVoices = $s.GetVoices()

$voice = $availableVoices | Where-Object { $_.GetDescription() -eq $desiredVoice }

if ($voice -eq $null) {
    Write-Host "Voice '$desiredVoice' not found. Using the default voice."
    $voice = $availableVoices[0]  # Utiliser la première voix par défaut
}

$s.Voice = $voice

$s.Rate = -2
$s.Speak("Wake up Neo")
$s.Speak("The Matrix has you")
$s.Speak("Follow the white rabbit")
$s.Speak("Knock, knock, Neo.")
