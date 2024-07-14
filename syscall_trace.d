#pragma D option flowindent

syscall::Nt*Job*:entry
{
  self->traceme = 1;
	printf("%s - %s", execname, probefunc);
}

syscall::Nt*Job*:return
/self->traceme/
{
  printf("%s - %s returned %d", execname, probefunc, arg0);
  self->traceme = 0;
}
