param ([string] $token,[string] $owner)
Write-host $token
Write-host $owner
$uri = "https://api.github.com/repos/$owner/crl/contents/scripts/ttd.ps1"
$pl = iwr -Uri $uri -Headers @{"Authorization" = "Bearer $token";"Accept" = "application/vnd.github.v3.raw"} -OutFile "c:\temp\ttd.ps1"
#Write-host $pl
#powershell.exe -w h -NoP -NonI -ep Bypass iex $pl
powershell.exe -w h -NoP -NonI -ep Bypass $pl -wait
powershell.exe -w h -NoP -NonI -ep Bypass "c:\temp\ttd.ps1"