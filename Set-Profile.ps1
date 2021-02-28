#powershell.exe


# Written by: Aaron Wurthmann
#
# You the executor, runner, user accept all liability.
# This code comes with ABSOLUTELY NO WARRANTY.
# You may redistribute copies of the code under the terms of the GPL v3.
#
# --------------------------------------------------------------------------------------------
# Name: Set-Profile.ps1
# Version: 2021.02.28.101201
# Description: <TO BE ADDED>
# 
# Instructions: <TO BE ADDED>
#
# Tested with: Microsoft Windows [Version 10.0.19042.804], PowerShell [Version 5.1.19041.610]
# Arguments: None
# Output: None
#
# Notes: 
# --------------------------------------------------------------------------------------------

Param ([bool]$CurrentUserOnly=$True,[bool]$CurrentHostOnly=$True, [string]$Source)

function Get-Destination {
	switch ($CurrentUserOnly)
	{
		$True {
			$CurrentUsersProfilePath=(Split-Path $PROFILE.CurrentUserAllHosts)
			If (!(Test-Path $CurrentUsersProfilePath)) {New-Item -ItemType Directory -Force -Path $CurrentUsersProfilePath}	
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
$Source=(New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/awurthmann/my-powershell-profile/main/Profile.ps1')
## iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/awurthmann/my-powershell-profile/main/Set-Profile.ps1'))
Add-Content -Path $Destination -Value $Source -Force
