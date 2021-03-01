# my-powershell-profile
My PowerShell profile. You are welcome to use it. (Obviously! It's public).
For the most part this is being uploaded to Github for easy access and version control.

## Legal
	You the executor, runner, user accept all liability.
	This code comes with ABSOLUTELY NO WARRANTY.
	You may redistribute copies of the code under the terms of the GPL v3.

## Instructions:
	Copy/Paste the line below into PowerShell for default settings (Current User/Local Host)
```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/awurthmann/my-powershell-profile/main/Set-Profile.ps1'))
```
```powershell
	> . $PROFILE
```
	or close and reopen PowerShell
## Alternative Instructions:
	  - Download Set-Profile.ps1
	  - Open PowerShell
```powershell
	  > Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```
	  - Execute Set-Profile.ps1 with desired paramaters.
