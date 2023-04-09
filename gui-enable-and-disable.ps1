# Check if script is running as admin
# If not, run the same script as admin
# Needed as editing regedit needs admin role
if(!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList "-File `"$($MyInvocation.MyCommand.Path)`"  `"$($MyInvocation.MyCommand.UnboundArguments)`""
  Exit
}

Add-Type -assembly System.Windows.Forms
Add-Type -AssemblyName PresentationFramework

[System.Windows.Forms.Application]::EnableVisualStyles()

$window = New-Object System.Windows.Forms.Form

$window.Text = "Enable/Disable Long Paths"
$window.Width = 600
$window.Height = 300
$window.AutoSize = $false
$window.MaximizeBox = $false
$window.ShowIcon = $false

$infoTxt = New-Object System.Windows.Forms.Label
$infoTxt.Location = New-Object System.Drawing.Point(10, 10)
$infoTxt.Size = New-Object System.Drawing.Size(500, 50)
$infoTxt.Text = "This tool modifies the system Registry to enable/disable long file paths in all file systems. USE WITH CAUTION!"
$window.Controls.Add($infoTxt)

$enableButton = New-Object System.Windows.Forms.Button
$enableButton.Location = New-Object System.Drawing.Point(180, 70)
$enableButton.Size = New-Object System.Drawing.Size(200, 40)
$enableButton.Text = "Enable Long Paths"
$enableButton.Add_Click({
  $window.DialogResult = [System.Windows.Forms.DialogResult]::OK

  $confirmEnable = [System.Windows.MessageBox]::Show("Enabling long file names can have unintended consequences. Make sure you know what you're doing!`n`nDo you want to continue?", "WARNING!", "YesNoCancel", "Warning", "No")
  if ($confirmEnable -eq "Yes") {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value "1"

    $confirmEnableRestart = [System.Windows.MessageBox]::Show("You MUST restart Windows to save and apply the changes. Make sure to save your work. Restart now?", "Restart Confirmation", "YesNo", "Information", "Yes")
    if ($confirmEnableRestart -eq "Yes") {
      Restart-Computer
    } else {
      Exit
    }
  }
})
$window.Controls.Add($enableButton)

$disableButton = New-Object System.Windows.Forms.Button
$disableButton.Location = New-Object System.Drawing.Point(180, 130)
$disableButton.Size = New-Object System.Drawing.Size(200, 40)
$disableButton.Text = "Disable Long Paths"
$disableButton.Add_Click({
  $window.DialogResult = [System.Windows.Forms.DialogResult]::Cancel

  $confirmDisable = [System.Windows.MessageBox]::Show("Disabling long file names may cause issues with already-existing long paths!`n`nDo you want to continue?", "WARNING!", "YesNoCancel", "Warning", "No")
  if ($confirmDisable -eq "Yes") {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value "0"

    $confirmDisableRestart = [System.Windows.MessageBox]::Show("You MUST restart Windows to save and apply the changes. Make sure to save your work. Restart now?", "Restart Confirmation", "YesNo", "Information", "Yes")
    if ($confirmDisableRestart -eq "Yes") {
      Restart-Computer
    } else {
      Exit
    }
  }
})
$window.Controls.Add($disableButton)

$window.ShowDialog()
