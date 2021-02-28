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
# Instructions: <MORE TO BE ADDED>
# iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/awurthmann/my-powershell-profile/main/Set-Profile.ps1'))
#
# Tested with: Microsoft Windows [Version 10.0.19042.804], PowerShell [Version 5.1.19041.610]
# Arguments: None
# Output: None
#
# Notes: <NEED TO UPDATE INSTRUCTIONS AND ADD ADMIN CHECK AND PROMPT SECTION UNDER CURRENTUSERONLY FALSE>
#	<NEED TO ADD ABILITY TO SPECIFY AN OTHER SOURCE>
# --------------------------------------------------------------------------------------------

Param ([bool]$CurrentUserOnly=$True,[bool]$CurrentHostOnly=$True, [string]$Source)

function Get-Destination {
	switch ($CurrentUserOnly)
	{
		$True {
			$CurrentUsersProfilePath=(Split-Path $PROFILE.CurrentUserAllHosts)
			If (!(Test-Path $CurrentUsersProfilePath)) {
				#New-Item -ItemType Directory -Force -Path $CurrentUsersProfilePath #Native Method to create Dir. Might be too slow
				$fso = New-Object -ComObject scripting.filesystemobject
				$fso.CreateFolder($CurrentUsersProfilePath)
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
try{
	$Source=(New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/awurthmann/my-powershell-profile/main/Profile.ps1')
	Add-Content -Path $Destination -Value $Source -Force
}
catch {
	throw
}
