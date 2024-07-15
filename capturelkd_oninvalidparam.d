#pragma D option destructive

inline NTSTATUS STATUS_INVALID_PARAMETER = 0xffffffffc000000DUL;

syscall:::return
/execname == "ms-teams.exe" && arg0 == STATUS_INVALID_PARAMETER/
{
    printf ("stack: \n");
    stack();
    printf ("Triggering LiveDump \n");
    lkd(1);
    exit(0);
}
