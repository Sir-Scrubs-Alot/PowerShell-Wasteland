# Usage:
# When you need to quickly find an uninstaller for a known program.

# Summary:
# This function will query the registry of the local system for the uninstall string of a program you specify.

# Steps:
# 1) Copy and paste the function at the bottom of this document into an elevated PowerShell prompt, then hit Enter.
# 2) Type the following command: Find-UninstallString <partialNameOfProgram>

# Example:
# Find-UninstallString chrome﻿
 
 function Find-UninstallString {
    param (
        $AppName
    )
    $productNames = @("*$AppName*")
    $UninstallKeys = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
                        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall',
                        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'
                        )
    $results = foreach ($key in (Get-ChildItem $UninstallKeys) ) {
        foreach ($product in $productNames) {
            if ($key.GetValue("DisplayName") -like "$product") {
                [pscustomobject]@{
                    KeyName = $key.Name.split('\')[-1];
                    DisplayName = $key.GetValue("DisplayName");
                    UninstallString = $key.GetValue("UninstallString");
                    Publisher = $key.GetValue("Publisher");
                }
            }
        }
    }
    $results | fl *
}
