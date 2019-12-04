Set-PSDebug -Trace 0
#Variables
$pass = '' ; $SVersion = '' ; $LVersion = ''

While ($pass -ne 'pass'){ #while server version and local version do not match.
    $ErrorActionPreference  = "SilentlyContinue"
    Write-Host "Getting Server version"
    $SVersion = get-content "$server\Master User Script\Data\Version.txt" #Get server version $Server = your server location (Cleaned for Github Public)
    Write-Host "Getting Local version"
    $LVersion = get-content C:\Powershell_Scripts\Master User Script\data\Version.txt #get local
    $ErrorActionPreference  = "Continue"

    If ($SVersion -gt $LVersion){ #check if versions match
        If (!$Lversion -or !(Test-Path -path "C:\Powershell_Scripts\Master User Script\data")){#If the path doesn't exist, create it.
        Write-warning "No Local version detected`nCreating Local Version from server."
            New-Item "C:\Powershell_Scripts\Master User Script\Data" -ItemType Directory
        }
        If ($Lversion){#If there is a local version, just let them know we're updating it.
            Write-warning "Version Mismatch!"
            Write-host "Getting New Version"
        }
        Try{Copy-Item -force -recurse -Path "$server\Master User Script\Master_User_Script.ps1" -Destination "C:\Powershell_Scripts\Master User Script\Master_User_Script.ps1"} #Script Copy $Server = your server location (Cleaned for Github Public)
        Catch{$update = 'failed'}
        If($update -eq 'failed'){Write-Warning "Something went wrong, unable to copy script from server"}
        else{Copy-Item -force -recurse -Path "$server\Master User Script\Data\Version.txt" -Destination "C:\Powershell_Scripts\Master User Script\Data\Version.txt"} #version Copy $Server = your server location (Cleaned for Github Public)
    }
    If ($LVersion -eq $SVersion){ #if they do match Line 24
    Write-Host "Enjoy your tool!"
        $pass = 'pass'
    }
    If (!$Sversion -and $LVersion){
    Write-warning "`n Unable to check version control`n Using existing local version"
    sleep 5
    $pass = 'pass'
    }
    If (!$SVersion -and !$LVersion){
    Write-Warning "Unable to check server version, and no local version exists."
    pause
    }
}
$ErrorActionPreference = "Continue"
Start-Process powershell.exe C:\Powershell_Scripts\Master User Script\Master_User_Script.ps1 -NoNewWindow #Start Script