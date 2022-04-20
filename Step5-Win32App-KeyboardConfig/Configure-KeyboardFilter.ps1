<#
.DESCRIPTION
This script configures the Windows feature Client-KeyboardFilter to prevent specific shortcuts to be used
on a kiosk device.

.NOTES
    Version:          1.0
    Author:           Samantha Howlett/baseVISION
    Creation Date:    15.10.2020
    Modification Date:
    Purpose/Change:   15.10.2020 - Initial script development
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
$LogPath = 'C:\Windows\Logs\KeyboardFilter_Config.log'

$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows Embedded\KeyboardFilter"

try{
    if(Test-Path -Path $RegPath){
        Set-ItemProperty -Path $RegPath -Name "Ctrl+Alt+Del" -Value "Blocked"
        Set-ItemProperty -Path $RegPath -Name "Win+L" -Value "Blocked"
        Set-ItemProperty -Path $RegPath -Name "BreakoutKeyScanCode" -Value 71

        #Check
        $KeyboardFilterRegistry = Get-ItemProperty -Path $RegPath
        if($KeyboardFilterRegistry."Ctrl+Alt+Del" -eq "Blocked"){
            Write-ScriptLog -LogPath $LogPath -LogMessage "Enabled keyboard filter for Ctrl+Alt+Del"
        } else {
            Write-ScriptLog -LogPath $LogPath -LogMessage "Keyboard filter for Ctrl+Alt+Del still disabled"
        }
        if($KeyboardFilterRegistry."Win+L" -eq "Blocked"){
            Write-ScriptLog -LogPath $LogPath -LogMessage "Enabled keyboard filter for Win+L"
        } else {
            Write-ScriptLog -LogPath $LogPath -LogMessage "Keyboard filter for Win+L still disabled"
        }
        if($KeyboardFilterRegistry."BreakoutKeyScanCode" -eq 71){
            Write-ScriptLog -LogPath $LogPath -LogMessage "Changed BreakoutKey successfully - restart required"
        } else {
            Write-ScriptLog -LogPath $LogPath -LogMessage "BreakoutKey not set correctly"
        }

        #Enable Keyboard Filter service
        $serviceStatus = Get-Service -Name "Microsoft Keyboard Filter" | Select-Object -Property StartType
        if(($serviceStatus.StartType -eq "Disabled")){
            Write-ScriptLog -LogPath $LogPath -LogMessage "Keyboard Filter service is currently disabled"
            Set-Service -Name "MsKeyboardFilter" -StartupType "Automatic"
            $serviceStatus = Get-Service -Name "Microsoft Keyboard Filter" | Select-Object -Property StartType
            if(($serviceStatus.StartType -eq "Automatic")){
                Write-ScriptLog -LogPath $LogPath -LogMessage "Keyboard Filter service StartType is now set to: Automatic"
            } else {
                Write-ScriptLog -LogPath $LogPath -LogMessage "Keyboard Filter service is still disabled."
            } 
        }
        
        #Require restart
        exit 3010
    } else {
        Write-ScriptLog -LogPath $LogPath -LogMessage "Keyboard Filter not present in Registry"
    }
}catch{
    Write-ScriptLog -LogPath $LogPath -LogMessage "$_.Exception.Message"
}