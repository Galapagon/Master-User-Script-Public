Set-PSDebug -Trace 0
#Title
$host.UI.RawUI.WindowTitle = "Master User Script"
$host.ui.RawUI.ForegroundColor = "green"
$host.ui.RawUI.BackgroundColor = "black"

$Version = "3.0010"
#Admin Check
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    pause
    Break
}
Write-Host "
Version $Version

          _____                            _____                            _____          
         /\    \                          /\    \                          /\    \         
        /::\____\                        /::\____\                        /::\    \        
       /::::|   |                       /:::/    /                       /::::\    \       
      /:::::|   |                      /:::/    /                       /::::::\    \      
     /::::::|   |                     /:::/    /                       /:::/\:::\    \     
    /:::/|::|   |                    /:::/    /                       /:::/__\:::\    \    
   /:::/ |::|   |                   /:::/    /                        \:::\   \:::\    \   
  /:::/  |::|___|______            /:::/    /      _____            ___\:::\   \:::\    \  
 /:::/   |::::::::\    \          /:::/____/      /\    \          /\   \:::\   \:::\    \ 
/:::/    |:::::::::\____\        |:::|    /      /::\____\        /::\   \:::\   \:::\____\
\::/    / ~~~~~/:::/    /        |:::|____\     /:::/    /        \:::\   \:::\   \::/    /
 \/____/      /:::/    /          \:::\    \   /:::/    /          \:::\   \:::\   \/____/ 
             /:::/    /            \:::\    \ /:::/    /            \:::\   \:::\    \     
            /:::/    /              \:::\    /:::/    /              \:::\   \:::\____\    
           /:::/    /                \:::\__/:::/    /                \:::\  /:::/    /    
          /:::/    /                  \::::::::/    /                  \:::\/:::/    /     
         /:::/    /                    \::::::/    /                    \::::::/    /      
        /:::/    /                      \::::/    /                      \::::/    /          by Galapagon
        \::/    /                        \::/____/                        \::/    /        
         \/____/                          ~~                               \/____/            with Jakeops
                                                                                                    Unseen
                                                                                               
                                                                                               
Instant Email from Jumpbox!
"
#migrate to Try{} Catch{} for errors - invoke set
#fix GM for purgatory check #I think this was completed

