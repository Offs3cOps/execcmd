<#

.SYNOPSIS
    Executes a series of cmd commands sequentially.
.DESCRIPTION
    This PowerShell script takes a list of cmd commands as argument and executes them sequentially.

    GitHub : https://github.com/Offs3cOps/execcmd
    
    WARNING: Test this script thoroughly in a non-production environment before using it in production.

    This script is provided "as-is" without any warranty. Use it at your own risk.

.NOTES
    File Name      : execcmd.ps1
    Copyright 2023 - Rahul Satheesan

.LINK
    GitHub : https://github.com/Offs3cOps/execcmd

.LICENSE

    Copyright 2023 Rahul Satheesan (https://github.com/Offs3cOps)

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

#>


param (
    [string] $cmdListFile
)


$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$hostname = $env:COMPUTERNAME

$outputFile = "${hostname}_$timestamp.txt"

$tempOutFile = "${hostname}_Temp_Out_$timestamp.txt"
$tempErrorFile = "${hostname}_Temp_Error_$timestamp.txt"


function ExecuteAndLogCommand($command) {
    $command | Out-File -Append $outputFile
    "==============================================="| Out-File -Append $outputFile

    $process = Start-Process -FilePath cmd.exe -ArgumentList "/C $command" -RedirectStandardOutput $tempOutFile -RedirectStandardError $tempErrorFile -Wait -NoNewWindow -PassThru

    Start-Sleep -Seconds 300
    
    if ((Test-Path $tempOutFile) -OR (Test-Path $tempErrorFile)){
        if ((Get-Content $tempErrorFile) -OR (Get-Content $tempOutFile)) {
        $output = Get-Content $tempOutFile, $tempErrorFile
        $output | Out-File -Append $outputFile
        "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++`n`n"|Out-File -Append $outputFile
        Set-Content -Path $tempOutFile -Value $null
        Set-Content -Path $tempErrorFile -Value $null
        }
    }

}

$startTime = Get-Date
"Hostname: $hostname" | Out-File -Append $outputFile
"`nScript execution started at: $startTime`n`n" | Out-File -Append $outputFile

$commands = Get-Content $cmdListFile

foreach ($command in $commands) {
    ExecuteAndLogCommand $command
}

$finishTime = Get-Date

$executionTime = $finishTime - $startTime

"Script execution finished at: $finishTime" | Out-File -Append $outputFile

Remove-Item $tempOutFile
Remove-Item $tempErrorFile

Write-Host "Output has been saved to $outputFile"
