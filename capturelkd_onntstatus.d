#pragma D option destructive

inline NTSTATUS STATUS_BUFFER_OVERFLOW = 0x80000005;
inline NTSTATUS STATUS_UNSUCCESSFUL = 0xc0000001UL;
inline NTSTATUS STATUS_INVALID_PARAMETER = 0xc000000DUL;
inline NTSTATUS STATUS_ACCESS_DENIED = 0xc0000022UL;
inline NTSTATUS STATUS_OBJECT_NAME_NOT_FOUND = 0xc0000034;
inline NTSTATUS STATUS_INVALID_ADDRESS = 0xc0000141;

syscall:::return
/execname == "ms-teams.exe"/
{
    self->status = (NTSTATUS)arg0;

    printf ("status: 0x%x\n", self->status);

    if (
            (self->status == STATUS_BUFFER_OVERFLOW) ||
            (self->status == STATUS_UNSUCCESSFUL) ||
            (self->status == STATUS_INVALID_PARAMETER) ||
            (self->status == STATUS_ACCESS_DENIED) ||
            (self->status == STATUS_OBJECT_NAME_NOT_FOUND) ||
            (self->status == STATUS_INVALID_ADDRESS)
        )
    {
        printf ("Return value arg0:%x \n", self->status);
        printf ("User stack: \n");
        ustack(10);
        /* printf ("Triggering LiveDump \n");
        lkd(1); */
        exit(0);
    }
}