#Variables
$MVerify = '' ; $Username = '' ; $ADCHeck = '' ; $Verify = '' ; $DistinguishedName = '' ; $SessionID = '' ; $city = '' ; $FullName = '' ; $FirstName = '' ; $LastName = '' ; $verify = ''
$FirstInitial = '' ; $SecondInitial = '' ; $Username = '' ; $me = (whoami).split('\')[1] ; $Username2 = '' ; $confirm = '' ; $Display = '' ; $Credential = '' ; $KeyPath = "C:\Powershell_Scripts\Master User Script\Keys\" ; $test = ''

#Credential Check
$ErrorActionPreference = "silentlycontinue"
$Password = Get-Content "C:\Powershell_Scripts\Master User Script\Keys\Defaultpassword.cred" | ConvertTo-SecureString
$ErrorActionPreference = "continue"
If(!$Password){
	if (-not(Test-Path -path c:\powershell_scripts\Master User Script\keys)){md $KeyPath}
	$Credential = Get-Credential -Message "Enter Default End User Password" -UserName "DefaultPassword"
	$path = 'C:\Powershell_Scripts\Master User Script\Keys\defaultpassword.cred'
	$Credential.Password | ConvertFrom-SecureString | Out-File $path
	$Password = Get-Content "C:\Powershell_Scripts\Master User Script\Keys\Defaultpassword.cred" | ConvertTo-SecureString
}

#Master Loop
While ("$Mverify" -ne 'exit') {
	$host.UI.RawUI.WindowTitle = "Master User Script v$Version"

#Clearing Variables
	$Verify = '' ; $DistinguishedName = '' ; $ADCHeck = '' ; $City = '' ; $Ticket = '' ; $test = '' ; $ccsiloop = '' ; $ADCheck2 = '' ; $Condense = '' ; $title = "" ; $AddCCSIAGENT = ""
	If ($Check -eq 'n'){$Username = '' ; $Check = ''}
	If (!$Mverify){
        Write-Host "`n`n############################################################################################################"
        $Mverify = Read-Host "`n 1) New User`n      1.2) CCSI `n`n 2) Anixis/Reset/Unlock User`n`n 3) Purgatory User`n`n 4) New Email`n`n 5) Add Missing Memberships`n`n O) Other`n`nWhat would you like to do"
    }

    If ($MVerify -eq '1' -or $MVerify -eq '1.2') {#New User
		$host.UI.RawUI.WindowTitle = "MUS v$version : New User"
		$test = ""
		While($test -ne 'pass'){
            $City = ''; $office = '' ; $ccsi = ''
			#Set Variables
            If ($Mverify -eq '1'){
			    $Office = Read-Host "`nActive Directory City Code (null for New Computers)"
            }
            If ($Mverify -eq '1.2'){
                $Office = 'CCSI'
            }
			If (!$Office){
                $city = "OU=New Computers"
                $Office = "OU=New Computers"
                Write-Warning "Please move target out of new computers"
                Pause
            }
            If ($Office -eq "ucf"){
                $City = "OU=Desktop Users,OU=UCF"
            }
			If($office -and $office -ne "ucf"){
                $City = "OU=Users,OU=" + $Office
                }
			if(!$Test){
				$FullName = Read-Host "`nUser's Full Name"
				$FirstName,$LastName = $FullName.Split(' ')
				$FirstInitial = $FirstName.Substring(0,1)
				$SecondInitial = $FirstName.Substring(0,2)
				$Username = ($FirstInitial + $Lastname)
				$Username2 = ($SecondInitial + $Lastname)
				$Display = ($Lastname + ", " + $FirstName)
			}
		    #Check to see if the Username is in use
			$ErrorActionPreference = "silentlycontinue"
			$ADCHeck = (Get-ADuser -Identity $Username -Properties DistinguishedName, Modified)
			$ErrorActionPreference = "continue"
			#If an existing user is found
			If($ADCHeck){
                #ask if that is the user they were trying to make
			   $Usr = Read-Host `n $ADCHeck.distinguishedname `n "Last Modified:" $ADCheck.Modified `n`n "Is this the user you are trying to create? (y/n)"
                ##if not, continue secondary naming
               If($Usr -eq 'n'){
                   $Username = $Username2
                   #Check for existing user again
                   	$ErrorActionPreference = "silentlycontinue"
			        $ADCHeck2 = (Get-ADuser -Identity $Username -Properties DistinguishedName, Modified)
			        $ErrorActionPreference = "continue"

                   #If there is another user, ask if that's who they wanted
                   If($ADCHeck2){
                   		$Usr2 = Read-Host `n $ADCHeck2.distinguishedname `n "Last Modified:" $ADCheck2.Modified `n`n "Is this the user you are trying to create? (y/n)"

                        #If that's still not who they wanted, start manual naming
                        If($Usr2 -eq 'n'){
                            #until we find a valid name
                            $manualusername = '' ; $adcheck = ''
                            While ($manualusername -ne 'yes' -and $username -ne 'exit'){
                                $ADCHeck = ''
                                #enter a desired username manually
                                $Username = Read-Host "Please enter desired Username (Login)[or exit]"
                                $ErrorActionPreference = "silentlycontinue"
			                    $ADCHeck = (Get-ADuser -Identity $Username -Properties DistinguishedName, Modified)
			                    $ErrorActionPreference = "continue"
                                    #Check to see if name is taken
                                    If(!$ADCHeck){
                                        $manualusername = 'yes'
                                    }
                                    If($ADCHeck){
                                        Write-Warning "Username already taken"
                                        Write-Host `n $ADCHeck.distinguishedname `n "Last Modified:" $ADCheck.Modified
                                        $adcheck = ''
                                    }
                            }
                            If($username -eq 'exit'){
                                $Verify = 'n' ; $test = 'pass'
                            }
                       }

                   }
				}
                   ##If that is the user they were trying to make we're done
               If($Usr -ne 'n'){
					Write-host "`nUser already exists!`n"
					$Verify = 'n' ; $test = 'pass'
               }
			}

            IF($USR -eq 'n' -or !$adcheck) {
                Write-Host "`nFirst Name: $firstname`nLast Name: $lastname`nUsername:$Username`nCity: $City"
                $Verify = Read-Host "`nDoes this Look correct? (y/n/exit) Default (Y)"
                    IF(!$Verify){
                        $Verify = 'y'
                    }
                    IF($Verify -eq "n"){
						$test = ""
                    }
            }

			If($Verify -eq "y"){
                $Ticket = Read-Host "Add Ticket Number? (Enter Number)"
                IF(!$Ticket){$Ticket = "Ticket Not Entered"}
                IF($Ticket -and $Ticket -ne "Ticket Not Entered"){$Ticket = "Created: OSTicket #"+$Ticket}
                IF($mverify -eq '1'){$Title = Read-Host "Enter Job title"
					If(!$Title){$title = 'blank'}
                }
                Write-Host
				if ($city -eq 'OU=Users,OU=ccsi'){
                    $CCSI = Read-Host "CCSI Default? (Y/N) Default (Y)`n (CCSi Agents, No Term Server users, Yes $company2, Standard Interet, No email)" #$company2 should be replaced with actual membership name (Cleaned for Github Public
                    IF(!$CCSI){$ccsi = 'y'}
                    If($ccsi -eq 'y'){
						$title = 'CCSi Agents' ; $AddTSU = 'n' ; $Add$company2 = 'y'; $AddInt = 'n' ; $AddCCSIAGENT = 'y' ; $AddEmail = 'n' #$add$company2 is an invalid statement (Cleaned for Github Public)
                    }
                    If ($ccsi -eq 'n'){
						$Title = Read-Host "Enter Job title (Default Customer Service)"
						If(!$Title){$Title = "CCSi Agents"}
						$AddTSU = Read-Host "`nAdd Term Server Users? (y/n) Default(N)"
						$Add$company2 = Read-Host "Add $company2 Users? (y/n) Default(Y)" #$add$company2 is an invalid statement (Cleaned for Github Public)
						$AddCCSIAGENT = Read-Host "Add CCSI Agents? (y/n) Default(Y)"
						$AddInt = Read-Host "`nUpgrade Internet from Standard to Unrestricted? (y/n) Default(N)"
						$AddEmail = Read-Host "`nCreate email address? (y/n) Default(N)"
                    }
                }
				if ($city -ne 'OU=Users,OU=ccsi'){
					$AddTSU = Read-Host "`nAdd Term Server Users? (y/n) Default(N)"
                    $AddInt = Read-Host "Upgrade Internet?`n Default (Restricted)`n S(tandard)`n U(nrestricted)`n(S/U/Ent)"
                    $AddEmail = Read-Host "`nCreate email address? (y/n) Default(N)" 
                }
                if($AddEmail -eq "y"){
                    $server = "$Server = your server location (Cleaned for Github Public)"
                }
                Else{
                    $server = Get-ADDomainController
                }
				#Start Create user
				$UPNname = ($Username + "@comapny.com") #@Company.com Should be replaced with your domain (Cleaned for Github Public)
				#Distinguish Usernames
                Write-Host
				Write-Host "`nUsername will be $Username. Copied to clipboard!"
				$Username | Set-Clipboard
                If($City -eq 'ucf'){
                    $city = 'OU=Desktop Users,OU=UCF'
                }
                #Create User

                New-ADUser -Name $fullname -AccountPassword $password -ChangePasswordAtLogon 1 -City $city -Description "$Ticket By $me" -DisplayName $Display -Enabled 1 -GivenName $Firstname -Office $office -Path "$City,OU=Sites,DC=$company,DC=com" -SamAccountName $username -Server $server -Surname $Lastname -Title $title -UserPrincipalName $UPNname #$company should be replaced with your domain (Cleaned for Github Public

                #Get DistinguishedName
				Sleep 2 #Pause for SessionID Latch
				$ErrorActionPreference = "silentlycontinue"
				$DistinguishedName = (Get-ADuser -Server $server -Identity $Username -Properties DistinguishedName).DistinguishedName ; If(!$DistinguishedName){Sleep 2 ; $DistinguishedName = (Get-ADuser -Server $server -Identity $Username -Properties DistinguishedName).DistinguishedName} ; If(!$DistinguishedName){Sleep 2 ; $DistinguishedName = (Get-ADuser -Server $server -Identity $Username -Properties DistinguishedName).DistinguishedName} ; If(!$DistinguishedName){Sleep 2 ; $DistinguishedName = (Get-ADuser -Server $server -Identity $Username -Properties DistinguishedName).DistinguishedName} ; If(!$DistinguishedName){Sleep 2 ; $DistinguishedName = (Get-ADuser -Server $server -Identity $Username -Properties DistinguishedName).DistinguishedName} ; If(!$DistinguishedName){Sleep 2 ; $DistinguishedName = (Get-ADuser -Server $server -Identity $Username -Properties DistinguishedName).DistinguishedName} ; If(!$DistinguishedName){Sleep 2 ; $DistinguishedName = (Get-ADuser -Server $server -Identity $Username -Properties DistinguishedName).DistinguishedName}
				$ErrorActionPreference = "continue"

				If($DistinguishedName){
					Write-Host "`nCreated User"
					Write-Host "Target:" $DistinguishedName
                    Write-Host

					#Set Sessions
                    Try{
					$SessionID = [adsi]"LDAP://$server/$DistinguishedName"
					Write-Host "Set Idle Time to 30min" $SessionID.psbase.InvokeSet('MaxIdleTime', 30)
					Write-Host "Set Disconnect to 1min" $SessionID.psbase.InvokeSet('MaxDisconnectionTime', 1)
					$SessionID.psbase.CommitChanges()
                    }
                    Catch{
                    Write-warning "Unable to set Idle time and Session limit, they will need to be added manually. `nCopied to desktop."
                    add-content $Home\Desktop\Missing_Sessions.txt `n$Username
                    }

					#Verify
					Get-ADUser -Server $server -Identity $Username

					#Memberships

					if ($AddTSU -eq "y") {
						Add-ADGroupMember -Server $server -Identity "Term Server Users" -Members $Username
					}

					if ($city -ne 'OU=Users,OU=ccsi'){
                            Try{
                                Add-ADGroupMember -Server $server -Identity "$office general users" -Members $Username
                            }
                            Catch{
                                Write-Warning "I tried adding the general users membership, but was unable to"
                            }
							If(!$addint -or $AddInt -eq "default" -or $AddInt -eq "d"){
								Add-ADGroupMember -Server $server -Identity "Internet Access (Restricted)" -Members $Username
								$AddInt = "n"
							}
							If($addint -eq "s"){
								Add-ADGroupMember -Server $server -Identity "Internet Access (Standard)" -Members $Username
								$AddInt = "n"
							}
							If($addint -eq "u"){
								Add-ADGroupMember -Server $server -Identity "Internet Access (Un-Restricted)" -Members $Username
								$AddInt = "n"
							}
						
					}
					if ($city -eq 'OU=Users,OU=ccsi'){
							If($addint -eq "n" -or !$addint){
								Add-ADGroupMember -Server $server -Identity "Internet Access (Standard)" -Members $Username
							}
							If($addint -eq "y" -or $addint -eq 'u'){
								Add-ADGroupMember -Server $server -Identity "Internet Access (Un-Restricted)" -Members $Username
                            }
						
						if ($Add$company2 -ne "n") { #Two $ in one statement like this creates an Invalid Statement (Cleaned for Github Public)
							Add-ADGroupMember -Server $server -Identity "Rds $company2 Users" -Members $Username # $company would be replaced with the appropriate company name (Cleaned for GitHub Public)
                        }
                        
                        if ($AddCCSIAGENT -ne 'n'){
                            Add-ADGroupMember -Server $server -Identity "CCSi Agents" -Members $Username
                        }
					}
                    
                    #Get Idle and Disconnect time, display error friendly.
                    Try{
					    Write-Host
					    Write-Host "Idle Limit" $SessionID.psbase.InvokeGet('MaxIdleTime')
					    Write-Host "End Disconnect" $SessionID.psbase.InvokeGet('MaxDisconnectionTime')
                    }
                    Catch{
                        Write-Warning "Unable to check session settings, probably due to delayed server replication."
                    }
                    Try{
                        Sleep 3
					    Write-Host "`n
					    $FirstName is a Member Of:"
					    Get-ADPrincipalGroupMembership -Server $server $Username | select name
                    }
                    Catch{
                        Write-Warning "Unable to get user memberships, probably due to delayed server replication."
                    }
					$Test = 'pass'
				}
				else{
					Write-Host "Invalid City Code or Unable to obtain Distinguished Name."
					$Test = 'fail'#loop back
				}
				If ($AddEmail -eq 'y'){
					$MVerify = '4' #Create Email
				}
			}
        }
			If ($AddEmail -ne 'y' -or $Verify -eq 'exit'){
                $MVerify = ''
                $AddEmail = ''
                $Test = 'pass'
            }
    #End Script
    Write-Host "############################################################################################################"  
	}#New User
		

    If ($Mverify -eq '2') {#Reset/Unlock
        While($Check -ne 'n'){
            $Reset = '' ; $username = ''
            $host.UI.RawUI.WindowTitle = "MUS v$version : Anixis Check, Reset & Unlock"
            #Get User
            $Username = Read-Host "What is the username? (or exit)"
            If($Username -ne 'exit'){
                Try{$DistinguishedName = (Get-ADuser -Identity $Username -Properties DistinguishedName).DistinguishedName
                    Write-Host "Target:" $DistinguishedName
                    $confirm = Read-Host 'Is this the User you want to Check? (y/n/exit)'
                    }
                Catch{Write-Warning "Unable to get Distinguished Name"
                    $confirm = 'n'
                }
                If($confirm -eq 'y'){
                    $Anixis = ((Invoke-WebRequest -Uri "$WebURL/$username" -Method Post).Content | ConvertFrom-Json).isEnrolled #$WebURL = your webURL location (Cleaned for Github Public)
                    If($Anixis){Write-Host 'This user is enrolled in Anixis!' -BackgroundColor "Green" -ForegroundColor "Black"
                         pause}
                    If(!$Anixis){Write-Warning 'User is not enrolled in Anixis.'
                        pause}

                    $Reset = read-host ' Do you want to manually unlock the user, and reset their password? (y/n/exit)'
                }
            }
            If ($Reset -eq 'y'){
                $Server = Read-host 'What server do you want to use? (Default $server)' ; If(!$Server){$Server = '$Server'} #$Server = your server location (Cleaned for Github Public)

                #Reset
                Set-ADAccountPassword -Reset -NewPassword $Password –Identity $Username -Server $Server
                Write-host "Reset $Username`'s Password"

                #Force Reset
                Set-ADUser –Identity $Username –ChangePasswordAtLogon 1 -Server $Server
                write-host "Force Change Password at Logon"

                #Unlock
                Unlock-ADAccount –Identity $Username -Server $Server
                Write-Host "Forced Unlock Account"

                $Check = 'n'
            }
            If ($confirm -eq 'exit' -or $username -eq 'exit' -or $reset -eq 'exit'){
                $Check = 'n' ; $mverify = ''
            }
        }
        $Mverify = ''
    }#Reset/Unlock

    If ($MVerify -eq '3') {#Move User to Purgatory

    $host.UI.RawUI.WindowTitle = "MUS v$version : Purgatory"

        While($Check -ne 'n'){
        #Variables
        $vpn = '' ; $check = '' ; $DistinguishedName = '' ; $Username = '' ; $enabled = '' ; $email = '' ; $USRGM = '' ; $getaduser = '' ; $EA10 = '' ; $EA12 = '' ; $FWDstatus = '' ; $FWTicket = ''

        #start
            $Username = Read-Host "`nWhat is the username you want to disable? (or exit)"
            If($username -eq 'exit'){$Check = 'n'}
            $ErrorActionPreference = "silentlycontinue"
			$Getaduser = (Get-ADuser -Identity $Username -Properties DistinguishedName, Modified, extensionattribute10, extensionattribute12, description)
            $DistinguishedName = ($getaduser).distinguishedname ; $EA10 = ($GetADUser).extensionattribute10 ; $EA12 = ($GetADUser).extensionattribute12 ;$FWTicket = ($GetADUser).extensionattribute10 ; $FWDstatus = ($GetADUser).extensionattribute12
            $ErrorActionPreference = "continue"
			If($DistinguishedName -and $Username -ne 'exit'){
				write-host "`n"
                $DistinguishedName
                $Getaduser.modified
				$verify = Read-Host "`nIs this correct? (y/n) (Default y)"
				If($Verify -ne 'n'){
                        $ErrorActionPreference = "silentlycontinue"
                        $Vpn = Get-ADPrincipalGroupMembership -Identity $Username | select -ExpandProperty Name | Where-Object { $_ -like 'VPN Enabled Domain Users' }| Sort
                        $ErrorActionPreference = "continue"
                        sleep 1
                        $1,$2,$3 = $DistinguishedName -split ",OU="
                        $office,$4,$5 =  $3 -split ","

                    #VPN Check
                    If($vpn){
                        Remove-ADGroupMember -Identity 'VPN Enabled Domain Users' -Members $username -Confirm:$False
                        Write-Warning 'User Was a Member of VPN Enabled Domain Users'
                        pause
                    }
                    #Email Check
                    $Email = (Get-ADUser -Identity $Username -Properties EmailAddress).EmailAddress #Check if user has Email
                    If($Email -and $fwdstatus -ne 'none'){
                        Write-Warning "User had Email Address"
                        Try{$gmlist = import-csv -Path "$server\Master User Script\Data\Gmlist.txt"} #Path to shared notepad with list of GMs $Server = your server location (Cleaned for Github Public)
                        Catch{Write-Host "Unable to reach GM list"}
                        ForEach ($item in $gmlist){ 
                            $Gmsite = $($item.Site)
                            $GM = $($item.GM)
                            If($gmsite -eq $Office -and $0ffice -ne "New Computers"){#Gm check / cleanup ##new computers switch to holding folder
                                Write-Host `n
                                Write-Warning "Please Contact $gm for email Fwd Instructions"
                            }
                            If($gmsite -eq $2 -and $2 -isnot "users"){
                                Write-Host `n
                                Write-Warning "Please Contact $gm for email Fwd Instructions"
                            }

                        }
                        While  (!$Ticket -and !$ea10){ #GM Purgatory Tickets
                            $Ticket = Read-Host "Please enter Ticket Number for GM E-Mail"
                            If(![bool]($Ticket -as [int])){
                                Write-Host "Please enter a Ticket Number Ex: 12345"
                                }
                            }
                        $date = get-date -UFormat "%Y %m %d" 
                        Set-ADUser $username -Replace @{extensionAttribute10 = "$Ticket OS"} #Ticket Number
                        Set-ADUser $username -Replace @{extensionAttribute11 = "Termed $date"} #Term Date
                        Set-ADUser $username -Replace @{extensionAttribute12 = "Waiting"} #Fwd Date
                        $Ticket = "OsTicket Gm Fwd #" + "$Ticket"
                    }

                    If(!$Email){
                        Move-ADObject -Identity $DistinguishedName -TargetPath 'OU=Purgatory,DC=$domain,DC=com' #Move to Regular Purgatory $domain = your domain name (Cleaned for Github Public)
                        #Purgatory Tickets
                        $ticket = Read-Host "Add Ticket Number?(Enter Number)"
                        IF(!$Ticket){$Ticket = "Ticket Not Entered"}
                        IF($Ticket -and $Ticket -ne "Ticket Not Entered"){$Ticket = "Purgatory OSTicket #$Ticket by $me"}
                    }

                    If($Fwdstatus -ne 'none'){
                        $Description = $getaduser.description #Get User Description
                        $Description = "$Ticket" + " " + "$Description" #add ticket details to Beginning of Description
                        Set-ADUser -Identity $username -Description "$Description" #set description
                    }
                    Disable-ADAccount $username
                    $enabled = (Get-ADUser -Identity $Username).enabled

                    while($enabled -eq $true){
                        Write-Host "`n`nChecking if user is disabled"
                        sleep 5
                        $enabled = (Get-ADUser -Identity $Username).enabled
                    }
                    If($enabled -eq $false){
                        $DistinguishedName = (Get-ADuser -Identity $Username -Properties DistinguishedName).DistinguishedName
                        write-Host `n$DistinguishedName
                        Write-Host "`nUser has been Disabled"
                    }
                    $check = 'n'
                
                If($FWDstatus){
                Write-Host "Forward Status for $username is $FWDstatus`n Check Ticket $fwticket for more information"
                $PurgMove = Read-Host "Would you like to change user?`n 1) Purgatory 2)Fwd 3)cancel "#2) Termed User Email Fwd Email FWD folder is currently non functional.
                If($PurgMove -eq '1'){
                    Move-ADObject -Identity $DistinguishedName -TargetPath 'OU=Purgatory,DC=$domain,DC=com' #Move to Regular Purgatory $domain = your domain name (Cleaned for Github Public)
                    #Purgatory Tickets
                    Set-ADUser $username -Replace @{extensionAttribute12 = "None"} #Fwd status
                    If(!$ticket){$Ticket = Read-Host "Add Ticket Number?(Enter Number)"}
                    IF(!$Ticket){
                        $Ticket = "Ticket Not Entered"
                    }
                    IF($Ticket -and $Ticket -ne "Ticket Not Entered"){
                        $Ticket = "Purgatory OSTicket #$Ticket by $me"
                    }
                    $Description = ($GetADUser).description #Get User Description
                    $Description = "$Ticket" + " " + "$Description" #add ticket details to Beginning of Description
                    Set-ADUser -Identity $username -Description "$Description" #set description
                }
                If($Purgmove -eq '2'){
                    Set-ADUser $username -Replace @{extensionAttribute12 = "Forward"}#Fwd  Status
                    Write-warning "Please ensure Email team is aware of FWD request"
                    pause
                }
			}
        }
            }
            If(!$DistinguishedName -and -$username -ne 'exit'){
                Write-Host "Unable to get Distinguished Username"
            }
        }
        $Mverify = ''
    }#Move user to purgatory

    If ($MVerify -eq '4') {#New Email Created by Unseen edited by Galapagon
		$host.UI.RawUI.WindowTitle = "MUS v$version : Unseen`'s Email Creator"
			#Starting Script
			$verify = ''
            If(!$server){$server = Get-ADDomainController}
			While($Verify -ne "exit"){
				#Variables
				IF ($addemail -ne 'y'){
					$username = "" ; $FirstName = "" ; $LastName = "" ;  $ADCHeck = ""
					write-host
					write-host "#################################################################"
					write-host
					$Username = Read-Host "What is the username?"
				}
				If ($username -ne 'exit'){

					#Fill variables with names
					IF ($addemail -ne 'y'){
					$ADCHeck = Get-ADUser $Username -server $server # $server = your server (Cleaned for Github Public)
					If($ADCHeck){
							Get-ADUser $username | foreach {
							$FirstName = $_.GivenName 
							$LastName = $_.SurName
						}
					
							#Are the names correct?
							Write-Host "Please confirm the names:"`n
							Write-Host "First Name: $FirstName `nLast Name: $LastName"`n
							$Verify = Read-Host "Are they correct?(y/n/exit)"
						}
					}
					If (!$ADCHeck -and $addemail -ne 'y'){
						$Verify = 'n'
					}
					If($verify -eq "n" -and $addemail -ne 'y') {
						Write-Host "Unable to fetch User."
					}

					If($Verify -eq "y" -or $addemail -eq 'y'){
						$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$Exchangehub/PowerShell/?SerializationLevel=Full -Authentication Kerberos #Your Exchange Hub should go here (Cleaned for Github public)
						Import-PSSession $Session
						Enable-RemoteMailbox $username -RemoteRoutingAddress $FirstName`.$LastName@lehub.mail.onmicrosoft.com
						Remove-PSSession $Session
						Set-ADUser -server $server $username -replace @{extensionAttribute15 = "TOD"}
                        If($AddEmail = 'y'){
                            $addemail = ''
                            $Username | Set-Clipboard
                            Get-ADUser -server $server $USername -properties EmailAddress | Select EmailAddress
                        }
					}

				}
				$Mverify = ''
				$Verify = "exit"
			}

    }#New Email

    If ($MVerify -eq '5') {#Check Membership & Sessions
		$host.UI.RawUI.WindowTitle = "MUS v$version : Missing Sessions"
        Function MissingSessions{
            $FullHome = import-csv -path "$Home\Desktop\Missing_Sessions.txt"
            foreach ($username in $FullHome){
                $username = $($username).H1
                Write-Host "`n###########################`n`n$username"
                If($username){
                    $DistinguishedName = (Get-ADuser -Identity $Username -Properties DistinguishedName).DistinguishedName
                    Try{
                        $SessionID = [adsi]"LDAP://$DistinguishedName"
	                    Write-Host "`nSet Idle Time to 30min" $SessionID.psbase.InvokeSet('MaxIdleTime', 30)
	                    Write-Host "Set Disconnect to 1min" $SessionID.psbase.InvokeSet('MaxDisconnectionTime', 1)
	                    $SessionID.psbase.CommitChanges()
                    }
                    Catch{
                        Write-warning "`nUnable to set Idle time and Session limit, please check User:$username manually, then remove it from $Home\Desktop\Missing_Sessions.txt"
                        pause
                        $set = "fail"
                    }
                    If($set -ne "fail"){
                        Try{
		                    Write-Host "`nIdle Limit" $SessionID.psbase.InvokeGet('MaxIdleTime')
		                    Write-Host "End Disconnect" $SessionID.psbase.InvokeGet('MaxDisconnectionTime')
                        }
                        Catch{
                            Write-Warning "Unable to check session settings, probably due to delayed server replication. This sessions module will not update for safety unless all tests pass"
                            pause
                            $set2 = "fail"
                        }
                    }
                }
            }
            write-host "`n###########################"
            If($set -ne "fail" -and $set2 -ne "fail"){
                Write-Host "`nOperations Completed Successfully"
                $Clear = Read-Host "Do you want to clear the Missing Sessions file? (y/n)"
                If($Clear -eq "y" -or $clear -eq "yes"){
                    Remove-Item -path "$Home\Desktop\Missing_Sessions.txt"
                }
            }
        }
        MissingSessions
        
        $Mverify = ''
    }#Check Membership & Sessions

    If ($Mverify -eq 'o' -or $mverify -eq '0'){

        Write-Host "`n`n############################################################################################################"
        $Mverify2 = Read-Host "`n1) Reset Default Password`n`n2) Check GM Site`n`n3) Membership Fix`n`n4) Sessions Fix`n`n91)Version Override`n`nb) Back`n`nWhat would you like to do"

        If ($Mverify2 -eq '1'){
            Function RemovePassword{
                $RemoveVerify = Read-Host "`nAre you sure you want to reset the default password?(y/n)"
                If($RemoveVerify -eq 'y'){
                    Remove-Item -path "C:\Powershell_Scripts\Master User Script\Keys\defaultpassword.cred"
                    Write-Warning "`n`nYou will now be prompted to re-enter the default end user Password`n"
                    pause
                    if (-not(Test-Path -path c:\powershell_scripts\Master User Script\keys)){md $KeyPath}
	                $Credential = Get-Credential -Message "Enter Default end user Password" -UserName "DefaultPassword"
	                $path = 'C:\Powershell_Scripts\Master User Script\Keys\defaultpassword.cred'
	                $Credential.Password | ConvertFrom-SecureString | Out-File $path
	                $Password = Get-Content "C:\Powershell_Scripts\Master User Script\Keys\Defaultpassword.cred" | ConvertTo-SecureString
                }
            }
            RemovePassword
            $MVerify = '' ; $mverify2 = ''
        }#Reset Default Password

        If ($MVerify2 -eq '2'){#Check Gm Site

        $office = Read-Host "`nWhat is the Site you need a GM for?"

        $gmlist = import-csv -Path "$server\Master User Script\Data\Gmlist.txt" #Path to shared notepad with list of GM $server = your server (Cleaned for Github Public)
                        ForEach ($item in $gmlist){ 
                            $Gmsite = $($item.Site)
                            $GM = $($item.GM)
                            If($gmsite -eq $Office -and $office -ne "New Computers"){#Gm check / cleanup ##new computers switch to holding folder
                                Write-Host `n`n
                                Write-host "Please Contact $gm"
                            }
                            If($gmsite -eq $2 -and $2 -isnot "users"){
                                Write-Host `n`n
                                Write-Warning "Please Contact $gm"
                            }
                            }
        write-host `n
        pause
        $MVerify = '' ; $mverify2 = ''

    }#Check Gm Site

        If ($MVerify2 -eq '3') {#Membership Fix
		$host.UI.RawUI.WindowTitle = "MUS v$version : Membership Fix"
        If(!$Username){$Username = Read-Host "What is the username you want to check?"}
       
       #Memberships
        $AddTSU = Read-Host "Add Term Server Users? (y/n)"
        if ($AddTSU -eq "y") {
           Add-ADGroupMember -Identity "Term Server Users" -Members $Username
        }

        $Add$compnay2 = Read-Host "Add $company2 Users? (y/n)" #$add$company2 is an invalid statement (Cleaned for Github Public)
        if ($Add$company2 -eq "y") {                           #again, $add$company2 should only have one $, and inside quotes should have the actual membership name (Cleaned for Github Public)
			Add-ADGroupMember -Identity "Rds $company2 Users" -Members $Username #(Cleaned for Github Public)
        }

        $AddInt = Read-Host " r(estricted)`n s(tandard)`n u(nrestricted)`n n(o)`n Add Internet?"
        While ($AddInt -ne "n") {
            If($addint -eq "r"){
                Add-ADGroupMember -Identity "Internet Access (Restricted)" -Members $Username
                $AddInt = "n"
            }
            If($addint -eq "s"){
                Add-ADGroupMember -Identity "Internet Access (Standard)" -Members $Username
                $AddInt = "n"
            }
            If($addint -eq "u"){
                Add-ADGroupMember -Identity "Internet Access (Un-Restricted)" -Members $Username
                $AddInt = "n"
            }
        }
        $Mverify = '' ; $Mverify2 = ''
    } #Membership Fix

        If ($Mverify2 -eq '4') {#Sessions Fix
		$host.UI.RawUI.WindowTitle = "MUS v$version : Sessions Fix"
        If(!$Username){$Username = Read-Host "What is the username you want to check?"}
        $ADCHeck = Get-ADUser $Username
        $AdCheck
			
        #Get DistinguishedName
            $DistinguishedName = (Get-ADuser -Identity $Username -Properties DistinguishedName).DistinguishedName
            Write-Host "Target:" $DistinguishedName
            write-host "`n"

            #Set Sessions
            While($Check -ne 'n'){
                $SessionID = [adsi]"LDAP://$DistinguishedName"
                Write-Host "Set Idle Time to 30min" $SessionID.psbase.InvokeSet('MaxIdleTime', 30)
                Write-Host "Set Disconnect to 1min" $SessionID.psbase.InvokeSet('MaxDisconnectionTime', 1)
                write-host "`n"
                $SessionID.psbase.CommitChanges()

                #Verify
                Write-Host "Idle Limit" $SessionID.psbase.InvokeGet('MaxIdleTime')
                Write-Host "End Disconnect" $SessionID.psbase.InvokeGet('MaxDisconnectionTime')
                $Check = Read-Host 'Do you want to check again? (y/n)'
            }
			write-host "`n"
			Write-Host "####################################################################################"
        $Mverify = '' ; $Mverify2 = ''
    } #Sessions Fix

        If ($Mverify2 -eq '91'){#Version Hotfix
            Write-host "This utility is designed to force pull an update from a user defined server, reguardless of version."
            $SVersion = "" ; $Server = "" ; $override = ""
            $server = read-host "What server do you want to pull from? (Default $server)" #$server = your server name (Cleaned for Github Public)
            If (!$Server) {$Server = "$server"} #$server = your server name (Cleaned for Github Public)
            $SVersion = get-content "\\$server\Master User Script\Data\Version.txt" ; Write-Host "The server version at $Server is $Sversion" #Get server version and output to console #$server = your server name (Cleaned for Github Public)
            $LVersion = get-content C:\Powershell_Scripts\Master User Script\data\Version.txt ; Write-host "Your local version is $Lversion" #Get local version and output to console 

            $override = Read-Host "Do you want to override your local version from the server? (y/n)"
            If ($override -eq 'y' -and $SVersion -lt $LVersion){
                Write-Warning "Your local version is $lversion and server is only $sversion"
                $override2 = Read-Host "Are you sure you want to override?(y/n)"
            }
            if ($override -eq 'y' -or $override2 -eq 'y') {                
                Try{Copy-Item -force -recurse -Path "\\$server\Master User Script\Master_User_Script.ps1" -Destination "C:\Powershell_Scripts\Master_User_Script.ps1"} #Script Copy #$server = your server name (Cleaned for Github Public)
                Catch{$update = 'failed'}
                If($update -eq 'failed'){Write-Warning "Something went wrong, unable to copy script from server"}
                else{Copy-Item -force -recurse -Path "\\$server\Master User Script\Data\Version.txt" -Destination "C:\Powershell_Scripts\Master User Script\Data\Version.txt"} #$server = your server name (Cleaned for Github Public)
                clear-host ; $LVersion = get-content C:\Powershell_Scripts\Master User Script\data\Version.txt ; Write-host "Your local version is now $Lversion"
                Start-Process powershell.exe C:\Powershell_Scripts\Master User Script\Master_User_Script.ps1 -NoNewWindow ; exit
            }
            Else{Write-Host "Keeping Version $lverson"}
        } #Version Hotfix

    
        Else {$Mverify = '' ; $Mverify2 = ''}

    }

    If($MVerify -eq 'admin'){
        $admin = '' ; $Sversion = ''
        $admin = Read-Host "Admin pannel`n 1)Set Test version`n 2)Set Regular Version"

        If($admin -eq '1'){ #Test version should not be necessary if you are using version control.
            Write-Warning "This is the Live Version"
            $Confirm = Read-Host "`nSet Test Script to Version $Version ?"
            If ($confirm -eq 'y'){
                $Version | Set-Content '$server\Master User Script\Data\Test_version.txt' #$server = your server name (Cleaned for Github Public)
                $SVersion = get-content "$server\Master User Script\Data\Test_version.txt" #$server = your server name (Cleaned for Github Public)
                Write-Host "Version Set to $sversion"
            }
        }
        If($admin -eq '2'){
            $Confirm = Read-Host "Set Script to Version $Version ?"
            If ($confirm -eq 'y'){
                $Version | Set-Content '$server\Master User Script\Data\Version.txt' #$server = your server name (Cleaned for Github Public)
                $SVersion = get-content "$Server\Master User Script\Data\Version.txt" #$server = your server name (Cleaned for Github Public)
                Write-Host "$sversion"
            }
        }
    $confirm = ''
    $Sversion = ''
    $Mverify = ''

    }

    If ($mverify -eq 'exit'){Exit}

    Else {$Mverify = ''}
}