<#
.DESCRIPTION
This script removes all configured blocked keys for the Windows feature Client-KeyboardFilter.

.NOTES
    Version:          1.0
    Author:           Samantha Howlett/baseVISION
    Creation Date:    15.10.2020
    Modification Date:
    Purpose/Change:   15.10.2020 - Initial script development
    Functions:        Write-ScriptLog
                      Enable-Predefined-Key
                      Remove-BlockedKeys
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
$LogPath = 'C:\Windows\Logs\KeyboardFilter_Config_Uninstall.log'

$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows Embedded\KeyboardFilter"

try{
    if(Test-Path -Path $RegPath){
        Set-ItemProperty -Path $RegPath -Name "Ctrl+Alt+Del" -Value "Allowed"
        Set-ItemProperty -Path $RegPath -Name "Win+L" -Value "Allowed"
        Set-ItemProperty -Path $RegPath -Name "BreakoutKeyScanCode" -Value 91

        #Check
        $KeyboardFilterRegistry = Get-ItemProperty -Path $RegPath
        if($KeyboardFilterRegistry."Ctrl+Alt+Del" -eq "Allowed"){
            Write-ScriptLog -LogPath $LogPath -LogMessage "Disabled keyboard filter for Ctrl+Alt+Del"
        } else {
            Write-ScriptLog -LogPath $LogPath -LogMessage "Keyboard filter for Ctrl+Alt+Del still enabled"
        }
        if($KeyboardFilterRegistry."Win+L" -eq "Allowed"){
            Write-ScriptLog -LogPath $LogPath -LogMessage "Disabled keyboard filter for Win+L"
        } else {
            Write-ScriptLog -LogPath $LogPath -LogMessage "Keyboard filter for Win+L still enabled"
        }
        if($KeyboardFilterRegistry."BreakoutKeyScanCode" -eq 91){
            Write-ScriptLog -LogPath $LogPath -LogMessage "Set BreakoutKey to default successfully - restart required"
        } else {
            Write-ScriptLog -LogPath $LogPath -LogMessage "BreakoutKey not set correctly"
        }
        
        exit 3010
    } else {
        Write-ScriptLog -LogPath $LogPath -LogMessage "Keyboard Filter not present in Registry"
    }
}catch{
    Write-ScriptLog -LogPath $LogPath -LogMessage "$_.Exception.Message"
}