#powershell


# Written by: Aaron Wurthmann
#
# You the executor, runner, user accept all liability.
# This code comes with ABSOLUTELY NO WARRANTY.
# You may redistribute copies of the code under the terms of the GPL v3.
#
# --------------------------------------------------------------------------------------------
# Name: Profile.ps1
# Version: 2021.07.21.094401
# Description: My PowerShell profile. You are welcome to use it obviously.
# 		For the most part this is being uploaded to GitHub for easy access and version control.
# 
# Instructions: Rename/Save file to desired location.
#	Description							Path
#	Windows: All Users, All Hosts		$PSHOME\Profile.ps1
#	Windows: All Users, Current Host	$PSHOME\Microsoft.PowerShell_profile.ps1
#	Windows: Current User, All Hosts	$Home\[My ]Documents\PowerShell\Profile.ps1
#	Windows: Current user, Current Host	$Home\[My ]Documents\PowerShell\Microsoft.PowerShell_profile.ps1
#	MacOs: Current user, Current Host	$Home/.config/powershell/Microsoft.PowerShell_profile.ps1
#	MacOs: Current user, VSCode			$Home/.config/powershell/Microsoft.VSCode_profile.ps1
#
# Tested with: Microsoft Windows [Version 10.0.19042.0], PowerShell [Version 5.1.19041.1023]
# Tested with: macOS [Version 10.15.7], PowerShell [Version 7.1.3]
#	"Microsoft Windows [Version $([System.Environment]::OSVersion.Version)], PowerShell [$($PSVersionTable.PSVersion.ToString())]"
#	"macOS [Version $([System.Environment]::OSVersion.Version)], PowerShell [$($PSVersionTable.PSVersion.ToString())]"
# 
# Arguments: None
# Output: None
#
# Notes:  
# --------------------------------------------------------------------------------------------

###Support Functions###
##Windows Check Function##
function isWindows {
	return $Env:OS -like "Windows*"
}
##End Windows Check Function##

##macOS Check Function##
function isMacOS {
	return $isMacOS -eq $True
}
##End macOS Check Function##

##Admin Check Function##
function isAdmin {
#	Checks if the current user has "Administrator" privileges, returns True or False 
	If(isWindows) {
		$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
		return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
	}
	ElseIf (isMacOS) {
		If (groups $(users) -contains "admin") {
			return $True
		}
		Else {
			return $False
		}
	}
}
##End Admin Check Function##

##Write Color Function
function Write-Color {
<#
 
.SYNOPSIS
Reformats Write-Host output, allowing multiple colors on the same line.
 
.DESCRIPTION
Usually to output information in PowerShell we use Write-Host. By using parameter -ForegroundColor you can define nice looking output text. Write-Color takes things a step further, allowing for multiple colors on the same command.


.PARAMETER Text
Text to be used. Encolse with double quotes " " and seperate with comma ,

.PARAMETER Color
Color to use. Seperate with comma ,

.PARAMETER StartTab
Indent text wih a number of tabs.

.PARAMETER LinesBefore
Blank lines to insert before text.

.PARAMETER LinesAfter
Blank lines to insert after text.

.EXAMPLE
Write-Color -Text "Red ", "Green ", "Yellow " -Color Red,Green,Yellow

.EXAMPLE
Write-Color -Text "This is text in Green ",
	"followed by red ",
	"and then we have Magenta... ",
	"isn't it fun? ",
	"Here goes DarkCyan" -Color Green,Red,Magenta,White,DarkCyan

.NOTES
Orginal Author:  Przemysław Kłys
 Version 0.2
  - Added Logging to file
 Version 0.1
  - First Draft

Edited by: Aaron Wurthmann
 Versoin 0.2A
  - Removed logging to file ability. Conflicts with our preferred method.
  - Added If statment to encapsulate main body.
  - Removed initialization of StartTab, LinesBefore, LinesAfter and adjusted If statments to reflect change.
    + That's meerly a coding prefference, nothing wrong with Przemysław's way.
Edited and tested on PowerShell [Version 5.1.16299.251], Windows [Version 10.0.16299.309]

You can find the colors you can use by using simple code:
	[enum]::GetValues([System.ConsoleColor]) | Foreach-Object {Write-Host $_ -ForegroundColor $_ }

.LINK
Orginal Author's Site -  https://evotec.xyz/powershell-how-to-format-powershell-write-host-with-multiple-colors
#>

Param ([String[]]$Text, [ConsoleColor[]]$Color = "White", [int]$StartTab, [int]$LinesBefore, [int]$LinesAfter=1)

If ($Text) {
		$DefaultColor = $Color[0]
		if ($LinesBefore) {  for ($i = 0; $i -lt $LinesBefore; $i++) { Write-Host "`n" -NoNewline } } # Add empty line before
		if ($StartTab) {  for ($i = 0; $i -lt $StartTab; $i++) { Write-Host "`t" -NoNewLine } }  # Add TABS before text
		if ($Color.Count -ge $Text.Count) {
			for ($i = 0; $i -lt $Text.Length; $i++) { Write-Host $Text[$i] -ForegroundColor $Color[$i] -NoNewLine } 
		} else {
			for ($i = 0; $i -lt $Color.Length ; $i++) { Write-Host $Text[$i] -ForegroundColor $Color[$i] -NoNewLine }
			for ($i = $Color.Length; $i -lt $Text.Length; $i++) { Write-Host $Text[$i] -ForegroundColor $DefaultColor -NoNewLine }
		}
		#Write-Host
		if ($LinesAfter) {  for ($i = 0; $i -lt $LinesAfter; $i++) { Write-Host "`n" } }  # Add empty line after
	}
}
##End Write Color Function
###End Support Functions###

