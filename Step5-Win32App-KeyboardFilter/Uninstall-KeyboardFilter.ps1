<#
.DESCRIPTION
This script installs the Windows feature Client-KeyboardFilter to prevent specific shortcuts to be used
on a kiosk device.

.NOTES
    Version:          1.0
    Author:           Samantha Howlett/baseVISION
    Creation Date:    15.10.2020
    Modification Date:
    Purpose/Change:   15.10.2020 - Initial script development
    Functions:        Write-ScriptLog
                      Enable-Predefined-Key
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
$LogPath = 'C:\Windows\Logs\KeyboardFilter_Uninstall.log'

#Enable keyboard filter feature		
try
{
  Write-ScriptLog -LogPath $LogPath -LogMessage "Start disable keyboard filter Feature"

  #Disable keyboard filter feature without restart	
  Disable-WindowsOptionalFeature -Online -FeatureName Client-KeyboardFilter -NoRestart -OutVariable result	

  #Detect if restart is needed
  if ($result.RestartNeeded -eq $true)
  {
    $restartneeded = $true
    Write-ScriptLog -LogPath $LogPath -LogMessage "Requries a restart"
  }			
}
catch
{
  # Something went wrong, display the error details and write an error to the event log
  Write-ScriptLog -LogPath $LogPath -LogMessage "$_.Exception.Message"
}

#If feature installed and requries a restart, then restart		
if ($restartneeded -eq $true)
{
  exit 3010
}

