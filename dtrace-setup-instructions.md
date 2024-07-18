# How to collect live kernel dump?

There are 3 main ways to collect live kernel dump in Windows:

* Using dtrace
* Using Task Manager

For some of the problems we debug, we need to collect live kernel dump to get a better understanding of the problem.

## Using dtrace

### Installing dtrace

1. Ensure you are using a supported version of Windows. Open admin PowerShell, and run:

```PowerShell
Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' | Select-Object -Property CompositionEditionID, CurrentBuildNumber, InstallationType`.
```

You can a supported Windows version, if the `CurrentBuildNumber` value is greater than 18980, for non-Server SKUs. And 18975 for Windows Server SKUs.
2. Download dtrace from here: [Download DTrace on Windows](https://www.microsoft.com/download/details.aspx?id=100441)
3. Ensure Bitlocker is disabled.
![Control Panel > System and Security > Bitlocker Drive Encryption](image-1.png)

4. Install dtrace by running the installer by running this command from admin PowerShell:
  
  ```PowerShell
  Start-Process msiexec.exe -ArgumentList '/i "$env:USERPROFILE\Downloads\DTrace.amd64.msi" /qn /L*V $env:USERPROFILE\Downloads\dtrace-install.log' -Wait
  [System.Environment]::SetEnvironmentVariable('Path', [System.Environment]::GetEnvironmentVariable('Path') + ';C:\Program Files\DTrace')
  ```

6. From admin cmd prompt, run the following commands:

```cmd
bcdedit /set dtrace ON
REG ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\ /v EnableVirtualizationBasedSecurity /t REG_DWORD /d 1
```

  **Note:** The `reg add` command might throw this warning:
  `Value EnableVirtualizationBasedSecurity exists, overwrite(Yes/No)?`. This is expected. You can type `Yes` and continue.

Also, run the following commands to setup live kernel dump:

```cmd
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CrashControl\FullLiveKernelReports" /f /t REG_DWORD /v FullLiveReportsMax /d 10
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CrashControl" /f /t REG_DWORD /v AlwaysKeepMemoryDump /d 1
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CrashControl\FullLiveKernelReports" /f /t REG_DWORD /v SystemThrottleThreshold /d 0
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CrashControl\FullLiveKernelReports" /f /t REG_DWORD /v ComponentThrottleThreshold /d 0

mkdir %SystemDrive%\livedumps
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CrashControl\LiveKernelReports /v "LiveKernelReportsPath" /t REG_SZ /d "\??\%SystemDrive%\livedumps"
```

7. Setup symbols cache by running the following command:

  ```PowerShell
  mkdir $env:SystemDrive\symbols
  $sym_path = "srv*{0}*https://msdl.microsoft.com/download/symbols" -f $env:SystemDrive\symbols
  [System.Environment]::SetEnvironmentVariable('_NT_SYMBOL_PATH', $sym_path, [System.EnvironmentVariableTarget]::User)
  ```

8. Reboot the machine - `shutdown /r /t 0`

### Collecting live kernel dump

1. Open notepad and paste the following and save it as `capture_invalidarg.d` in the `Downloads` folder:

The following snippet is for capturing a live kernel dump if ms-teams.exe received either `STATUS_INVALID_PARAMETER` or `E_INVALIDARG` as the return value from a system call:

```dtrace
#pragma D option destructive

inline NTSTATUS STATUS_INVALID_PARAMETER = 0xffffffffc000000DUL;
inline NTSTATUS E_INVALIDARG = 0x57;

syscall:::return
/execname == "ms-teams.exe" && (arg0 == STATUS_INVALID_PARAMETER || arg0 == E_INVALIDARG)/
{
    printf("\nStarting to capture invalid argument crashes...\n");    self->status = (NTSTATUS)arg0;
    printf ("\nReturn value: status: 0x%x, arg0:%x \n", self->status, arg0);
    printf ("User stack: \n");
    ustack(10);
    printf ("\nTriggering LiveDump...\n");
    lkd(1);
    exit(0);
}
```

2. Open admin cmd prompt and run the following command:

  ```PowerShell
  dtrace -s $env:USERPROFILE\Downloads\capture_invalidarg.d -o $env:USERPROFILE\Downloads\capture_invalidarg.log
  ```

When the error code is returned by the system call, the live kernel dump will be captured in the `livedumps` folder and dtrace will exit. But leave the machine as is, so that the kernel dump collection can complete. Depending on the RAM size, it might take ~10-15 minutes to complete.
