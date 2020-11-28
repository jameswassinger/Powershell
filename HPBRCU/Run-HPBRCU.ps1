<#
    Purpose : Gather HP Battery Recall Utility results.
    Author  : James Wassinger
    Created : 4/19/2019

#>

# Logging Function
function Write-LogEntry {
    param(
        [parameter(Mandatory=$true, HelpMessage="Value added to the log file.")]
        [ValidateNotNullOrEmpty()]
        [string]$Value,

        [parameter(Mandatory=$false, HelpMessage="Name of the log file that the entry will written to.")]
        [ValidateNotNullOrEmpty()]
        [string]$FileName = "HPBRCU_$(get-date -f yyyy-MM-dd).log"
    )

    if(!(Test-Path -Path "C:\Windows\Temp")) {
        New-Item -Path "C:\Windows\Temp" -ItemType Directory -Force
    }

    # Determine log file location
    $LogFilePath = Join-Path -Path $env:windir -ChildPath "Temp\$($FileName)"

    # Add value to log file
    try {
        Add-Content -Value "$(Get-Date)     $Value" -LiteralPath $LogFilePath -ErrorAction Stop
    }
    catch [System.Exception] {
        Write-Warning -Message "Unable to append log entry to $FileName file"
    }
}

# Suppress default errors
$erroractionpreference = "SilentlyContinue"
# Assign variable for directory location of the running script.
$ROOT = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

# Path of the install HP Battery Recall Utility on the computer.
$hpbrcu = "C:\Program Files (x86)\Hewlett-Packard\HP Battery Recall Utility"

# Enter the fileshare path where the results should be stored.
$fileShare = "REPLACE_WITH_YOUR_FILESHARE_PATH"

Write-LogEntry -Value "The HPBRCU script is starting on $env:COMPUTERNAME"

if((Test-Path -Path $hpbrcu)) {
    Write-LogEntry -Value "$hpbrcu, path found"

    #Remove any pre-existing XML files the utility may have generated.
    Remove-Item -Recurse -Path (Join-Path $hpbrcu -ChildPath *.xml) -Force

    <# Change to the utility directory. If you do not change to the directory
       and run the program the XML will not be generated. #>
    CD "C:\Program Files (x86)\Hewlett-Packard\HP Battery Recall Utility"

    <# Run the program after changing to the directory where the program resides.
       Switch -s or -o #>
    cmd /c "HPBRCU.exe" -s

    try {
    # Copy the generated output to the specified fileshare path.
    Copy-Item -Path ( Join-Path -Path $hpbrcu -ChildPath *.xml) -Destination (Join-Path -Path $fileShare -ChildPath "$env:COMPUTERNAME.xml") -Force
    } catch {
        Write-LogEntry -Value "failed to copy item(s). $_"
    }
}else{
    <#
        Output what the HP Battery Recall Utility is not installed,
        and exit the script.
    #>
    Write-LogEntry -Value "The HPBRCU is not installed on $env:COMPUTERNAME"
}