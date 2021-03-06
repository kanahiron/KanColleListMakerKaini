#ifndef isfilled
#module YR3L2H
#uselib "kernel32.dll"
#func VirtualAllocYR3L2H "VirtualAlloc" int, int, int, int
#func VirtualFreeYR3L2H "VirtualFree" int, int, int
#define NULL                   0x00000000
#define PAGE_EXECUTE_READWRITE 0x00000040
#define MEM_COMMIT             0x00001000
#define MEM_RESERVE            0x00002000
#define MEM_DECOMMIT           0x00004000
#define MEM_RELEASE            0x00008000
#deffunc YR3L2H_destructor onexit
	if(NULL != isfilled_ptr) {
		VirtualFreeYR3L2H isfilled_ptr, 144, MEM_DECOMMIT
		VirtualFreeYR3L2H isfilled_ptr, 0, MEM_RELEASE
		isfilled_ptr = NULL
	}
	return
#deffunc YR3L2H_constructor
	YR3L2H_destructor
	VirtualAllocYR3L2H NULL, 144, MEM_RESERVE, PAGE_EXECUTE_READWRITE
	VirtualAllocYR3L2H stat, 144, MEM_COMMIT, PAGE_EXECUTE_READWRITE
	isfilled_ptr    = stat
	dupptr isfilled_bin, stat, 144, vartype("int")
	isfilled_bin.0  = $83EC8B55, $558B10EC, $084D8B10, $00F06583, $0C5D8B53, $6B01438D
	isfilled_bin.6  = $835603C0, $8D57FCE0, $D2850171, $45895C7E, $F45DF7F4, $D0AF0F4A
	isfilled_bin.12 = $6583D603, $DB8500F8, $418D3A7E, $084D8902, $89087529, $7529FC45
	isfilled_bin.18 = $8AFA8BFC, $085D8B01, $753B0438, $38068A35, $8A2F7507, $5D8B0241
	isfilled_bin.24 = $3B0438FC, $45FF2475, $0C5D8BF8, $3903C783, $D77CF85D, $8BF045FF
	isfilled_bin.30 = $5503F045, $10453BF4, $C033B07C, $5B5E5F40, $C033C3C9, $0000F7EB
	return
#define global isfilled(%1, %2, %3) \
	prm@YR3L2H = varptr(%1), %2, %3:\
	mref value@YR3L2H, 64:\
	value@YR3L2H = callfunc(prm@YR3L2H, isfilled_ptr@YR3L2H, 3)
#global
YR3L2H_constructor
#endif
