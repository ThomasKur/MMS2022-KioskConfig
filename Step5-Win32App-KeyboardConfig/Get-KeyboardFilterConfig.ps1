<#
.DESCRIPTION
This script checks if the Windows feature Client-KeyboardFilter to prevent specific shortcuts to be used
on a kiosk device is installed on the device.

.NOTES
    Version:          1.0
    Author:           Samantha Howlett/baseVISION
    Creation Date:    23.10.2020
    Modification Date:
    Purpose/Change:   23.10.2020 - Initial script development
    Functions:        Write-ScriptLog
#>   

function Write-ScriptLog {
    <#
    .SYNOPSIS
        Writes logs for this script

    .DESCRIPTION
        Writes logs with date and time into a text file to a specified location.

    .PARAMETER LogPath
        Path where to store the log files

    .EXAMPLE
        Write-Log -LogPath 'c:\logs'

    .NOTES
        Version:          1.0
        Author:           Jeremias Emch/baseVISION
        Creation Date:    <Date>
        Purpose/Change:   Initial script development
    #>

    [CmdletBinding()]
    Param
    (
        # Path for logs
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$LogPath,

        # Log message
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$LogMessage
    )

    Process {
        # Check log path
        if (Test-Path -Path (Split-Path -Path $LogPath)) {
            # Write logs to txt file
            $dt = Get-Date -UFormat %Y"/%m/%d/%T"
            $errorText = $dt + " - " + $LogMessage -replace "`n", " " -replace "´n", " " 
            Out-File -FilePath $LogPath -Append -InputObject $errorText 
        }
        else {
            Write-Host "No access to specified log path ($LogPath)."
            Write-Host "The Script wont be able to load LOGS and it will be terminated." -ForegroundColor Red
            Exit
        }
    }
}

#########################################################################
$LogPath = 'C:\Windows\Logs\KeyboardFilter_Config_Detect.log'

try
{
    $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows Embedded\KeyboardFilter'
    if(Test-Path $regPath){
        $keyboardFilterReg = Get-ItemProperty -Path $regPath
        if($keyboardFilterReg.'Ctrl+Alt+Del' -eq "Blocked"){
            $blockCtrlAltDel = $true
        } else {
            $blockCtrlAltDel = $false
            Write-ScriptLog -LogPath $LogPath -LogMessage "Ctrl+Alt+Del not configured correctly"
        }
        if($keyboardFilterReg.'Win+L' -eq "Blocked"){
            $blockWinLock = $true
        } else {
            $blockWinLock = $false
            Write-ScriptLog -LogPath $LogPath -LogMessage "Win+L not configured correctly"
        }
        if($keyboardFilterReg.'BreakoutKeyScanCode' -eq 71){
            $breakOutConfigured = $true
        } else {
            $breakOutConfigured = $false
            Write-ScriptLog -LogPath $LogPath -LogMessage "BreakoutKeyScanCode not configured correctly"
        }

        if($blockCtrlAltDel -and $blockWinLock -and $breakOutConfigured){
            Write-ScriptLog -LogPath $LogPath -LogMessage "Everything detected"
            Write-Host "Found it!"
        }
    }
}
catch
{
  # Something went wrong, display the error details and write an error to the event log
  Write-ScriptLog -LogPath $LogPath -LogMessage "$_.Exception.Message"
}