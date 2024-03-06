Start-Sleep -s 3

# Sets Volume to max level

$k=[Math]::Ceiling(100/2);$o=New-Object -ComObject WScript.Shell;for($i = 0;$i -lt $k;$i++){$o.SendKeys([char] 175)}

#Start-Process "https://www.youtube.com/watch?v=xm3YgoEiEDc?autoplay=1" -WindowStyle maximized
#STRING Powershell -command "$wshell = New-Object -ComObject wscript.shell;[system.Diagnostics.Process]::Start(\"msedge\",\"about:blank\");Sleep 1;$wshell.SendKeys('^"{l}"');Sleep 1;$wshell.SendKeys('https://fakeupdate.net/win10ue/');$wshell.SendKeys('"{Enter}"');$wshell.SendKeys('"{F11}"')"
#$wshell = New-Object -ComObject wscript.shell;[system.Diagnostics.Process]::Start("msedge");Sleep 1;$wshell.SendKeys('^"{l}"');Sleep 1;$wshell.SendKeys('"https://fakeupdate.net/win10ue/"');$wshell.SendKeys('"{Enter}"');$wshell.SendKeys('"{F11}"')
$wshell = New-Object -ComObject wscript.shell;Start-Process "https://www.youtube.com/watch?v=xm3YgoEiEDc";Sleep 1;$wshell.SendKeys('"{Enter}"');Sleep 2;$wshell.SendKeys('"{F}"')
