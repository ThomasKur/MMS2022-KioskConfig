<#
.DESCRIPTION
This script removes all configured blocked keys for the Windows feature Client-KeyboardFilter.

.NOTES
    Version:          1.1
    Author:           Samantha Howlett, Dominik Stegemann/baseVISION
    Creation Date:    23.10.2020
    Modification Date:
    Purpose/Change:   23.10.2020 - Initial script development
                      26.03.2021 - Added custom keys for Edge
    Functions:        Write-ScriptLog
                      Remove-Custom-Key
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

function Remove-Custom-Key {
    <#
    .SYNOPSIS
        Remove a key combination for Keyboard Filter to block

    .DESCRIPTION
        Remove a key combination for Keyboard Filter to block

    .PARAMETER KeyId
        Key combination to remove

    .EXAMPLE
        Enable-Custom-Key "Ctrl+d"

    .NOTES
        Version:          1.0
        Author:           https://docs.microsoft.com/en-us/windows-hardware/customize/enterprise/wekf-customkeyremove
        Creation Date:    <Date>
        Purpose/Change:   Initial script development
    #>

    [CmdletBinding()]
    Param
    (
        # Key combination
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$KeyId
    )

    # Call the static Remove() method on the class reference
        $retval = $classCustomKey.Remove($KeyId)

    # Check the return value for status
        if ($retval.ReturnValue -eq 0) {

    # Custom key combination removed successfully
            $Removemessage = "Removed ${KeyID}."
            Write-ScriptLog -LogPath $LogPath -LogMessage "$Removemessage"

        } elseif ($retval.ReturnValue -eq 2147942523) {

    # No object exists with the specified custom key
            $Errormessage = "Failed to remove ${KeyID}. No object found."
            Write-ScriptLog -LogPath $LogPath -LogMessage "$Errormessage"
        } else {

    # Unknown error, report error code in hexadecimal
            $Generalerrormessage = "Failed to remove ${KeyID}. Unknown Error: " + "{0:x0}" -f $retval.ReturnValue
            Write-ScriptLog -LogPath $LogPath -LogMessage "$Generalerrormessage"
    }

}

#########################################################################
$LogPath = 'C:\Windows\Logs\CustomKeyboardFilter_Config_Uninstall.log'

$COMPUTER = "localhost"
$NAMESPACE = "root\standardcimv2\embedded"
# Create a handle to the class instance so we can call the static methods
$classCustomKey = [wmiclass]"\\$COMPUTER\${NAMESPACE}:WEKF_CustomKey"

$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows Embedded\KeyboardFilter"


try{
    if(Test-Path -Path $RegPath){

        #Change RegPath to the CustomerFilters, after check for Windows Keyboard Filter Service
        $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows Embedded\KeyboardFilter\CustomFilters"

        #Removing all custom keys that have the Enabled property set to false
        $objDisabledCustomKeys = Get-WmiObject -Namespace $NAMESPACE -Class WEKF_CustomKey;

        foreach ($objCustomKey in $objDisabledCustomKeys) {
            if (!$objCustomKey.Allowed) {
                Remove-Custom-Key($objCustomKey.Id)
            }
        }


        #Check
        if(Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows Embedded\KeyboardFilter\CustomFilters' -Name "Ctrl+d" -ErrorAction SilentlyContinue){
            Write-ScriptLog -LogPath $LogPath -LogMessage "Keyboard filter for Ctrl+d still enabled"
        } else {
            Write-ScriptLog -LogPath $LogPath -LogMessage "Disabled keyboard filter for Ctrl+d"
        }

        if(Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows Embedded\KeyboardFilter\CustomFilters' -Name "Ctrl+h" -ErrorAction SilentlyContinue){
            Write-ScriptLog -LogPath $LogPath -LogMessage "Keyboard filter for Ctrl+h still enabled"
        } else {
            Write-ScriptLog -LogPath $LogPath -LogMessage "Disabled keyboard filter for Ctrl+h"
        }
        if(Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows Embedded\KeyboardFilter\CustomFilters' -Name "Ctrl+j" -ErrorAction SilentlyContinue){
            Write-ScriptLog -LogPath $LogPath -LogMessage "Keyboard filter for Ctrl+j still enabled"
        } else {
            Write-ScriptLog -LogPath $LogPath -LogMessage "Disabled keyboard filter for Ctrl+j"
        }
        if(Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows Embedded\KeyboardFilter\CustomFilters' -Name "Ctrl+o" -ErrorAction SilentlyContinue){
            Write-ScriptLog -LogPath $LogPath -LogMessage "Keyboard filter for Ctrl+o still enabled"
        } else {
            Write-ScriptLog -LogPath $LogPath -LogMessage "Disabled keyboard filter for Ctrl+o"
        }
        if(Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows Embedded\KeyboardFilter\CustomFilters' -Name "Ctrl+s" -ErrorAction SilentlyContinue){
            Write-ScriptLog -LogPath $LogPath -LogMessage "Keyboard filter for Ctrl+s still enabled"
        } else {
            Write-ScriptLog -LogPath $LogPath -LogMessage "Disabled keyboard filter for Ctrl+s"
        }
        if(Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows Embedded\KeyboardFilter\CustomFilters' -Name "Ctrl+Shift+u" -ErrorAction SilentlyContinue){
            Write-ScriptLog -LogPath $LogPath -LogMessage "Keyboard filter for Ctrl+Shift+u still enabled"
        } else {
            Write-ScriptLog -LogPath $LogPath -LogMessage "Disabled keyboard filter for Ctrl+Shift+u"
        }
        if(Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows Embedded\KeyboardFilter\CustomFilters' -Name "F1" -ErrorAction SilentlyContinue){
            Write-ScriptLog -LogPath $LogPath -LogMessage "Keyboard filter for F1 still enabled"
        } else {
            Write-ScriptLog -LogPath $LogPath -LogMessage "Disabled keyboard filter for F1"
        }
        if(Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows Embedded\KeyboardFilter\CustomFilters' -Name "F7" -ErrorAction SilentlyContinue){
            Write-ScriptLog -LogPath $LogPath -LogMessage "Keyboard filter for F7 still enabled"
        } else {
            Write-ScriptLog -LogPath $LogPath -LogMessage "Disabled keyboard filter for F7"
        }
        exit 3010
    } else {
        Write-ScriptLog -LogPath $LogPath -LogMessage "Custom Keyboard Filter not present in Registry"
    }
}catch{
    Write-ScriptLog -LogPath $LogPath -LogMessage "$_.Exception.Message"
}