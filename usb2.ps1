# Définir l'URL de l'image
$imageUrl = "https://raw.githubusercontent.com/RichardHallade/public/de7a08056b5f34decd4271b34eef251581440b60/hacking.png"

# Définir le chemin où l'image sera sauvegardée localement
$imagePath = "c:\temp\test.png"

# Télécharger l'image
Invoke-WebRequest -Uri $imageUrl -OutFile $imagePath

# Définir le fond d'écran
function Set-Wallpaper {
    param (
        [string]$Path
    )
    
    Add-Type @"
        using System;
        using System.Runtime.InteropServices;
        public class Wallpaper {
            [DllImport("user32.dll", CharSet = CharSet.Auto)]
            public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
            public const int SPI_SETDESKWALLPAPER = 0x0014;
            public const int SPIF_UPDATEINIFILE = 0x01;
            public const int SPIF_SENDWININICHANGE = 0x02;
        }
"@
    
    [Wallpaper]::SystemParametersInfo(0x0014, 0, $Path, 0x01 -bor 0x02)
}

# Appeler la fonction pour définir le fond d'écran
Set-Wallpaper -Path $imagePath
