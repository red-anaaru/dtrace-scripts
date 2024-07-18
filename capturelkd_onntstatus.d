#pragma D option destructive

/*inline NTSTATUS STATUS_BUFFER_OVERFLOW = 0x80000005;
inline NTSTATUS STATUS_UNSUCCESSFUL = 0xc0000001UL;
inline NTSTATUS STATUS_INVALID_PARAMETER = 0xc000000DUL;
inline NTSTATUS STATUS_ACCESS_DENIED = 0xc0000022UL;
inline NTSTATUS STATUS_OBJECT_NAME_NOT_FOUND = 0xc0000034;
inline NTSTATUS STATUS_INVALID_ADDRESS = 0xc0000141;

inline NTSTATUS E_FAIL = 0x80004005;
inline NTSTATUS E_OUTOFMEMORY = 0x8007000E */
inline NTSTATUS E_INVALIDARG = 0x80070057;
/*inline NTSTATUS E_NOTSUPPORTED = 0x80040000;
inline NTSTATUS E_NOTIMPL = 0x80010004;
inline NTSTATUS E_FILESTRMFILEIO = 0x80010009;
inline NTSTATUS E_WAIT_TIMEOUT = 0x80070102; */

syscall:::return
/execname == "ms-teams.exe"/
{
    self->status = (NTSTATUS)arg0;

    printf ("status: 0x%x\n", self->status);
    printf ("Return value arg0:%x \n", arg0);
    printf ("User stack: \n");
    ustack(10);
    /* printf ("Triggering LiveDump \n");
    lkd(1); */
    exit(0);
}
