<#
.Synopsis
This script performs a check if there are active users logged on to a system an if not then reboots the pc after x seconds. This is usefull in kiosk scenarious where the logon from lockscreen is not happening automatically. 

.NOTES
  Version:        1.0
  Author:         Thomas Kurth - baseVISION AG
  Blog:           https://www.wpninjas.ch
  Creation Date:  2022.04.20
  Purpose/Change: Initial script development

#>

[CmdletBinding()]
Param(
)

## Manual Variable Definition
########################################################
# Script Configuration
$DebugPreference = "Continue"
$ScriptVersion = "001"
$ScriptName = "Kiosk-AutologinFix"


$LogFilePathFolder = "c:\Windows\Logs"
$FallbackScriptPath = "C:\Windows" # This is only used if the filename could not be resolved(IE running in ISE)

# Log Configuration
$DefaultLogOutputMode = "Console-LogFile" # "Console-LogFile","Console-WindowsEvent","LogFile-WindowsEvent","Console","LogFile","WindowsEvent","All"
$DefaultLogWindowsEventSource = $ScriptName
$DefaultLogWindowsEventLog = "CustomPS"

 
#region Functions
########################################################
 
function Write-Log {
    <#
    .DESCRIPTION
    Write text to a logfile with the current time.
 
    .PARAMETER Message
    Specifies the message to log.
 
    .PARAMETER Type
    Type of Message ("Info","Debug","Warn","Error").
 
    .PARAMETER OutputMode
    Specifies where the log should be written. Possible values are "Console","LogFile" and "Both".
 
    .PARAMETER Exception
    You can write an exception object to the log file if there was an exception.
 
    .EXAMPLE
    Write-Log -Message "Start process XY"
 
    .NOTES
    This function should be used to log information to console or log file.
    #>
    param(
        [Parameter(Mandatory = $true, Position = 1)]
        [String]
        $Message
        ,
        [Parameter(Mandatory = $false)]
        [ValidateSet("Info", "Debug", "Warn", "Error")]
        [String]
        $Type = "Debug"
        ,
        [Parameter(Mandatory = $false)]
        [ValidateSet("Console-LogFile", "Console-WindowsEvent", "LogFile-WindowsEvent", "Console", "LogFile", "WindowsEvent", "All")]
        [String]
        $OutputMode = $DefaultLogOutputMode
        ,
        [Parameter(Mandatory = $false)]
        [Exception]
        $Exception
    )
    
    $DateTimeString = Get-Date -Format "yyyy-MM-dd HH:mm:sszz"
    $Output = ($DateTimeString + "`t" + $Type.ToUpper() + "`t" + $Message)
    if ($Exception) {
        $ExceptionString = ("[" + $Exception.GetType().FullName + "] " + $Exception.Message)
        $Output = "$Output - $ExceptionString"
    }
 
    if ($OutputMode -eq "Console" -OR $OutputMode -eq "Console-LogFile" -OR $OutputMode -eq "Console-WindowsEvent" -OR $OutputMode -eq "All") {
        if ($Type -eq "Error") {
            Write-Error $output
        }
        elseif ($Type -eq "Warn") {
            Write-Warning $output
        }
        elseif ($Type -eq "Debug") {
            Write-Debug $output
        }
        else {
            Write-Verbose $output -Verbose
        }
    }
    
    if ($OutputMode -eq "LogFile" -OR $OutputMode -eq "Console-LogFile" -OR $OutputMode -eq "LogFile-WindowsEvent" -OR $OutputMode -eq "All") {
        try {
            Add-Content $LogFilePath -Value $Output -ErrorAction Stop
        }
        catch {
            exit 99001
        }
    }
 
    if ($OutputMode -eq "Console-WindowsEvent" -OR $OutputMode -eq "WindowsEvent" -OR $OutputMode -eq "LogFile-WindowsEvent" -OR $OutputMode -eq "All") {
        try {
            New-EventLog -LogName $DefaultLogWindowsEventLog -Source $DefaultLogWindowsEventSource -ErrorAction SilentlyContinue
            switch ($Type) {
                "Warn" {
                    $EventType = "Warning"
                    break
                }
                "Error" {
                    $EventType = "Error"
                    break
                }
                default {
                    $EventType = "Information"
                }
            }
            Write-EventLog -LogName $DefaultLogWindowsEventLog -Source $DefaultLogWindowsEventSource -EntryType $EventType -EventId 1 -Message $Output -ErrorAction Stop
        }
        catch {
            exit 99002
        }
    }
}
 
function New-Folder {
    <#
    .DESCRIPTION
    Creates a Folder if it's not existing.
 
    .PARAMETER Path
    Specifies the path of the new folder.
 
    .EXAMPLE
    CreateFolder "c:\temp"
 
    .NOTES
    This function creates a folder if doesn't exist.
    #>
    param(
        [Parameter(Mandatory = $True, Position = 1)]
        [string]$Path
    )
    # Check if the folder Exists
 
    if (Test-Path $Path) {
        Write-Log "Folder: $Path Already Exists"
    }
    else {
        New-Item -Path $Path -type directory | Out-Null
        Write-Log "Creating $Path"
    }
}


function Get-ActiveUserSession {
    $Users = query user 2>&1

    $Users = $Users | ForEach-Object {
        (($_.trim() -replace ">" -replace "(?m)^([A-Za-z0-9]{3,})\s+(\d{1,2}\s+\w+)", '$1  none  $2' -replace "\s{2,}", "," -replace "none", $null))
    } | ConvertFrom-Csv

    $Sessions = @()
    foreach ($User in $Users)
    {
        $Sessions += [PSCustomObject]@{
            Username = $User.USERNAME
            SessionState = $User.STATE.Replace("Disc", "Disconnected")
            SessionType = $($User.SESSIONNAME -Replace '#', '' -Replace "[0-9]+", "")
        } 
    }

    # Check if a user is active
    $ActiveSessions = $Sessions | Where-Object { $_.SessionType -eq "console" -and $_.SessionState -eq "Active" } 
    return $ActiveSessions

}