###Operating System Specific Settings###
##Windows Specific Settings##
If (isWindows) {
	
	##Windows Prompt Function##
	function prompt {
		#Example:
		#┌──(aaron@gibson)-[C:\Users\Aaron\Documents\Folder]
		#└ >_
		#
		#	Displays shortened path if current directory is too wide to fit in the window
		#	Example:
		#	┌──(aaron@gibson)-[C:\..\Documents\Folder]
		#	└ >_
		#
		$actualPath=(get-location).Path
		if ($actualPath -like "Microsoft.PowerShell.Core\FileSystem::\\*") {
			$remotePath=$true
			$cwd = ($actualPath -split "\\\\", 0)[1]
		}
		Else {
			$cwd = $actualPath
		}
		$LineDownandRight=[char]0x250C + [char]0x2500 + [char]0x2500
		$LineUpandRight=[char]0x2514
		$LineLength=$("$LineDownandRight($env:username)@$(hostname)-[$cwd]").Length
		$WindowWidth=(get-host).UI.RawUI.WindowSize.Width
		$BackgroundColor=(get-host).ui.rawui.BackgroundColor
		If ($LineLength -ge $WindowWidth) {
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
		}
		
		If (isAdmin) {
			If ($BackgroundColor -eq "Black"){
				$result="$(Write-Color -Text "$LineDownandRight(", "$(($env:username).ToLower())@$(hostname)", ")-[", "$cwd","]`n$LineUpandRight" -Color Red,Blue,Red,White,Red -LinesAfter 0)"
			}
			Else {
				$result="$(Write-Color -Text "$LineDownandRight(", "$(($env:username).ToLower())@$(hostname)", ")-[", "$cwd","]`n$LineUpandRight" -Color Red,Yellow,Red,White,Red -LinesAfter 0)"
			}
			
		}
		Else {
			If ($BackgroundColor -eq "Black"){
				$result="$(Write-Color -Text "$LineDownandRight(", "$(($env:username).ToLower())@$(hostname)", ")-[", "$cwd","]`n$LineUpandRight" -Color Green,Blue,Green,White,Green -LinesAfter 0)"
			}
			Else {
				$result="$(Write-Color -Text "$LineDownandRight(", "$(($env:username).ToLower())@$(hostname)", ")-[", "$cwd","]`n$LineUpandRight" -Color Green,Yellow,Green,White,Green -LinesAfter 0)"
			}
			
		}

		Clear-Variable LineLength,WindowWidth
		
		$host.UI.RawUI.WindowTitle = "$startupTitle"+":"+" $actualPath"
		return $result+" >_"
	}
	##End Windows Prompt Function##
	
	##Windows Aliases##
	Set-Alias ifconfig ipconfig.exe
	
	#Notepad++#
	$nppPath=Get-ItemPropertyValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\notepad++.exe" -Name "(Default)" -ErrorAction Silent
	If ($nppPath -and (Test-Path $nppPath)) {
		Set-Alias npp $nppPath
		Set-Alias notepad++ $nppPath
	}
	#End Notepad++#
	##End Windows Aliases##

	##Windows Path Settings##
	If (Test-Path "$Home\Documents\GitHub") {
		((Get-ChildItem -Recurse $Home\Documents\GitHub\ *.ps1).VersionInfo.FileName) | Split-Path | Get-Unique | 
		 ForEach-Object {$AppendPath+="$_;"}; $env:Path+=";$AppendPath"
		#
	}
	##End Windows Path Settings##
	
	##Windows Starting Directory###
	$Directories = @(
		"$env:USERPROFILE\Dropbox\bin\scripts\ps",
		"$env:USERPROFILE\Documents\bin\scripts\ps",
		#"$env:USERPROFILE\Documents\WindowsPowerShell",
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
	If ($Directory) {Remove-Variable Directory}
	If ($Directories) {Remove-Variable Directories}
	##End Windows Starting Directory###
	

} 
##End Windows Specific Settings##

##macOS Specific Settings##
If (isMacOS) {
	
	##MacOS Prompt Function##
	function prompt {
		#Example:
		#┌──(aaron@gibson)-[/Users/aaron/Documents]
		#└ PS >_
		#
		#	Displays shortened path if current directory is too wide to fit in the window
		#	Example:
		#	┌──(aaron@gibson)-[/Users/../Documents/Folder]
		#	└ PS >_
		#
		$actualPath=(get-location).Path
		if ($actualPath -like "Microsoft.PowerShell.Core\FileSystem::\\*") {
			$remotePath=$true
			$cwd = ($actualPath -split "\\\\", 0)[1]
		}
		Else {
			$cwd = $actualPath
		}
		$LineDownandRight=[char]0x250C + [char]0x2500 + [char]0x2500
		$LineUpandRight=[char]0x2514
		$LineLength=$("$LineDownandRight($env:username)@$(hostname)-[$cwd]").Length
		$WindowWidth=(get-host).UI.RawUI.WindowSize.Width
		$BackgroundColor=(get-host).ui.rawui.BackgroundColor
		If ($LineLength -ge $WindowWidth) {
			[array]$cwdt=$()
			$cwdi=-1
			do {
				$cwdi=$cwd.indexofany("\/",$cwdi+1)
				[array]$cwdt+=$cwdi
			}
			until($cwdi -eq -1)

			if ($cwdt.count -gt 3) {
				$cwd = $cwd.substring(0,$cwdt[1]) + "/.." + $cwd.substring($cwdt[$cwdt.count-2])
			}
			If ($remotePath) {$cwd="\\"+$cwd}
		}
		
		If (isAdmin) {
			If ($BackgroundColor -eq -1){
				$result="$(Write-Color -Text "$LineDownandRight(", "$((whoami).ToLower())@$(hostname)", ")-[", "$cwd","]`n$LineUpandRight" -Color Red,Blue,Red,White,Red -LinesAfter 0)"
			}
			Else {
				$result="$(Write-Color -Text "$LineDownandRight(", "$((whoami).ToLower())@$(hostname)", ")-[", "$cwd","]`n$LineUpandRight" -Color Red,Yellow,Red,White,Red -LinesAfter 0)"
			}
			
		}
		Else {
			If ($BackgroundColor -eq -1){
				$result="$(Write-Color -Text "$LineDownandRight(", "$((whoami).ToLower())@$(hostname)", ")-[", "$cwd","]`n$LineUpandRight" -Color Green,Blue,Green,White,Green -LinesAfter 0)"
			}
			Else {
				$result="$(Write-Color -Text "$LineDownandRight(", "$((whoami).ToLower())@$(hostname)", ")-[", "$cwd","]`n$LineUpandRight" -Color Green,Yellow,Green,White,Green -LinesAfter 0)"
			}
			
		}

		Clear-Variable LineLength,WindowWidth
		
		$host.UI.RawUI.WindowTitle = "$startupTitle"+":"+" $actualPath"
		return $result+" PS >_"
	}
	##End MacOS Prompt Function##
	
	##MacOS Aliases##
	#Visual Studio Code##
	$vscodePath='/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code'
	if (Test-Path $vscodePath) {
		Set-Alias code $vscodePath
		Set-Alias vs $vscodePath
		Set-Alias vscode $vscodePath
	}
	#End Visual Studio Code##
	##End MacOS Aliases##
}
##End macOS Specific Settings##
###End Operating System Specific Settings###


###All Operating Systems Settings###

##All Operating Systems Functions##
#Change Directory Function##
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
		try {
			Set-Location $Path -ErrorAction Stop
		}
		catch {
			if ($error[0].Exception.Message -like "Cannot find path*because it does not exist.") {
				Write-Host "cd : $($error[0].Exception.Message.ToString().Trim())" -BackgroundColor black -ForegroundColor red
				Write-Host "At line:1 char:1"  -BackgroundColor black -ForegroundColor red
				Write-Host "+ cd $Path"  -BackgroundColor black -ForegroundColor red
				Write-Host "+"("~" * ($Path.Length + 3)) -BackgroundColor black -ForegroundColor red
				Write-Host "    + CategoryInfo          :$($error[0].CategoryInfo.ToString().Trim())" -BackgroundColor black -ForegroundColor red
				Write-Host "    + FullyQualifiedErrorId :$($error[0].FullyQualifiedErrorId.ToString().Trim())" -BackgroundColor black -ForegroundColor red
			}
			else {throw}
		}
		finally {
			Write-Host (get-location).Path -ForegroundColor $fgColor
		}
	}
}
#End Change Directory Function##

