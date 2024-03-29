#powershell.exe


# Written by: Aaron Wurthmann
#
# You the executor, runner, user accept all liability.
# This code comes with ABSOLUTELY NO WARRANTY.
# You may redistribute copies of the code under the terms of the GPL v3.
#
# --------------------------------------------------------------------------------------------
# Name: Set-Profile.ps1
# Version: 2021.03.01.095301
# Description: Script used to install or 'set' the Windows PowerShell profile.
# 
# Instructions:
#	Copy/Paste the line below into PowerShell for default settings (Current User/Local Host)
#		iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/awurthmann/my-powershell-profile/main/Set-Profile.ps1'))
#	or to change the default arguments
#		$installScript=((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/awurthmann/my-powershell-profile/main/Set-Profile.ps1'))
#		$ScriptBlock = [System.Management.Automation.ScriptBlock]::Create($installScript)
#		$ScriptArgs=@($False,$False,"C:\SomePath\Profile.ps1")
#		Invoke-Command $ScriptBlock -ArgumentList $ScriptArgs
#	Or download and run this script in PowerShell with the desired parameters.
#
# Arguments: -CurrentUserOnly 'True/False' (Default True), -CurrentHostOnly 'True/False' (Default True), -Source (Default Aaron's profile on Github)
# Output: None
#
# Tested with: Microsoft Windows [Version 10.0.19042.804], PowerShell [Version 5.1.19041.610]
# Tested with: macOS [Version 12.6.0], PowerShell [7.2.6]
#	"Microsoft Windows [Version $([System.Environment]::OSVersion.Version)], PowerShell [$($PSVersionTable.PSVersion.ToString())]"
#	"macOS [Version $([System.Environment]::OSVersion.Version)], PowerShell [$($PSVersionTable.PSVersion.ToString())]"
#
# Notes: 
# --------------------------------------------------------------------------------------------

Param ([bool]$CurrentUserOnly=$True,[bool]$CurrentHostOnly=$True, [string]$Source)

function Get-Destination {
	switch ($CurrentUserOnly)
	{
		$True {
			$CurrentUsersProfilePath=(Split-Path $PROFILE.CurrentUserAllHosts)
			If (!(Test-Path $CurrentUsersProfilePath)) {
				#$fso = New-Object -ComObject Scripting.FileSystemObject
				#$fso.CreateFolder($CurrentUsersProfilePath)
				New-item $CurrentUsersProfilePath -ItemType Directory -force
			}	
			switch ($CurrentHostOnly) {
				$True {return $PROFILE.CurrentUserCurrentHost}
				$False {return $PROFILE.CurrentUserAllHosts}
			}
		}
		$False {
			switch ($CurrentHostOnly) {
				$True {return $PROFILE.AllUsersCurrentHost}
				$False {return $PROFILE.AllUsersAllHosts}
			}
		}
	}
}

$Destination=Get-Destination
try {
	If (!($Source)) {$Source=(New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/awurthmann/my-powershell-profile/main/Profile.ps1')}
	Set-Content -Path $Destination -Value $Source -Force -ErrorAction Stop
}
catch {
	If ($error[0].Exception.Message -like "Access to the path *$(Split-Path $PROFILE.AllUsersAllHosts)* is denied.") {
		Write-Host "Changes to 'All Users' profiles requires administrator permissions." -ForegroundColor Yellow -BackgroundColor Black
	}
	throw
}
