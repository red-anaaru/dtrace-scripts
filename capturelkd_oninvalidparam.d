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
