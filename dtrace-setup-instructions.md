# How to collect live kernel dump?

There are 3 main ways to collect live kernel dump in Windows:

* Using dtrace
* Using Task Manager

For some of the problems we debug, we need to collect live kernel dump to get a better understanding of the problem.

## Using dtrace

### Installing dtrace

1. Ensure you are using a supported version of Windows. From PowerShell, run `Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' | Select-Object -Property CurrentBuildNumber, LCUVer` to check the version of Windows you are using. The `CurrentBuildNumber` value should be greater than 18980 (for non-Server SKUs) and 18975 for Windows Server SKUs.
2. Download dtrace from here: [Download DTrace on Windows](https://www.microsoft.com/download/details.aspx?id=100441)
3. Install dtrace by running the installer.
4. From PowerShell, `setx $env:PATH "$env:PATH;C:\Program Files\DTrace"`
5. Ensure Bitlocker is disabled. From admin powershell, run the following:

    ```powershell
    Get-BitLockerVolume -MountPoint "C:" | Select-Object -Property VolumeStatus, ProtectionStatus
    ```

    If the output is `FullyEncrypted`, run the following:

    ```powershell
    Disable-BitLocker -MountPoint "C:"
    ```

6. From admin cmd prompt, run the following commands:

  ```cmd
  bcdedit /set dtrace ON
  REG ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\ /v EnableVirtualizationBasedSecurity /t REG_DWORD /d 1
  ```

  **Note:** The `reg add` command might warn and prompt you whether to overwrite if `EnableVirtualizationBasedSecurity` is already set. You can ignore this warning and proceed.
7. Setup symbols cache by running the following command:

  ```cmd
  mkdir %SystemDrive%\dtrace
  setx _NT_SYMBOL_PATH "srv*%SystemDrive%\dtrace*https://msdl.microsoft.com/download/symbols"
  ```

8. Reboot the machine.
