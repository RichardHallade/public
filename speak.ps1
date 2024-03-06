Start-Sleep -s 3

# Sets Volume to max level

$k=[Math]::Ceiling(100/2);$o=New-Object -ComObject WScript.Shell;for($i = 0;$i -lt $k;$i++){$o.SendKeys([char] 175)}

# Sets up speech module 

$s=New-Object -ComObject SAPI.SpVoice
$s.Rate = -2
$s.Speak("We found you")
$s.Speak("We know where you are")
$s.Speak("We are everywhere")
