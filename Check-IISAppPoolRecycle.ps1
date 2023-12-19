<#
.SYNOPSIS
    Checks for events related to a specified IIS Application Pool recycle in Windows Event Logs.

.DESCRIPTION
    This script searches the Windows System Event Log for entries related to the recycling of a specified IIS Application Pool. 
    It allows the user to specify the application pool and the timeframe for the search.

.PARAMETER AppPoolName
    The name of the IIS Application Pool to check.

.PARAMETER HoursBack
    The number of hours back to search for events. Must be a positive integer.

.EXAMPLE
    PS> .\CheckAppPoolRecycle.ps1
    This will prompt the user to enter the application pool name and the number of hours back to search.
#>

param (
    [string]$AppPoolName = (Read-Host -Prompt "Enter the Application Pool name"),
    [int]$HoursBack = (Read-Host -Prompt "Enter the number of hours back to search for events")
)

try {
    # Validate the hours input
    if ($HoursBack -le 0) {
        throw "The number of hours must be greater than zero."
    }

    # Calculate the timeframe based on user input
    $TimeFrame = (Get-Date).AddHours(-$HoursBack)

    # Filter the event log for events containing the application pool name
    $AppPoolEvents = Get-WinEvent -LogName System | 
        Where-Object { $_.TimeCreated -gt $TimeFrame -and $_.Message -like "*$AppPoolName*" }

    # Output the results
    if ($AppPoolEvents) {
        Write-Host "Events found for Application Pool '$AppPoolName' in the last $HoursBack hours:"
        $AppPoolEvents | Format-Table TimeCreated, Message -AutoSize
    } else {
        Write-Host "No events found for Application Pool '$AppPoolName' in the last $HoursBack hours."
    }
} catch {
    Write-Host "An error occurred: $_"
}