#The 'which' Function##
function which ($cmd) {
	# Use to identify the location of executables
	try {
		$result=Get-Command $cmd
		If ($result.CommandType -eq "Alias") {
			return $result.DisplayName
		}
		Else {
			return $result.Definition
		} 
	}
	catch {
		throw
	}
}
#End The 'which' Function##

#Tail Function
function tail {
	Param (
		[parameter(Position=0,Mandatory,HelpMessage="Enter file path",ValueFromPipeline,ValueFromPipelineByPropertyName)]
		[Alias("File")]
		[string]$FilePath
	)
	try {
		Get-Content -Path $FilePath -Wait
	}
	catch {
		throw
	}
}
##End Tail Function

#Cleanup Functions/Variables/Environment Functions##
function Cleanup-Environment {
#	Clears variables and functions to process' (shell's) original state when launched.
	Cleanup-Variables
	Cleanup-Functions
	#[System.GC]::Collect() #Current version of PowerShell does garbage collection
}

function Cleanup-Functions {
#	Clears functions to process' (shell's) original state when launched.
  Get-ChildItem -Path Function: |
    Where-Object { $startupFunctions -notcontains $_.Name } | 
	 % { Remove-Item -Path Function:"$($_.Name)" }
}

function Cleanup-Variables {
#	Clears variables to process' (shell's) original state when launched.
  Get-Variable |
    Where-Object { $startupVariables -notcontains $_.Name } |
     % { Remove-Variable -Name "$($_.Name)" -Force -Scope "global" }
}
#End Cleanup Functions/Variables/Environment Functions##
##End All Operating Systems Functions##

##All Operating Systems Static Variables##
$startupFunctions=""
new-variable -force -name startupFunctions -value ( Get-ChildItem -Path Function: | % { $_.Name } )

$startupVariables=""
new-variable -force -name startupVariables -value ( Get-Variable | % { $_.Name } )

$startupTitle=(get-host).UI.RawUI.WindowTitle -replace "Windows","" -replace "PowerShell","PSH" -replace "Administrator","Admin"
##End All Operating Systems Static Variables##

##All Operating Systems Aliases###
Remove-Item alias:\cd
Set-Alias cd cd_func
##End All Operating Systems Aliases##
###End All Operating Systems Settings###
