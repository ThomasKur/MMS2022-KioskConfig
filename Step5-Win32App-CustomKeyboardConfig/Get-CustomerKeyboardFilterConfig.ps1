<#
.DESCRIPTION
This script checks if the Windows feature Client-KeyboardFilter to prevent specific shortcuts to be used
on a kiosk device is installed on the device.

.NOTES
    Version:          1.1
    Author:           Samantha Howlett, Dominik Stegemann/baseVISION
    Creation Date:    23.10.2020
    Modification Date:
    Purpose/Change:   23.10.2020 - Initial script development
                      26.03.2021 - Added custom keys for Edge
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
$LogPath = 'C:\Windows\Logs\CustomKeyboardFilter_Config_Detect.log'

try
{
    $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows Embedded\KeyboardFilter\CustomFilters'
    if(Test-Path $regPath){
        $keyboardFilterReg = Get-ItemProperty -Path $regPath
        if($keyboardFilterReg.'Ctrl+d' -eq "Blocked"){
            $blockCtrld = $true
        } else {
            $blockCtrld = $false
            Write-ScriptLog -LogPath $LogPath -LogMessage "Ctrl+d not configured correctly"
        }
        if($keyboardFilterReg.'Ctrl+h' -eq "Blocked"){
            $blockCtrlh = $true
        } else {
            $blockCtrlh = $false
            Write-ScriptLog -LogPath $LogPath -LogMessage "Ctrl+h not configured correctly"
        }
        if($keyboardFilterReg.'Ctrl+j' -eq "Blocked"){
            $blockCtrlj = $true
        } else {
            $blockCtrlj = $false
            Write-ScriptLog -LogPath $LogPath -LogMessage "Ctrl+j not configured correctly"
        }
        if($keyboardFilterReg.'Ctrl+o' -eq "Blocked"){
            $blockCtrlo = $true
        } else {
            $blockCtrlo = $false
            Write-ScriptLog -LogPath $LogPath -LogMessage "Ctrl+o not configured correctly"
        }
        if($keyboardFilterReg.'Ctrl+s' -eq "Blocked"){
            $blockCtrls = $true
        } else {
            $blockCtrls = $false
            Write-ScriptLog -LogPath $LogPath -LogMessage "Ctrl+s not configured correctly"
        }
        if($keyboardFilterReg.'Ctrl+Shift+u' -eq "Blocked"){
            $blockCtrlShiftu = $true
        } else {
            $blockCtrlShiftu = $false
            Write-ScriptLog -LogPath $LogPath -LogMessage "Ctrl+Shift+u not configured correctly"
        }
        if($keyboardFilterReg.'F1' -eq "Blocked"){
            $blockf1 = $true
        } else {
            $blockf1 = $false
            Write-ScriptLog -LogPath $LogPath -LogMessage "F1 not configured correctly"
        }
        if($keyboardFilterReg.'F7' -eq "Blocked"){
            $blockf7 = $true
        } else {
            $blockf7 = $false
            Write-ScriptLog -LogPath $LogPath -LogMessage "F7 not configured correctly"
        }

         
        if($blockCtrld -and $blockCtrlh -and $blockCtrlj -and $blockCtrlo -and $blockCtrls -and $blockCtrlShiftu -and $blockf1 -and $blockf7){
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