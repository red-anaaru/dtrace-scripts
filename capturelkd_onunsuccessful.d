#pragma D option destructive

inline NTSTATUS STATUS_UNSUCCESSFUL = 0xffffffffc0000001UL;

syscall:::return
/execname == "ms-teams.exe" && arg0 == STATUS_UNSUCCESSFUL/
{
    printf ("stack: \n");
    stack();
    printf ("Triggering LiveDump \n");
    lkd(1);
    exit(0);
}