#endregion

#region Dynamic Variables and Parameters
########################################################
 
# Try get actual ScriptName
try {
    $CurrentFileNameTemp = $MyInvocation.MyCommand.Name
    If ($CurrentFileNameTemp -eq $null -or $CurrentFileNameTemp -eq "") {
        $CurrentFileName = "NotExecutedAsScript"
    }
    else {
        $CurrentFileName = $CurrentFileNameTemp
    }
}
catch {
    $CurrentFileName = $LogFilePathScriptName
}
$LogFilePath = "$LogFilePathFolder\{0}_{1}_{2}.log" -f ($ScriptName -replace ".ps1", ''), $ScriptVersion, (Get-Date -uformat %Y%m%d%H%M)
# Try get actual ScriptPath
try {
    try { 
        $ScriptPathTemp = Split-Path $MyInvocation.MyCommand.Path
    }
    catch {
 
    }
    if ([String]::IsNullOrWhiteSpace($ScriptPathTemp)) {
        $ScriptPathTemp = Split-Path $MyInvocation.InvocationName
    }
 
    If ([String]::IsNullOrWhiteSpace($ScriptPathTemp)) {
        $ScriptPath = $FallbackScriptPath
    }
    else {
        $ScriptPath = $ScriptPathTemp
    }
}
catch {
    $ScriptPath = $FallbackScriptPath
}
 
#endregion
 
#region Initialization
########################################################
 


 
#endregion

#region Install Script
########################################################

New-Folder $LogFilePathFolder
Write-Log "Start Script $Scriptname"

    ###########################################################################################
	# Get the current script path and content and save it to the client
	###########################################################################################

	$currentScript = Get-Content -Path $($PSCommandPath)

	$schtaskScript = $currentScript[(0) .. ($currentScript.IndexOf("#region Install Script") - 1)]
    $schtaskScript = $schtaskScript + $currentScript[($currentScript.IndexOf("#endregion Install Script") + 1) .. ($currentScript.IndexOf("#endregion Main Script"))]

	$scriptSavePath = $(Join-Path -Path $env:ProgramData -ChildPath $ScriptName )

	if (-not (Test-Path $scriptSavePath)) {

		New-Folder $scriptSavePath 
	}

	$scriptSavePathName = "$ScriptName.ps1"

	$scriptPath = $(Join-Path -Path $scriptSavePath -ChildPath $scriptSavePathName)

	$schtaskScript | Out-File -FilePath $scriptPath -Force

	###########################################################################################
	# Create dummy vbscript to hide PowerShell Window popping up 
	###########################################################################################

	$vbsDummyScript = "
	Dim shell,fso,file

	Set shell=CreateObject(`"WScript.Shell`")
	Set fso=CreateObject(`"Scripting.FileSystemObject`")

	strPath=WScript.Arguments.Item(0)

	If fso.FileExists(strPath) Then
		set file=fso.GetFile(strPath)
		strCMD=`"powershell -nologo -executionpolicy ByPass -command `" & Chr(34) & `"&{`" &_
		file.ShortPath & `"}`" & Chr(34)
		shell.Run strCMD,0
	End If
	"

	$scriptSavePathName = "$ScriptName-VBSHelper.vbs"

	$dummyScriptPath = $(Join-Path -Path $scriptSavePath -ChildPath $scriptSavePathName)

	$vbsDummyScript | Out-File -FilePath $dummyScriptPath -Force

	$wscriptPath = Join-Path $env:SystemRoot -ChildPath "System32\wscript.exe"

	###########################################################################################
	# Register a scheduled task to run in system context every x min
	###########################################################################################

	$schtaskName = $ScriptName
	$schtaskDescription = "This script performs a check if there are active users logged on to a system an if not then reboots the pc after x seconds. This is usefull in kiosk scenarious where the logon from lockscreen is not happening automatically."

	$trigger = New-ScheduledTaskTrigger -Daily -At 12am

	#call the vbscript helper and pass the PosH script as argument
	$action = New-ScheduledTaskAction -Execute $wscriptPath -Argument "`"$dummyScriptPath`" `"$scriptPath`"" 
	$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 5)

	$task = Register-ScheduledTask -TaskName $schtaskName -Trigger $trigger -Action $action  -Settings $settings -Description $schtaskDescription -User "System" -RunLevel Highest -Force
    
    $task.Triggers.Repetition.Duration = "P1D" # Repeat for a duration of one day
    $task.Triggers.Repetition.Interval = "PT5M" # Repeat every 5 minutes, use PT1H for every hour
    $task | Set-ScheduledTask
	Start-ScheduledTask -TaskName $schtaskName


# Exit script as it was executed as Installation
exit 0

#endregion Install Script

#region Main Script
########################################################

if($null -ne (Get-ActiveUserSession)){
    # User is logged on and active, nothing to do
} else {
    # Provide enough time to logon for another user
    Write-Log "No active sessions discovered, start sleep and check in 60 seconds"
    Start-Sleep -Seconds 60
    # Check if still nobody is signed on
    if($null -ne (Get-ActiveUserSession)){
        # User is now logged on and active, nothing to do
    } else {
        # Reboot PC
        Write-Log "Still no active sessions discovered, start reboot"
        Restart-Computer -Force
    }
}

#endregion Main Script
