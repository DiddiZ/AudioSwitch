### Configuration ###
# Declare devices
# Format: (device_id, icon_path), ...
# To see all availabel devices use:
#     Get-AudioDevice -List
$devices = # Headset
		   ("{0.0.0.00000000}.{ecd6fc2e-c811-438d-91b1-dbcc1fbe5ed7}", "%SystemRoot%\system32\mmres.dll,6"),
		   # Speaker
           ("{0.0.0.00000000}.{b25a9bd1-7217-42fe-a99f-5c6231096c8b}", "%SystemRoot%\system32\mmres.dll,4")
# Error icon is displayed when the current device in unknown. Windows updates may change the device ids.
$errorIcon = "%SystemRoot%\system32\shell32.dll,10"

# Location of this file
$scriptPath = $script:MyInvocation.MyCommand.Path
$scriptDir = Split-Path $scriptPath

# Path to the created shortcut. The location of this script is usually fine.
$link = "$ScriptDir\AudioSwitch.lnk"

### Functions ###
# Re-pins the shortcut to the quick launch bar in order to refresh the shortcut icon in the task bar.
function Re-Pin($Target){
	$KeyPath1  = "HKCU:\SOFTWARE\Classes"
	$KeyPath2  = "*"
	$KeyPath3  = "shell"
	$KeyPath4  = "{:}"
	$ValueName = "ExplorerCommandHandler"
	$ValueData = (Get-ItemProperty("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Windows.taskbarpin")).ExplorerCommandHandler

	$Key2 = (Get-Item $KeyPath1).OpenSubKey($KeyPath2, $true)
	$Key3 = $Key2.CreateSubKey($KeyPath3, $true)
	$Key4 = $Key3.CreateSubKey($KeyPath4, $true)
	$Key4.SetValue($ValueName, $ValueData)

	$Shell = New-Object -ComObject "Shell.Application"
	$Folder = $Shell.Namespace((Get-Item $Target).DirectoryName)
	$Item = $Folder.ParseName((Get-Item $Target).Name)
	$Item.InvokeVerb($KeyPath4) # Remove
	$Item.InvokeVerb($KeyPath4) # Add

	$Key3.DeleteSubKey($KeyPath4)
	if ($Key3.SubKeyCount -eq 0 -and $Key3.ValueCount -eq 0) {
		$Key2.DeleteSubKey($KeyPath3)
	}
}

# Re-creates the shortcut. It runs this script silently.
function ShortCut($target, $icon){
	$wshshell = new-object -comobject wscript.shell
	$shortCut = $wshShell.CreateShortCut($target)
	$Shortcut.TargetPath = "powershell"
	$shortCut.Arguments = "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`""
	$shortCut.IconLocation = $icon
	$shortCut.WindowStyle = 7
	$shortCut.Save()
}

### Main ###
# Find current audio device
$current = Get-AudioDevice -Playback
$curIdx = -1
for ($i=0; $i -lt $devices.length; $i++){
	$deviceId = $devices[$i][0]
	If ($current.ID -eq $deviceId){
		$curIdx = $i
		break;
	}
}

# Switch to next audio device
if ($curIdx -gt -1) {
	# Select next audio device
	$device = $devices[($curIdx+1)%$devices.length]
	$deviceId = $device[0]
	$deviceIcon = $device[1]
	# Change audio device
	Set-AudioDevice -ID $deviceId | Out-Null
	# Update shortcut
	ShortCut $link $deviceIcon
} else {
	# Unknown audio device. Shange shortcut icon to error icon.
	ShortCut $link $errorIcon
}
# Refresh task bar
Re-Pin $link
