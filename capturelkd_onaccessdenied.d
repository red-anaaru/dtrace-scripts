#pragma D option destructive

inline NTSTATUS STATUS_ACCESS_DENIED = 0xffffffffc0000022UL;

syscall:::return
/execname == "ms-teams.exe" && arg0 == STATUS_ACCESS_DENIED/
{
    printf ("stack: \n");
    stack();
    printf ("Triggering LiveDump \n");
    lkd(1);
    exit(0);
}
