#Requires -RunAsAdministrator

# Admin variables
$Browsers = @(
    [PSCustomObject]@{
        Name = "Microsoft Edge"
        ProcessName = "msedge"
        PasswordFiles = @(
            "$env:SystemDrive\Users\*\AppData\Local\Microsoft\Edge\User Data\Default\Login Data"
        )
    }
    [PSCustomObject]@{
        Name = "Google Chrome"
        ProcessName = "chrome"
        PasswordFiles = @(
            "$env:SystemDrive\Users\*\AppData\Local\Google\Chrome\User Data\Default\Login Data"
        )
    }
    [PSCustomObject]@{
        Name = "Brave"
        ProcessName = "brave"
        PasswordFiles = @(
            "$env:SystemDrive\Users\*\AppData\Local\BraveSoftware\Brave-Browser\User Data\Default\Login Data"
        )
    }
    [PSCustomObject]@{
        Name = "Mozilla Firefox"
        ProcessName = "firefox"
        PasswordFiles = @(
            "$env:SystemDrive\Users\*\AppData\Roaming\Mozilla\Firefox\Profiles\*\logins.json"
            "$env:SystemDrive\Users\*\AppData\Roaming\Mozilla\Firefox\Profiles\*\key3.db"
            "$env:SystemDrive\Users\*\AppData\Roaming\Mozilla\Firefox\Profiles\*\key4.db"
        )
    }
)

### Do not edit below
# Some C# magic to mark files for deletion on reboot
Add-Type @'
    using System;
    using System.Text;
    using System.Runtime.InteropServices;
       
    public class LockedFile
    {
        public enum MoveFileFlags
        {
            MOVEFILE_DELAY_UNTIL_REBOOT         = 0x00000004
        }
 
        [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        static extern bool MoveFileEx(string lpExistingFileName, string lpNewFileName, MoveFileFlags dwFlags);
        
        public static bool DeleteFileOnReboot (string sourcefile)
        {
            return MoveFileEx(sourcefile, null, MoveFileFlags.MOVEFILE_DELAY_UNTIL_REBOOT);         
        }
    }
'@

# Functions
function Remove-PasswordFile {
    param (
        [String]$FilePath
    )

    if (Test-Path -LiteralPath $FilePath) {
        if (Test-Path -LiteralPath $FilePath -PathType Container) {
            Write-Output "ERROR: $FilePath is a folder, not a file"
        } else {
            $fileRemoved = $null
            try {
                Remove-Item -LiteralPath $FilePath -ErrorAction Stop
                $fileRemoved = $true
            }
            catch {
                $marked = [LockedFile]::DeleteFileOnReboot($FilePath)
                $fileRemoved = $false
            }
            finally{
                if ($fileRemoved) {
                    Write-Output "$FilePath removed"
                } else {
                    if ($marked) {
                        Write-Output "$FilePath marked for deletion on reboot"
                    } else {
                        Write-Output "ERROR: $FilePath cannot be deleted"
                        throw (New-Object ComponentModel.Win32Exception)
                    }
                }
            }
        }
    }
}

# Main loop
foreach ($browser in $Browsers) {
    $processes = $null
    $processes = Get-Process -name ($browser.ProcessName) -IncludeUserName -ErrorAction SilentlyContinue

    if ($null -ne $processes) {
        Write-Output "`n`"$($browser.Name)`" is running for following users:"
        $processes.Username | Sort-Object -Unique
    } else {
        Write-Output "`n`"$($browser.Name)`" is not running"
    }

    foreach ($passwordFile in (Get-ChildItem -Path ($browser.PasswordFiles))){
        Remove-PasswordFile -FilePath $passwordFile
    }
}