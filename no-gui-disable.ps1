# Check if script is running as admin
# If not, run the same script as admin
# Needed as editing regedit needs admin role
if(!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList "-File `"$($MyInvocation.MyCommand.Path)`"  `"$($MyInvocation.MyCommand.UnboundArguments)`""
  Exit
}

# Disclaimer
$esc = [char]0x1B
Write-Host "$esc[1mWARNING!$esc[0m Disabling long file names may cause issues with already-existing long paths!"

# Confirm that the user wants to edit regedit
$confirm = Read-Host "Do you want to continue? (y/N)"
if ($confirm -eq "y" -or $confirm -eq "Y") {
  Write-Host "`nEditing the Registry...`n"
} else {
  Write-Host "`nStopping...`n"
  Exit
}

# Set the key
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value "0"

# Confirm that the user wants to reboot
$confirmRestart = Read-Host "You $esc[1mMUST$esc[0m restart Windows to save and apply the changes. Make sure to save your work. Restart now? (y/N)"
if ($confirmRestart -eq "y" -or $confirmRestart -eq "Y") {
  Write-Host "Restarting...`n"

  Start-Sleep -Seconds 2
  Restart-Computer
} else {
  Write-Host "Please restart manually as soon as possible!`n"
  Exit
}
