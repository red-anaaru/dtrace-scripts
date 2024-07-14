#pragma D option flowindent

syscall::NtAssignProcessToJobObject:entry
/execname == "svchost.exe"/
{
  self->traceme = 1;
	printf("called %s - job_handle: 0x%x, proc_handle: 0x%x\n", probefunc, arg0, arg1);
}

/*
fbt:::
/self->traceme/
{}

fbt:::entry
/self->traceme/
{
	printf("called %s - job_handle: 0x%x, proc_handle: 0x%x\n", probefunc, arg0, arg1);
}
*/

syscall::NtAssignProcessToJobObject:return
/self->traceme/
{
  printf("%s - %s returned %d, return path offset: 0x%x\n", execname, probefunc, arg1, arg0);
  self->traceme = 0;
}
