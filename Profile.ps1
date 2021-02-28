#powershell.exe


# Written by: Aaron Wurthmann
#
# You the executor, runner, user accept all liability.
# This code comes with ABSOLUTELY NO WARRANTY.
# You may redistribute copies of the code under the terms of the GPL v3.
#
# --------------------------------------------------------------------------------------------
# Name: Profile.ps1
# Version: 2021.02.28.145001
# Description: My PowerShell profile. You are welcome to use it obviously.
# 		For the most part this is being uploaded to Github for easy access and version control.
# 
# Instructions: Rename/Save file to desired location.
#	Description			Path
#	All Users, All Hosts		$PSHOME\Profile.ps1
#	All Users, Current Host		$PSHOME\Microsoft.PowerShell_profile.ps1
#	Current User, All Hosts		$Home\[My ]Documents\PowerShell\Profile.ps1
#	Current user, Current Host	$Home\[My ]Documents\PowerShell\Microsoft.PowerShell_profile.ps1
#
# Tested with: Microsoft Windows [Version 10.0.19042.804], PowerShell [Version 5.1.19041.610]
# Arguments: None
# Output: None
#
# Notes:  
# --------------------------------------------------------------------------------------------





###Functions###

##Prompt Function##
function prompt {
#	Displays shortened path at prompt current drive letter, immediate sub directory and current directory.
#   Example: C:\..\drivers\etc>_
	
	$actualPath=(get-location).Path
	if ($actualPath -like "Microsoft.PowerShell.Core\FileSystem::\\*") {
		$remotePath=$true
		$cwd = ($actualPath -split "\\\\", 0)[1]
	}
	Else {
		$cwd = $actualPath
	}
	
    [array]$cwdt=$()
    $cwdi=-1
    do {
		$cwdi=$cwd.indexofany("\\",$cwdi+1)
		[array]$cwdt+=$cwdi
	}
	until($cwdi -eq -1)

	if ($cwdt.count -gt 3) {
		$cwd = $cwd.substring(0,$cwdt[0]) + "\.." + $cwd.substring($cwdt[$cwdt.count-3])
    }
	If ($remotePath) {$cwd="\\"+$cwd}
	$host.UI.RawUI.WindowTitle = "$startupTitle"+":"+" $actualPath"
	return "$cwd>_"
}
##End Prompt Function##

##Change Directory Function##
function cd_func {
#	When changing directories via 'cd', echo the full path in the desired foreground color.
#	Extends cd's capabilities to allow spaces in the path without encapsulating the path in double-quotes,
#	 this is useful when the path was copy-pasted from Windows explorer or otherwise.
#	Note: See the Alias section below, whereupon the current 'cd' is reset to this function. 

	$fgColor="Cyan"

	If ($args.count -gt 1) {
		Foreach ($arg in $args) {
			If ([string]$path) {$path=$path +" "+ $arg}
			Else {[string]$path=$arg}
		}
	}
	Else {
		[string]$path=$args
	}
	
	If ($Path) {
		If (Test-Path $Path) {
			Set-Location $Path
		}
		Else {
			Write-Host "cd : Cannot find path '$Path:String' because it does not exist." -BackgroundColor black -BackgroundColor black -ForegroundColor red
			Write-Host "At line:1 char:1"  -BackgroundColor black -ForegroundColor red
			Write-Host "+ cd $Path"  -BackgroundColor black -ForegroundColor red
			Write-Host "+"("~" * ($Path.Length + 3)) -BackgroundColor black -ForegroundColor red
			Write-Host "	+ CategoryInfo          : ObjectNotFound: ($Path) [Set-Location], ItemNotFoundException"  -BackgroundColor black -ForegroundColor red
			Write-Host "	+ FullyQualifiedErrorId : PathNotFound,Microsoft.PowerShell.Commands.SetLocationCommand"  -BackgroundColor black -ForegroundColor red
			Write-Host
			break
		}
	}
	$actualPath=(get-location).Path
	Write-Host "$actualPath" -ForegroundColor $fgColor
}
##End Change Directory Function##

##Cleanup Functions/Variables/Environment Functions##
function Cleanup-Environment {
#	Clears variables and functions to process' (shell's) orginal state when launched.
	Cleanup-Variables
	Cleanup-Functions
	#[System.GC]::Collect() #Current version of PowerShell does garbage collection
}

function Cleanup-Functions {
#	Clears functions to process' (shell's) orginal state when launched.
  Get-ChildItem -Path Function: |
    Where-Object { $startupFunctions -notcontains $_.Name } | 
	 % { Remove-Item -Path Function:"$($_.Name)" }
}

function Cleanup-Variables {
#	Clears variables to process' (shell's) orginal state when launched.
  Get-Variable |
    Where-Object { $startupVariables -notcontains $_.Name } |
     % { Remove-Variable -Name "$($_.Name)" -Force -Scope "global" }
}
##End Cleanup Functions/Variables/Environment Functions##

###End Functions###

###Static Variables###
## Variables needed to support functions
$startupFunctions=""
new-variable -force -name startupFunctions -value ( Get-ChildItem -Path Function: | % { $_.Name } )

$startupVariables=""
new-variable -force -name startupVariables -value ( Get-Variable | % { $_.Name } )
###End Static Variables###

###Aliases###

Remove-Item alias:\cd
Set-Alias cd cd_func

##Windows Specific Aliases##
If ($Env:OS -like "Windows*") {
	Set-Alias ifconfig ipconfig.exe
	
	##Notepad++##
	$nppPath=Get-ItemPropertyValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\notepad++.exe" -Name "(Default)" -ErrorAction Silent
	If ($nppPath -and (Test-Path $nppPath)) {
		Set-Alias npp $nppPath
		Set-Alias notepad++ $nppPath
	}
	##End Notepad++##
}
##End Windows Specific Aliases##

###End Aliases###

###Starting Directory###

#Add/arrange directories by order of preference with $Home at the end
$Directories = @(
	"$env:USERPROFILE\Dropbox\bin\scripts\ps",
	"$env:USERPROFILE\Documents\bin\scripts\ps",
	"$env:USERPROFILE\Documents\WindowsPowerShell",
	"$env:USERPROFILE\Documents",
	"Microsoft.PowerShell.Core\FileSystem::\\Mac\Home\Documents",
	"$Home"
)
ForEach ($Directory in $Directories) {
	If (Test-Path $Directory) {
		Set-Location $Directory
		break
	}
}

###End Starting Directory###


###Modules###

#Modules go here

###End Modules###

